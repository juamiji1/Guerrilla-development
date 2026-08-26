# -------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development
# AUTHOR: JMJR
#
# TOPIC: Centroid-based distances to state institutions (unconditional and same-side)
#
# NOTES: Python companion to FV_1_preparing_GIS_r3comment.R. Uses the same inputs
#        (segments, FMLN control zones, schools 1980, cities 1945, roads 1980,
#        comms 1945) but measures every distance from the SEGMENT CENTROID instead
#        of the polygon boundary, so tracts crossed by a road/line no longer get a
#        mechanical zero. Outputs one CSV with unconditional and same-side
#        (conditional) distances in km.
#
#        Requires: geopandas >= 0.13 (shapely 2). Run: python FV_1_preparing_GIS_centroid_dists.py
# -------------------------------------------------------------------------------------------------

import geopandas as gpd
import pandas as pd
import numpy as np
from shapely import union_all

BASE = "C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/"
OUT = BASE + "gis/maps_interim/segm_centroid_dists.csv"

# Projected CRS in meters (UTM 16N covers El Salvador; distortion is negligible)
CRS_M = 32616

# -------------------------------------------------------------------------------------------------
# Load inputs (same sources as FV_1_preparing_GIS_r3comment.R)
# -------------------------------------------------------------------------------------------------
country = gpd.read_file(BASE + "gis/slv_adm_2020_shp/slv_borders_census2007.shp")
slv_crs = country.crs

segments = gpd.read_file(BASE + "gis/maps_interim/segm07_nowater.shp").to_crs(slv_crs)

control = gpd.read_file(BASE + "gis/guerrilla_map/zona_control_onu_91.shp")
control = control.set_crs(slv_crs, allow_override=True)  # mirrors st_crs(controlShp) <- slv_crs

schools = pd.read_csv(BASE + "gis/mineduc/escuelas_before_80.csv")
schools = schools.dropna()
schools = gpd.GeoDataFrame(schools, geometry=gpd.points_from_xy(schools["x"], schools["y"]), crs=slv_crs)

comms = gpd.read_file(BASE + "gis/communications/comms_1945_line.shp").to_crs(slv_crs)

cities = gpd.read_file(BASE + "gis/maps_interim/cities_1945.shp")
cities = cities.set_crs(slv_crs, allow_override=True).to_crs(slv_crs)

roads = gpd.read_file(BASE + "gis/historic_rail_roads/roads_1980.shp").to_crs(slv_crs)

# Reproject everything to meters and fix invalid geometries
def clean(gdf):
    gdf = gdf.to_crs(CRS_M)
    gdf["geometry"] = gdf.geometry.make_valid()
    return gdf

segments = clean(segments)
control = clean(control)
schools = clean(schools)
comms = clean(comms)
cities = clean(cities)
roads = clean(roads)

control_union = union_all(control.geometry.values)

# -------------------------------------------------------------------------------------------------
# Classify sides (same logic as the R script: any intersection with control = within)
# -------------------------------------------------------------------------------------------------
segments["within_control"] = segments.geometry.intersects(control_union).astype(int)
centroids = segments.geometry.centroid

schools["within_control"] = schools.geometry.intersects(control_union)
cities["within_control"] = cities.geometry.intersects(control_union)

# Lines are split geometrically, as in the R script (st_intersection / st_difference)
comms_in = union_all(comms.geometry.intersection(control_union).values)
comms_out = union_all(comms.geometry.difference(control_union).values)
roads_in = union_all(roads.geometry.intersection(control_union).values)
roads_out = union_all(roads.geometry.difference(control_union).values)

schools_in = union_all(schools.loc[schools.within_control, "geometry"].values)
schools_out = union_all(schools.loc[~schools.within_control, "geometry"].values)
cities_in = union_all(cities.loc[cities.within_control, "geometry"].values)
cities_out = union_all(cities.loc[~cities.within_control, "geometry"].values)

schools_all = union_all(schools.geometry.values)
cities_all = union_all(cities.geometry.values)
roads_all = union_all(roads.geometry.values)
comms_all = union_all(comms.geometry.values)

# -------------------------------------------------------------------------------------------------
# Distances from the centroid (km); NaN when a side has no features
# -------------------------------------------------------------------------------------------------
def dist_km(points, geom):
    if geom is None or geom.is_empty:
        return np.full(len(points), np.nan)
    return points.distance(geom).values / 1000

out = pd.DataFrame({"SEG_ID": segments["SEG_ID"], "within_control": segments["within_control"]})

# Unconditional centroid distances
out["dist_school_unc"] = dist_km(centroids, schools_all)
out["dist_cities_unc"] = dist_km(centroids, cities_all)
out["dist_road_unc"] = dist_km(centroids, roads_all)
out["dist_comms_unc"] = dist_km(centroids, comms_all)

# Same-side (conditional) centroid distances
inside = segments["within_control"] == 1
pairs = {
    "dist_school_cond": (schools_in, schools_out),
    "dist_cities_cond": (cities_in, cities_out),
    "dist_road_cond": (roads_in, roads_out),
    "dist_comms_cond": (comms_in, comms_out),
}
for col, (geom_in, geom_out) in pairs.items():
    d = np.full(len(segments), np.nan)
    d[inside.values] = dist_km(centroids[inside], geom_in)
    d[~inside.values] = dist_km(centroids[~inside], geom_out)
    out[col] = d

# Minimum across institution types
out["dist_any_unc"] = out[["dist_school_unc", "dist_cities_unc", "dist_road_unc", "dist_comms_unc"]].min(axis=1)
out["dist_any_cond"] = out[["dist_school_cond", "dist_cities_cond", "dist_road_cond", "dist_comms_cond"]].min(axis=1)

out.to_csv(OUT, index=False)
print(f"Saved {len(out)} segments to {OUT}")
print(out.drop(columns="SEG_ID").describe().round(2))

# END
