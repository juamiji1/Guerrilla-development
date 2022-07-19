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
coopShp <- st_read(dsn = "gis/cooperatives", layer = "cooperatives")
st_crs(coopShp)<- slv_crs

#Importing conflict data location
events <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/edh_muertes_guerra_civil/events_XY.csv")
events_sf <- st_as_sf(events, coords = c("longitud", "latitud"), crs = slv_crs)

victims <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/edh_muertes_guerra_civil/victims_XY.csv")
victims_sf <- st_as_sf(victims, coords = c("longitud", "latitud"), crs = slv_crs)


tm_shape(slvShp_segm) + 
  tm_borders()+
  tmap_options(check.and.fix = TRUE)+
  tm_shape(events_sf) + 
  tm_symbols(col='green', size=2)

