#--------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development 
# AUTHOR: JMJR
#
# TOPIC: Preparin GIS data
#--------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------
## PACKAGES AND LIBRARIES:
#
#---------------------------------------------------------------------------------------
# --- Load ---
library(sf)
library(raster)
library(exactextractr)

library(dplyr)
library(tidyr)
library(matrixStats)

library(sp)         # needed for: as(slvShp, "Spatial")
library(ggplot2)
library(ggrepel)

#Directory: 
current_path ='C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
setwd(current_path)


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Administrative boundaries:
#---------------------------------------------------------------------------------------
#Importing El salvador shapefile
slvShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing El salvador shapefile of segments 
#slvShp_segm <- st_read(dsn='censo2007/shapefiles', layer = "DIGESTYC_Segmentos2007")
slvShp_segm <- st_read(dsn='gis/maps_interim', layer = "segm07_nowater")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')

#---------------------------------------------------------------------------------------
# Preparing Guerrilla boundaries:
#---------------------------------------------------------------------------------------
#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#---------------------------------------------------------------------------------------
# Preparing other Geographic data:
#---------------------------------------------------------------------------------------
schools80 <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/mineduc/escuelas_before_80.csv",header=TRUE)
names(schools80)[1] <- 'codigoce'
schools80 <- na.omit(schools80) 
schools80_sf <- st_as_sf(schools80, coords = c("x", "y"), crs = slv_crs)

#Importing communication lines in 1945
comms45 <- st_read(dsn = "gis/communications", layer = "comms_1945_line")
comms45 <- st_transform(comms45, crs = slv_crs)

#Importing cities in 1945
cities45 <- st_read(dsn = "gis/maps_interim", layer = "cities_1945")
st_crs(cities45)<- slv_crs
cities45 <- st_transform(cities45, crs = slv_crs)

#Roads and railways
railShp <- st_read(dsn = "gis/historic_rail_roads", layer = "railway_1980")
railShp <- st_transform(railShp, crs = slv_crs)

roadShp <- st_read(dsn = "gis/historic_rail_roads", layer = "roads_1980")
roadShp <- st_transform(roadShp, crs = slv_crs)

#---------------------------------------------------------------------------------------
## NIGHT LIGHTS: LOAD + ALIGN + CROP/MASK
#---------------------------------------------------------------------------------------
# Night-lights raster (you can switch to VIIRS if needed)
nl13 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')

# Ensure CRS matches polygons (segments use slv_crs)
# If nl13 has no CRS or differs, project it
if (is.na(crs(nl13))) {
  stop("Night-lights raster has no CRS set. Set it first (crs(nl13) <- ...) before projecting.")
}

if (!compareCRS(crs(nl13), as.character(slv_crs$wkt))) {
  nl13 <- projectRaster(nl13, crs = as.character(slv_crs$wkt))
}

# Crop & mask to El Salvador boundary
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask = slvShp_sp)

#---------------------------------------------------------------------------------------
## DEFINE QUANTILE AND GINI FUNCTIONS 
#---------------------------------------------------------------------------------------
get_q10 <- function(values, coverage_fraction) {
  x <- values[!is.na(values)]
  as.numeric(quantile(x, 0.1, na.rm = TRUE))
}

get_q25 <- function(values, coverage_fraction) {
  x <- values[!is.na(values)]
  as.numeric(quantile(x, 0.25, na.rm = TRUE))
}

get_q75 <- function(values, coverage_fraction) {
  x <- values[!is.na(values)]
  as.numeric(quantile(x, 0.75, na.rm = TRUE))
}

get_q90 <- function(values, coverage_fraction) {
  x <- values[!is.na(values)]
  as.numeric(quantile(x, 0.9, na.rm = TRUE))
}

# Gini helper (base R) — no extra packages needed
gini_vec <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 2) return(NA_real_)
  if (all(x == 0)) return(0)
  x <- sort(x)
  n <- length(x)
  # G = (2*sum(i*x_i))/(n*sum(x)) - (n+1)/n
  (2 * sum(seq_len(n) * x)) / (n * sum(x)) - (n + 1) / n
}

get_gini <- function(values, coverage_fraction) {
  gini_vec(values)
}

gini_w <- function(x, w) {
  ok <- !is.na(x) & !is.na(w) & w > 0
  x <- x[ok]; w <- w[ok]
  if (length(x) < 2) return(NA_real_)
  if (sum(w) == 0) return(NA_real_)
  if (all(x == 0)) return(0)
  
  o <- order(x)
  x <- x[o]; w <- w[o]
  
  W <- sum(w)
  wx <- w * x
  mu <- sum(wx) / W
  if (mu == 0) return(0)
  
  # Weighted Gini via pairwise formula (O(n^2)) is too slow,
  # so use a sorted cumulative approach:
  cw <- cumsum(w)
  # G = (1/(mu*W)) * sum( w_i * (2*cw_i - w_i - W) * x_i ) / W
  sum(w * (2 * cw - w - W) * x) / (mu * W^2)
}

