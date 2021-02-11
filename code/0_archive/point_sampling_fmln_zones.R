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
#library(tidyr)
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
current_path ='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "Zonas_control")
controlShp <- st_transform(controlShp, crs = slv_crs)

#Importing FMLN expansion zones
expansionShp <- st_read(dsn = "gis/guerrilla_map", layer = "Zonas_expansion")
expansionShp <- st_transform(expansionShp, crs = slv_crs)

#Importing FMLN disputed zones
disputaShp <- st_read(dsn = "gis/guerrilla_map", layer = "Zonas_disputa")
disputaShp <- st_transform(disputaShp, crs = slv_crs)

#Converting polygons to polylines
control_line <- st_cast(controlShp,"MULTILINESTRING")
expansion_line <- st_cast(expansionShp,"MULTILINESTRING")
disputa_line <- st_cast(disputaShp,"MULTILINESTRING")

#Sampling points int he borders for the RDD
set.seed(1234)
control_line_sample <- st_sample(control_line, 300, type="regular") 
expansion_line_sample <- st_sample(expansion_line, 300, type="regular")
disputa_line_sample <- st_sample(disputa_line, 300, type="regular")

#Grouping all points 
pnt_control_line_sample <- st_cast(control_line_sample, "POINT")
pnt_expansion_line_sample <- st_cast(expansion_line_sample, "POINT")
pnt_disputa_line_sample <- st_cast(disputa_line_sample, "POINT")

#Converting to an sp spatial object 
pnt_control_line_sample_sp <- as(pnt_control_line_sample, Class='Spatial')
pnt_expansion_line_sample_sp <- as(pnt_expansion_line_sample, Class='Spatial')
pnt_disputa_line_sample_sp <- as(pnt_disputa_line_sample, Class='Spatial')

#COnverting to spatialpoints to spatialpointdataframe to export 
pnt_control_line_sample_sp <- SpatialPointsDataFrame(pnt_control_line_sample_sp, data.frame(ID=1:length(pnt_control_line_sample_sp)))
pnt_expansion_line_sample_sp <- SpatialPointsDataFrame(pnt_expansion_line_sample_sp, data.frame(ID=1:length(pnt_expansion_line_sample_sp)))
pnt_disputa_line_sample_sp <- SpatialPointsDataFrame(pnt_disputa_line_sample_sp, data.frame(ID=1:length(pnt_disputa_line_sample_sp)))
class(pnt_control_line_sample_sp)

#Exporting the shapefile 
writeOGR(obj=pnt_control_line_sample_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/fmln_zone_point_sample", layer="control_line_sample", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=pnt_expansion_line_sample_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/fmln_zone_point_sample", layer="expansion_line_sample", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=pnt_control_line_sample_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/fmln_zone_point_sample", layer="disputa_line_sample", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#Plot checks 
tm_shape(slvShp) + 
  tm_borders(col='black', lwd = 2, lty = "solid", alpha = NA)+
  tm_shape(control_line_sample) +
  tm_symbols(col = "red", scale = .5) 







