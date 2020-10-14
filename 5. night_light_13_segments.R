# PROJECT: 
# TOPIC: 
# AUTHOR: JMJR
# DATE: 

#install.packages('bit64')
#install.packages('raster')

## LIBRARIES:
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


## PREPARING SHAPEFILES OF FMLN ZONES:

#Directory: 
current_path ='C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/censo2007/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/slv_adm_2020_shp", layer = "slv_admbnda_adm0_2020")
slv_crs <- st_crs(slvShp)

#Importing El salvador shapefile of segments 
slvShp_segm <- st_read(dsn='shapefiles', layer = "DIGESTYC_Segmentos2007")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#Transforming sf object to sp object 
slvShp_segm_sp <- as(slvShp_segm, Class='Spatial')
slvShp_sp <- as(slvShp, Class='Spatial')

#Importing the 2013 night light raster 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
crs(nl13)
res(nl13)

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)

#Averaging by segment 
slvShp_segm_nl13_sp <- extract(nl13_mask, slvShp_segm_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_nl13_sp)[17] <- 'mean_nl'
writeOGR(obj=slvShp_segm_nl13_sp, dsn="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/night_lights", layer="slvShp_segm_nl13_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)

#Transforming sp object to sf object 
slvShp_segm_nl13 <- st_as_sf(slvShp_segm_nl13_sp, coords = c('y', 'x'))

## PLOTTING VISUALIZATION CHECKS:
tm_shape(slvShp_segm_nl13) + 
  tm_polygons(col = "mean_nl", lwd=0.02, title="Mean of Night Light (2013)")+
  tm_layout(frame = FALSE)
  tmap_save(filename="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/4-Results/Salvador/plots/night_light_13_segment_salvador.pdf")




#END.