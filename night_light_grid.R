# PROJECT: 
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

# Load raster 
nldi <- raster('NLDI_2006_0p25_rev20111230.tif')
nl06 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F162006.v4b.avg_lights_x_pct.tif')
nl09 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F162009.v4b.avg_lights_x_pct.tif')
nl12 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F182012.v4c.avg_lights_x_pct.tif')
crs(nldi)
res(nldi)
crs(nl06)
res(nl06)
crs(nl09)
res(nl09)
crs(nl12)
res(nl12)

#Bounding box 
poly_grid <- st_make_grid(slvShp, n=1)
crs(poly_grid)

#Sf to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')
poly_grid_sp <- as(poly_grid, Class='Spatial')

#Cropping and masking the raster 
nldi_crop <- crop(nldi, slvShp_sp)
nldi_mask <- mask(nldi_crop, mask=slvShp_sp)

nl06_crop <- crop(nl06, slvShp_sp)
nl06_mask <- mask(nl06_crop, mask=slvShp_sp)
nl09_crop <- crop(nl09, slvShp_sp)
nl09_mask <- mask(nl09_crop, mask=slvShp_sp)
nl12_crop <- crop(nl12, slvShp_sp)
nl12_mask <- mask(nl12_crop, mask=slvShp_sp)

nl06Shp_pixels_sp <- rasterToPolygons(nl06_mask, dissolve=FALSE)
nl09Shp_pixels_sp <- rasterToPolygons(nl09_mask, dissolve=FALSE)
nl12Shp_pixels_sp <- rasterToPolygons(nl12_mask, dissolve=FALSE)
names(nl06Shp_pixels_sp)[1] <- 'value'
names(nl09Shp_pixels_sp)[1] <- 'value'
names(nl12Shp_pixels_sp)[1] <- 'value'

nl06Shp_pixels <- st_as_sf(nl06Shp_pixels_sp)
nl09Shp_pixels <- st_as_sf(nl09Shp_pixels_sp)
nl12Shp_pixels <- st_as_sf(nl12Shp_pixels_sp)

##Export shp 
writeOGR(obj=nl06Shp_pixels_sp, dsn="guerrilla_map", layer="nl06Shp_pixels_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=nl09Shp_pixels_sp, dsn="guerrilla_map", layer="nl09Shp_pixels_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=nl12Shp_pixels_sp, dsn="guerrilla_map", layer="nl12Shp_pixels_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)

#Plot
tm_shape(nl06_mask) + 
  tm_raster() +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(nl09_mask) + 
  tm_raster() +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(nl12_mask) + 
  tm_raster() +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(nldi_mask) + 
  tm_raster() +
  tm_shape(slvShp) + 
  tm_borders()





#END