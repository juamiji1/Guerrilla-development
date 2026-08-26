# -------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development
# AUTHOR: JMJR
#
# TOPIC: Terrain-aware walking time to state institutions (unconditional and same-side)
#
# NOTES: Companion to FV_1_preparing_GIS_centroid_dists.py. Builds a walking-speed
#        cost surface from the DEM using Tobler's hiking function and computes the
#        accumulated walking TIME (minutes) from each segment centroid to the
#        nearest institution of each type, using skimage's MCP_Geometric.
#
#        Unconditional: travel anywhere in the country.
#        Same-side (conditional): travel restricted to the tract's own side of the
#        guerrilla boundary (cells on the other side are impassable), which
#        implements the referee's "no one can cross the boundary" counterfactual
#        physically: routes must go around, not through.
#
#        Requires: geopandas, rasterio, scikit-image (env: geo_clean).
#        Run: python FV_1_preparing_GIS_walktime_dists.py
# -------------------------------------------------------------------------------------------------

import geopandas as gpd
import pandas as pd
import numpy as np
import rasterio
from rasterio import features as rfeatures
from rasterio.warp import calculate_default_transform, reproject, Resampling
from shapely import union_all
from skimage.graph import MCP_Geometric

BASE = "C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/"
DEM_PATH = BASE + "gis/altitud/DEM.tif"
OUT = BASE + "gis/maps_interim/segm_walktime_dists.csv"

CRS_M = 32616   # UTM 16N (meters)
RES = 100       # working resolution of the cost surface (meters)

# -------------------------------------------------------------------------------------------------
# Load vectors (same sources as the centroid script)
# -------------------------------------------------------------------------------------------------
country = gpd.read_file(BASE + "gis/slv_adm_2020_shp/slv_borders_census2007.shp")
slv_crs = country.crs

segments = gpd.read_file(BASE + "gis/maps_interim/segm07_nowater.shp").to_crs(slv_crs)

control = gpd.read_file(BASE + "gis/guerrilla_map/zona_control_onu_91.shp")
control = control.set_crs(slv_crs, allow_override=True)

schools = pd.read_csv(BASE + "gis/mineduc/escuelas_before_80.csv").dropna()
schools = gpd.GeoDataFrame(schools, geometry=gpd.points_from_xy(schools["x"], schools["y"]), crs=slv_crs)

comms = gpd.read_file(BASE + "gis/communications/comms_1945_line.shp").to_crs(slv_crs)

cities = gpd.read_file(BASE + "gis/maps_interim/cities_1945.shp")
cities = cities.set_crs(slv_crs, allow_override=True).to_crs(slv_crs)

roads = gpd.read_file(BASE + "gis/historic_rail_roads/roads_1980.shp").to_crs(slv_crs)


def clean(gdf):
    gdf = gdf.to_crs(CRS_M)
    gdf["geometry"] = gdf.geometry.make_valid()
    return gdf


country = clean(country)
segments = clean(segments)
control = clean(control)
schools = clean(schools)
comms = clean(comms)
cities = clean(cities)
roads = clean(roads)

control_union = union_all(control.geometry.values)
country_union = union_all(country.geometry.values)

segments["within_control"] = segments.geometry.intersects(control_union).astype(int)
centroids = segments.geometry.centroid

# -------------------------------------------------------------------------------------------------
# Reproject the DEM to the working grid (UTM meters, RES resolution)
# -------------------------------------------------------------------------------------------------
with rasterio.open(DEM_PATH) as src:
    dst_transform, w, h = calculate_default_transform(
        src.crs, f"EPSG:{CRS_M}", src.width, src.height, *src.bounds, resolution=RES
    )
    dem = np.full((h, w), np.nan, dtype="float64")
    reproject(
        source=rasterio.band(src, 1),
        destination=dem,
        src_transform=src.transform,
        src_crs=src.crs,
        dst_transform=dst_transform,
        dst_crs=f"EPSG:{CRS_M}",
        resampling=Resampling.bilinear,
        dst_nodata=np.nan,
    )

transform = dst_transform
shape = dem.shape
print(f"Cost grid: {shape[0]} x {shape[1]} cells at {RES} m")

# The DEM declares no nodata: treat out-of-range sentinels as missing before
# computing slopes (El Salvador tops out below 2,800 masl)
dem[(dem < -100) | (dem > 4000)] = np.nan

