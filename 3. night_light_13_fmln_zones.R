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
current_path ='C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "slv_adm_2020_shp", layer = "slv_admbnda_adm0_2020")
slv_crs <- st_crs(slvShp)

#Importing FMLN control zones
controlShp <- st_read(dsn = "guerrilla_map", layer = "Zonas_control")
controlShp <- st_transform(controlShp, crs = slv_crs)

#Importing FMLN expansion zones
expansionShp <- st_read(dsn = "guerrilla_map", layer = "Zonas_expansion")
expansionShp <- st_transform(expansionShp, crs = slv_crs)

#Importing FMLN disputed zones
disputaShp <- st_read(dsn = "guerrilla_map", layer = "Zonas_disputa")
disputaShp <- st_transform(disputaShp, crs = slv_crs)

#Converting polygons to polylines
control_line <- st_cast(controlShp,"MULTILINESTRING")
expansion_line <- st_cast(expansionShp,"MULTILINESTRING")
disputa_line <- st_cast(disputaShp,"MULTILINESTRING")

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')

## PREPARING THE NIGHT LIGHT GRID:

#Importing the 2013 night light raster 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
crs(nl13)
res(nl13)

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)

#Converting the raster to a same size polygon grid 
nl13Shp_pixels_sp <- rasterToPolygons(nl13_mask, dissolve=FALSE)

#Fixing the nl value 
names(nl13Shp_pixels_sp)[1] <- 'value'

#Transforming sp object to sf object 
nl13Shp_pixels <- st_as_sf(nl13Shp_pixels_sp, coords = c('y', 'x'))
crs(nl13Shp_pixels)


## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:

#Creating indicators for whether the pixel is within each FMLN zone
nl13Shp_pixels_int <- mutate(nl13Shp_pixels, within_control=as.numeric(st_intersects(nl13Shp_pixels, controlShp, sparse = FALSE)), 
                             within_expansion=as.numeric(st_intersects(nl13Shp_pixels, expansionShp, sparse = FALSE)),
                             within_disputa=as.numeric(st_intersects(nl13Shp_pixels, disputaShp, sparse = FALSE)))

#Calculating the minimum distance of each pixel to the FMLN zones 
nl13Shp_pixels_int$dist_control<-as.numeric(st_distance(nl13Shp_pixels, control_line))
nl13Shp_pixels_int$dist_expansion<-as.numeric(st_distance(nl13Shp_pixels, expansion_line))
nl13Shp_pixels_int$dist_disputa<-as.numeric(st_distance(nl13Shp_pixels, disputa_line))

#Subseting to check the bordering pixels 
y<-subset(nl13Shp_pixels_int, dist_control==0)


## EXPORTING THE SHAPEFILE AS AN SP OBJECT:
nl13Shp_pixels_sp <- as(nl13Shp_pixels_int, Class='Spatial')
writeOGR(obj=nl13Shp_pixels_sp, dsn="guerrilla_map", layer="nl13Shp_pixels_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)


## PLOTTING VISUALIZATION CHECKS:
tm_shape(nl13Shp_pixels_int) + 
  tm_polygons('within_control', palette='Greys', alpha= .25) +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(control_line)+
  tm_lines(col='red') +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(y) + 
  tm_polygons(col="within_control", palette="Reds") +
  tm_shape(slvShp) + 
  tm_borders()

#Exporting map of night light density and FMLN zones
tm_shape(nl13_mask) + 
  tm_raster(title='Night Light Density (2013)') +
  tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(disputaShp) + 
  tm_borders(col='pink', lwd = 3, lty = "solid", alpha = NA) +
  tm_shape(expansionShp) + 
  tm_borders(col='blue', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/4-Results/Salvador/plots/night_light_13_salvador.pdf")





#END.




