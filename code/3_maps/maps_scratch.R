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


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES:
#
#---------------------------------------------------------------------------------------
#Directory: 
current_path ='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Importing El salvador shapefile
deptoShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm1_2020")
muniShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm2_2020")

#Rivers
river1Shp <- st_read(dsn = "gis/Hidrografia", layer = "rioA_merge")
river1Shp <- st_transform(river1Shp, crs = slv_crs)

#Importing worked shapefile
slvShp_segm_info <- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "slvShp_segm_info_sp_onu_91")

#Importing Cattaneo BW Samples
slvShp_segm_sample <- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "segm_info_sample")
control_line_sample <- st_read(dsn = "gis/guerrilla_map", layer = "control_line_sample")


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
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/depto_control_91.pdf")

tm_shape(muniShp) + 
  tm_borders(col='black', lwd = 1) +
  tm_shape(controlShp) + 
  tm_polygons(col='red', alpha=.4)+
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/muni_control_91.pdf")

tm_shape(slvShp_segm_info) + 
  tm_polygons(col='men_lv2', title='Altitude', palette="-RdYlGn", colorNA = "white", textNA = "Missing data")+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red", lwd=10, title="Guerrilla Control")+
  tm_shape(river1Shp)+
  tm_borders(col='blue', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="blue", lwd=10, title="Main Rivers")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.17, legend.title.size =1.1,frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/elev_segm.pdf")

tm_shape(slvShp_segm_sample)+
  tm_fill(col='deepskyblue', alpha=NA)+
  tm_add_legend(type="line", col="deepskyblue", lwd=10, title="Sample of Census Tracts")+
  tm_shape(slvShp_segm_info) + 
  tm_borders()+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red", lwd=10, title="Guerrilla-Controlled Boundary")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_sample.pdf")
  














