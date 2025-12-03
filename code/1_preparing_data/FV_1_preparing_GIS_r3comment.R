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
#install.packages('bit64')
#install.packages('raster')
#install.packages('exactextractr')
#install.packages('rmapshaper')
#install.packages('geojsonio')

library(data.table)
library(rgdal)
library(rgeos)
library(ggplot2)
library(ggrepel)
library(sf)
library(spdep)
library(sp)
library(ggpubr)
library(dplyr)
library(tidyr)
library(scales) 
library(tidyverse)
library(lubridate)
library(gtools)
library(foreign)
library(ggmap)
library(maps)
library(gganimate)
library(gifski)
library(transformr)
library(tmap)
library(raster)
library(exactextractr)
library(matrixStats)
library(rgeos)
library(rmapshaper)
library(geojsonio)
library(plyr)
library(spatialEco)

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

segm_info_dists <- rbind(segm_in, segm_out)
segm_info_dists <- st_drop_geometry(segm_info_dists)

write.csv(segm_info_dists, "C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim/segm_info_dists.csv", row.names = FALSE)



#END
