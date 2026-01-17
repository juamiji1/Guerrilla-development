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
library("rgeos")
library(rmapshaper)
library(geojsonio)
library("viridis") 
library("qpdf")  
library("tools")  


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES:
#
#---------------------------------------------------------------------------------------
#Directory: 
current_path ='/Users/bj6385/Desktop/Guerrillas 2023 Replication/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing FMLN control zones
controlShp <- st_read(dsn = "Data/gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Importing breaks of controlled zones
pnt_controlBrk_400<- st_read(dsn = "Data/gis/nl_segm_lvl_vars", layer = "pnt_controlBrk_400")
pnt_controlBrk_1000<- st_read(dsn = "Data/gis/nl_segm_lvl_vars", layer = "pnt_controlBrk_1000")

#Importing El salvador shapefile
deptoShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_admbnda_adm1_2020")
muniShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_admbnda_adm2_2020")


#Importing worked shapefile
slvShp_segm_info <- st_read(dsn = "Data/gis/nl_segm_lvl_vars", layer = "slvShp_segm_info_sp_onu_91")


#---------------------------------------------------------------------------------------
## PLOTS:
#
#---------------------------------------------------------------------------------------
tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(deptoShp) + 
  tm_borders(lwd = 3) 

tm_shape(deptoShp) + 
  tm_borders(col='black', lwd = 1) +
  tm_shape(controlShp) + 
  tm_polygons(col='red', alpha=.4)+
  tm_scale_bar(position=c("left", "bottom")) +
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="Plots/depto_control_91.pdf")

tm_shape(muniShp) + 
  tm_borders(col='black', lwd = 1) +
  tm_shape(controlShp) + 
  tm_polygons(col='red', alpha=.4)+
  tm_scale_bar(position=c("left", "bottom")) +
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="Plots/muni_control_91.pdf")

