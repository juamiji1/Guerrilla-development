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
#install.packages('spatialEco')

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
library("plyr")
library(spatialEco)


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
slvShp_sp <- as(slvShp, Class='Spatial')

#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Importing worked shapefile
slvShp_segm_info <- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "slvShp_segm_info_sp_onu_91")

#Importing San Salvador location 
capital <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/slv_adm_2020_shp/san_salvador.csv")
capital_sf <- st_as_sf(capital, coords = c("lon", "lat"), crs = slv_crs)

#Importing and simplifying Coast shapefile 
coastShp <- st_read(dsn = "gis/Hidrografia", layer = "coast")
coastShp <- st_transform(coastShp, crs = slv_crs)
coastShp_sp <-as(coastShp, Class='Spatial')
coastShp_sp_simp <- ms_simplify(coastShp_sp, keep = 0.01)
coastSimp_sf<-st_as_sf(coastShp_sp_simp)

#Importing El salvador shapefile of segments 
slvShp_segm <- st_read(dsn='censo2007/shapefiles', layer = "DIGESTYC_Segmentos2007")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm_sp <- as(slvShp_segm, Class='Spatial')

#Importing El salvador political boundaries shapefile
deptoShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm1_2020")
muniShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm2_2020")

deptoShp_sp <-as(deptoShp, Class='Spatial')
muniShp_sp <-as(muniShp, Class='Spatial')

deptoShp_sp_simp <- ms_simplify(deptoShp_sp, keep = 0.01)
muniShp_sp_simp <- ms_simplify(muniShp_sp, keep = 0.01)

deptoSimp_sf<-st_as_sf(deptoShp_sp_simp)
muniSimp_sf<-st_as_sf(muniShp_sp_simp)

#Calculating centroids
deptoShp_centroid <-st_centroid(deptoShp)
muniShp_centroid <-st_centroid(muniShp)

deptoLine <- st_cast(deptoSimp_sf,"MULTILINESTRING")
muniLine <- st_cast(muniSimp_sf,"MULTILINESTRING")


#---------------------------------------------------------------------------------------
## PREPARING RASTERS (NLD, altitude, cacao):
#
#---------------------------------------------------------------------------------------
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/precipitation", 
                       pattern='.tif$', all.files=TRUE, full.names=TRUE)
rainStack <- stack(rastlist)
rainStack <- crop(rainStack, slvShp_sp)
rainMean <- stackApply(rainStack, indices =  rep(1,nlayers(rainStack)), fun = "mean", na.rm = T)
rainMean_mask<-mask(rainMean,slvShp_sp)

rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/temperature/maxtemp", 
                       pattern='.tif$', all.files=TRUE, full.names=TRUE)
maxtempStack <- stack(rastlist)
maxtempStack <- crop(maxtempStack, slvShp_sp)
maxtempMean <- stackApply(maxtempStack, indices =  rep(1,nlayers(maxtempStack)), fun = "mean", na.rm = T)
maxtempMean_mask<-mask(maxtempMean,slvShp_sp)

rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/temperature/mintemp", 
                       pattern='.tif$', all.files=TRUE, full.names=TRUE)
mintempStack <- stack(rastlist)
mintempStack <- crop(mintempStack, slvShp_sp)
mintempMean <- stackApply(mintempStack, indices =  rep(1,nlayers(mintempStack)), fun = "mean", na.rm = T)
mintempMean_mask<-mask(mintempMean,slvShp_sp)

elevation <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
elevation2 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/DEM.tif')
elevation2<-resample(elevation2, elevation, method="bilinear")
ruggedness<- spatialEco::tri(elevation2) 

#---------------------------------------------------------------------------------------
## AVERAGING RASTERS BY SEGMENT LEVEL:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info$rainmean <- exact_extract(rainMean_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$maxtempmean <- exact_extract(maxtempMean_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$mintempmean <- exact_extract(mintempMean_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$ruggedmean <- exact_extract(ruggedness, slvShp_segm_info, 'mean')

#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
#Distance to capital and coast 
slvShp_segm_info$dist_coast<-as.numeric(st_distance(slvShp_segm_info, coastSimp_sf))
slvShp_segm_info$dist_capital<-as.numeric(st_distance(slvShp_segm_info, capital_sf))
slvShp_segm_info$dist_depto2<-as.numeric(st_distance(slvShp_segm_info, deptoLine, by_element = TRUE))
slvShp_segm_info$dist_muni2<-as.numeric(st_distance(slvShp_segm_info, muniLine, by_element = TRUE))

#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
slvShp_segm_info_sp <- as(slvShp_segm_info, Class='Spatial')

#Exporting the shapefile 
writeOGR(obj=slvShp_segm_info_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="slvShp_segm_info_sp_onu_91_v2", driver="ESRI Shapefile",  overwrite_layer=TRUE)




#END