# TOPIC: 
# AUTHOR: JMJR
# DATE: 

#install.packages('bit64')
#install.packages('raster')

## Libraries ------------------------------------------------------------------------------------------------------------------------------------------------------
library(data.table)
library(rgdal)
library(rgeos)
library(ggplot2)
library(ggrepel)
library(sf)
library(sp)
library("ggpubr")
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

## Shapefiles ----------------------------------------------------------------------------------------------------------------------------------------------------
current_path ='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/5-Maps/Salvador/'
setwd(current_path)

##Load old shp 
slvShp <- st_read(dsn = "slv_adm_2020_shp", layer = "slv_admbnda_adm0_2020")
slv_crs <- st_crs(slvShp)

controlShp <- st_read(dsn = "guerrilla_map", layer = "Zonas_control")
controlShp <- st_transform(controlShp, crs = slv_crs)

expansionShp <- st_read(dsn = "guerrilla_map", layer = "Zonas_expansion")
expansionShp <- st_transform(expansionShp, crs = slv_crs)

disputaShp <- st_read(dsn = "guerrilla_map", layer = "Zonas_disputa")
disputaShp <- st_transform(disputaShp, crs = slv_crs)

st_crs(controlShp)
st_crs(expansionShp)
st_crs(disputaShp)

#Sf to sp object 
controlShp_sp <- as(controlShp, Class='Spatial')
expansionShp_sp <- as(expansionShp, Class='Spatial')
disputaShp_sp <- as(disputaShp, Class='Spatial')

##Export shp 
writeOGR(obj=controlShp_sp, dsn="guerrilla_map", layer="controlShp_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=expansionShp_sp, dsn="guerrilla_map", layer="expansionShp_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=disputaShp_sp, dsn="guerrilla_map", layer="disputaShp_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)

#Plot
tm_shape(slvShp) + 
  tm_borders() +
  tm_shape(controlShp) + 
  tm_borders(col='red') +
  tm_shape(expansionShp) + 
  tm_borders(col='blue') +
  tm_shape(disputaShp) + 
  tm_borders(col='pink') 




  

#END.
