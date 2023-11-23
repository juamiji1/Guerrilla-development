#--------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development 
# TOPIC: Using 1982 boundaries 
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
slvShp_segm <- st_read(dsn='gis/cantons', layer = "Cantons_From2007CensusSegments")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')

#---------------------------------------------------------------------------------------
# Preparing Guerrilla boundaries:
#---------------------------------------------------------------------------------------
#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Importing FMLN disputed zones
disputaShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_fmln_onu_91")
st_crs(disputaShp) <- slv_crs

#Converting polygons to polylines
#control_line <- st_cast(controlShp,"MULTILINESTRING")
control_line <- st_read(dsn = "gis/maps_interim", layer = "control91_line")
disputa_line <- st_cast(disputaShp,"MULTILINESTRING")


#---------------------------------------------------------------------------------------
## PREPARING RASTERS FILES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Raster Layers:
#---------------------------------------------------------------------------------------
#Importing the rasters 
nl13 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
nl92 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F101992.v4b.avg_lights_x_pct.tif')
elevation <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
elevation2 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/DEM.tif')

#Aligning the CRS for all rasters 
nl_crs <- crs(nl13)
elevation <- projectRaster(elevation, crs=nl_crs)

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)
nl92_mask <- mask(crop(nl92, slvShp_sp), mask=slvShp_sp)

elevation_crop <- crop(elevation, slvShp_sp)
elevation2_crop <- crop(elevation2, slvShp_sp)

#Masking 
elevation_mask <- mask(elevation_crop, mask=slvShp_sp)
elevation2_mask <- mask(elevation2_crop, mask=slvShp_sp)

#Not considering zeros 
#nl13_mask_zeros <- reclassify(nl13_mask, c(-Inf,0, NA))


#---------------------------------------------------------------------------------------
## AVERAGING RASTERS BY SEGMENT LEVEL:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info1<-slvShp_segm

#Extracting mean
slvShp_segm_info1$nl <- exact_extract(nl13_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$nl92 <- exact_extract(nl92_mask, slvShp_segm, 'mean')
slvShp_segm_info1$elev <- exact_extract(elevation_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$elev2 <- exact_extract(elevation2, slvShp_segm_info1, 'mean')

#Extracting weighted mean
#slvShp_segm_info1$wmean_nl <- exact_extract(nl13_mask, slvShp_segm_info1, 'weighted_mean', weights=area(nl13_mask))


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info2<-slvShp_segm_info1

#Calculating the minimum distance of each segment to the FMLN zones 
slvShp_segm_info2$dist_control<-as.numeric(st_distance(st_make_valid(slvShp_segm), control_line))
slvShp_segm_info2$dist_disputa<-as.numeric(st_distance(st_make_valid(slvShp_segm), disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
slvShp_segm_info2 <- mutate(slvShp_segm_info2, within_control=as.numeric(st_intersects(st_make_valid(slvShp_segm), controlShp, sparse = FALSE)), 
                            within_disputa=as.numeric(st_intersects(st_make_valid(slvShp_segm), disputaShp, sparse = FALSE)))


#---------------------------------------------------------------------------------------
## INCLUDING THE LINE BREAK FE:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info<-slvShp_segm_info2

#Sampling points int the borders for the RDD
set.seed(1234)

control_line_sample <- st_sample(control_line, 1000, type="regular")
pnt_controlBrk_1000 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 400, type="regular")
pnt_controlBrk_400 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(st_make_valid(slvShp_segm_info), pnt_controlBrk_1000, by_element = FALSE)

#Converting from units object to numeric array
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()

#Calculating the min for each row
distMin<-rowMins(distMatrix)

#Extracting the column indexes as the breaks FE 
brkIndex<-which((distMatrix==distMin)==1,arr.ind=TRUE)

#Dropping duplicates and sorting by row 
brkIndexUnique<-brkIndex[!duplicated(brkIndex[, "row"]), ]  
brkIndexUnique<-brkIndexUnique[order(brkIndexUnique[, "row"]),]

#Adding information to shapefile
slvShp_segm_info$cntrldist_brk1000<-distMin
slvShp_segm_info$cntrlbrkfe1000<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(st_make_valid(slvShp_segm_info), pnt_controlBrk_400, by_element = FALSE)

#Converting from units object to numeric array
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()

#Calculating the min for each row
distMin<-rowMins(distMatrix)

#Extracting the column indexes as the breaks FE 
brkIndex<-which((distMatrix==distMin)==1,arr.ind=TRUE)

#Dropping duplicates and sorting by row 
brkIndexUnique<-brkIndex[!duplicated(brkIndex[, "row"]), ]  
brkIndexUnique<-brkIndexUnique[order(brkIndexUnique[, "row"]),]

#Adding information to shapefile
slvShp_segm_info$cntrldist_brk400<-distMin
slvShp_segm_info$cntrlbrkfe400<-brkIndexUnique[, 'col']


#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
#Saving as an R object 
save.image(file='C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/temp/cantons_info.RData')

# Converting from sf to sp object
slvShp_segm_info_sp_v2 <- as(slvShp_segm_info, Class='Spatial')

#Exporting the all data shapefile
#writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="slvShp_segm_info_sp_onu_91", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="slvShp_cantons_info_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)







#END.
