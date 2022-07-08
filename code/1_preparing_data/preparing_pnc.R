#--------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development 
# TOPIC: 
# AUTHOR: JMJR
# DATE: 
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
# Importing other features:
#---------------------------------------------------------------------------------------
#Importing comisarias of PNC  data location
comisarias <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/pnc/comisarias.csv")
comisarias_sf <- st_as_sf(comisarias, coords = c("lon", "lat"), crs = slv_crs)

roadShp <- st_read(dsn = "gis/historic_rail_roads", layer = "roads_1980")
roadShp <- st_transform(roadShp, crs = slv_crs)

#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info1<-slvShp_segm

#Distance to closest PNC  
distBrk<-st_distance(st_make_valid(slvShp_segm), st_make_valid(comisarias_sf), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_comisaria<-distMin

#Distance to closest road 
distBrk<-st_distance(st_make_valid(slvShp_segm), st_make_valid(roadShp), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_road80<-distMin

#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
slvShp_segm_info_sp <- as(slvShp_segm_info1, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=slvShp_segm_info_sp, dsn="C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="slvShp_segm_pnc", driver="ESRI Shapefile",  overwrite_layer=TRUE)







#END
