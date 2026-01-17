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
#install.packages('exactextractr')

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
current_path ='/Users/bj6385/Desktop/Guerrillas 2023 Replication/'
setwd(current_path)


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Administrative boundaries:
#---------------------------------------------------------------------------------------
#Importing El salvador shapefile
slvShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

# Control line:
control_line_sample <- st_read(dsn = "Data/gis/guerrilla_map", layer = "control_line_sample")

#Importing FMLN control zones
controlShp <- st_read(dsn = "Data/gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs



#Importing El salvador shapefile of segments 
#slvShp_segm <- st_read(dsn='censo2007/shapefiles', layer = "DIGESTYC_Segmentos2007")
slvShp_segm <- st_read(dsn='Data/gis/maps_interim', layer = "segm07_nowater")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')
#---------------------------------------------------------------------------------------
# Importing other features:
#---------------------------------------------------------------------------------------
#Importing conflict data location
events <- read.csv("Data/gis/edh_muertes_guerra_civil/events_XY.csv")
events_sf <- st_as_sf(events, coords = c("longitud", "latitud"), crs = slv_crs)

victims <- read.csv("Data/gis/edh_muertes_guerra_civil/victims_XY.csv")
victims_sf <- st_as_sf(victims, coords = c("longitud", "latitud"), crs = slv_crs)

events_sf$nvíctimas <- as.numeric(events_sf$nvíctimas)


jitevents <- st_jitter(events_sf, .025)

tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(control_line_sample) + 
  tm_lines(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red2", lwd=10, title="Guerrilla-Controlled Boundary")+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "solid")+
  tm_layout(frame = FALSE) +
  tm_shape(jitevents) + 
  tm_symbols(size="nvíctimas",col="black",title.size="War Events", scale=2, shape=3,sizes.legend=c(50,100,200,500), sizes.legend.labels=c("<=50","100","200","500+")) 
tmap_save(filename="Plots/jiteventsNOVICTIMS&Boundaries.png")