get_gini_w <- function(values, coverage_fraction) {
  gini_w(values, coverage_fraction)
}

#---------------------------------------------------------------------------------------
## TOPOLOGICAL RELATIONS: 
#
#---------------------------------------------------------------------------------------
#Categorize whethere they are in or not for small features 
slvShp_segm_info <- st_make_valid(slvShp_segm)
slvShp_segm_info <- mutate(slvShp_segm_info, within_control=as.numeric(st_intersects(slvShp_segm_info, controlShp, sparse = FALSE)))
segm_in  <- slvShp_segm_info[slvShp_segm_info$within_control==1, ]
segm_out <- slvShp_segm_info[!slvShp_segm_info$within_control==1, ]

mark_within_control <- function(x, control) {
  x <- st_make_valid(x)
  x$within_control <- lengths(st_intersects(x, control)) > 0
  x
}

schools80_sf_info <- mark_within_control(schools80_sf, controlShp)
schools_in <- schools80_sf_info[schools80_sf_info$within_control==1, ]
schools_out <- schools80_sf_info[!schools80_sf_info$within_control==1, ]

cities45_info <- mark_within_control(cities45, controlShp)
cities_in <- cities45_info[cities45_info$within_control==1, ]
cities_out <- cities45_info[!cities45_info$within_control==1, ]

#Categorize whethere they are in or not for lines
comms_in <- st_intersection(comms45, controlShp)
comms_out <- st_difference(comms45, controlShp)

road_in <- st_intersection(roadShp, controlShp)
road_out <- st_difference(roadShp, controlShp)

#Distance to closest school conditional on same side of the border
compute_min_dist <- function(segments, features) {
  if (nrow(segments) == 0 || nrow(features) == 0) {
    # if no features on that side, return all NA
    return(rep(NA_real_, nrow(segments)))
  }
  
  distBrk <- st_distance(segments, features, by_element = FALSE)
  distMatrix <- distBrk %>% as.data.frame() %>% data.matrix()
  distMin <- rowMins(distMatrix)
  as.numeric(distMin)
}

feature_pairs <- list(
  school = list("in" = schools_in, "out" = schools_out),
  cities = list("in" = cities_in,  "out" = cities_out),
  #rail   = list("in" = rail_in,    "out" = rail_out),
  road   = list("in" = road_in,    "out" = road_out),
  comms  = list("in" = comms_in,   "out" = comms_out)
)

for (fname in names(feature_pairs)) {
  segm_in[[paste0("dist_", fname)]]  <- compute_min_dist(segm_in,  feature_pairs[[fname]][["in"]])
  segm_out[[paste0("dist_", fname)]] <- compute_min_dist(segm_out, feature_pairs[[fname]][["out"]])
}

#---------------------------------------------------------------------------------------
## NIGHT LIGHTS QUARTILES WITHIN EACH SEGMENT
#---------------------------------------------------------------------------------------
# (Compute for all segments, not separately for in/out)
slvShp_segm_info$nl_q10 <- exact_extract(nl13_mask, slvShp_segm_info, get_q10)
slvShp_segm_info$nl_q25 <- exact_extract(nl13_mask, slvShp_segm_info, get_q25)
slvShp_segm_info$nl_q75 <- exact_extract(nl13_mask, slvShp_segm_info, get_q75)
slvShp_segm_info$nl_q90 <- exact_extract(nl13_mask, slvShp_segm_info, get_q90)

slvShp_segm_info$nl_gini <- exact_extract(nl13_mask, slvShp_segm_info, get_gini)
slvShp_segm_info$nl_gini_w <- exact_extract(nl13_mask, slvShp_segm_info, get_gini_w)

#---------------------------------------------------------------------------------------
## EXPORT
#---------------------------------------------------------------------------------------
segm_info_dists <- rbind(segm_in, segm_out)

segm_info_dists_df <- st_drop_geometry(segm_info_dists)

nl_df <- slvShp_segm_info %>%
  st_drop_geometry() %>%
  dplyr::select(SEG_ID, nl_q10, nl_q25, nl_q75, nl_q90, nl_gini, nl_gini_w)

segm_info_out <- dplyr::left_join(segm_info_dists_df, nl_df, by = "SEG_ID")

write.csv(segm_info_out,"C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim/segm_info_dists.csv",row.names = FALSE)



#END