# -------------------------------------------------------------------------------------------------
# Cost surface: minutes to cross one meter, from Tobler's hiking function
#   speed (km/h) = 6 * exp(-3.5 * |slope + 0.05|), slope = rise/run
# Isotropic approximation: use the local slope magnitude.
# -------------------------------------------------------------------------------------------------
gy, gx = np.gradient(dem, RES)
slope = np.sqrt(gx**2 + gy**2)

speed_kmh = 6.0 * np.exp(-3.5 * np.abs(slope + 0.05))
minutes_per_m = 60.0 / (speed_kmh * 1000.0)

# MCP_Geometric accumulates in CELL units (1 per orthogonal step, sqrt(2) per
# diagonal), so scale the per-meter cost by the cell size once here
minutes_per_m = minutes_per_m * RES

# Cells outside the country (or DEM nodata) are impassable
country_mask = rfeatures.geometry_mask([country_union], out_shape=shape, transform=transform, invert=True)
cost = np.where(country_mask & np.isfinite(minutes_per_m), minutes_per_m, np.inf)

# Side masks for the conditional runs
control_mask = rfeatures.geometry_mask([control_union], out_shape=shape, transform=transform, invert=True)
cost_in = np.where(control_mask, cost, np.inf)     # travel only inside guerrilla zones
cost_out = np.where(~control_mask, cost, np.inf)   # travel only outside

# -------------------------------------------------------------------------------------------------
# Sources: rasterize each institution layer onto the grid
# -------------------------------------------------------------------------------------------------
def source_cells(geoms, grid_cost):
    """Row/col indices of passable cells touched by the features."""
    geoms = [g for g in geoms if g is not None and not g.is_empty]
    if not geoms:
        return []
    mask = rfeatures.geometry_mask(geoms, out_shape=shape, transform=transform, invert=True)
    mask &= np.isfinite(grid_cost)
    return list(zip(*np.nonzero(mask)))


def accumulate(grid_cost, geoms):
    """Accumulated walking time (minutes) from the nearest feature, per cell."""
    starts = source_cells(geoms, grid_cost)
    if not starts:
        return np.full(shape, np.nan)
    mcp = MCP_Geometric(grid_cost)
    cum, _ = mcp.find_costs(starts)
    return np.where(np.isfinite(cum), cum, np.nan)


def extract(cum):
    """Sample the accumulated-cost surface at the segment centroids."""
    rows, cols = rasterio.transform.rowcol(transform, centroids.x.values, centroids.y.values)
    rows = np.clip(np.asarray(rows), 0, shape[0] - 1)
    cols = np.clip(np.asarray(cols), 0, shape[1] - 1)
    return cum[rows, cols]


layers = {"school": schools, "cities": cities, "road": roads, "comms": comms}
inside = (segments["within_control"] == 1).values

out = pd.DataFrame({"SEG_ID": segments["SEG_ID"], "within_control": segments["within_control"]})

for name, gdf in layers.items():
    print(f"... {name}")

    # Unconditional: one run over the whole country
    out[f"time_{name}_unc"] = extract(accumulate(cost, gdf.geometry.values))

    # Same-side: features CLIPPED to each side (a line crossing the boundary
    # contributes its inside portion to the in-surface and its outside portion
    # to the out-surface), then separate runs on each side's masked surface.
    # The two surfaces partition the passable cells, so each centroid is finite
    # on exactly one: take whichever side the centroid cell actually lies on.
    geoms_in = gdf.geometry.intersection(control_union).values
    geoms_out = gdf.geometry.difference(control_union).values
    t_in = extract(accumulate(cost_in, geoms_in))
    t_out = extract(accumulate(cost_out, geoms_out))
    out[f"time_{name}_cond"] = np.where(~np.isnan(t_in), t_in, t_out)

out["time_any_unc"] = out[[f"time_{n}_unc" for n in layers]].min(axis=1)
out["time_any_cond"] = out[[f"time_{n}_cond" for n in layers]].min(axis=1)

# Tracts that are unreachable on foot in practice (isolated islands): set to
# missing rather than reporting astronomical times
timecols = [c for c in out.columns if c.startswith("time")]
n_unreach = (out[timecols] > 10000).any(axis=1).sum()
out[timecols] = out[timecols].where(out[timecols] <= 10000)
print(f"Set {n_unreach} unreachable tract(s) to missing (walking time > 10,000 min)")

out.to_csv(OUT, index=False)
print(f"Saved {len(out)} segments to {OUT}")
print(out.drop(columns="SEG_ID").describe().round(1))

# END
