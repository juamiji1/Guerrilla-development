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
slvShp_segm <- st_read(dsn='gis/maps_interim', layer = "segm07_nowater")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')

#Centroids of segments 
segm_centroid<-st_centroid(st_make_valid(slvShp_segm)) 

#---------------------------------------------------------------------------------------
# Importing other features:
#---------------------------------------------------------------------------------------
#Importing comisarias of PNC  data location
comisarias <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/pnc/comisarias.csv")
comisarias_sf <- st_as_sf(comisarias, coords = c("lon", "lat"), crs = slv_crs)

roadShp <- st_read(dsn = "gis/historic_rail_roads", layer = "roads_1980")
roadShp <- st_transform(roadShp, crs = slv_crs)

roadShp14 <- st_read(dsn = "gis/historic_rail_roads", layer = "roads_selection_2014")
roadShp14 <- st_transform(roadShp14, crs = slv_crs)
roadShp14 <- st_simplify(roadShp14, preserveTopology = FALSE, dTolerance = 10000)

#Importing conflict data location at baseline
events <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/edh_muertes_guerra_civil/events_XY_baseline.csv")
events_sf <- st_as_sf(events, coords = c("longitud", "latitud"), crs = slv_crs)

victims <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/edh_muertes_guerra_civil/victims_XY_baseline.csv")
victims_sf <- st_as_sf(victims, coords = c("longitud", "latitud"), crs = slv_crs)

#Importing location of schools in 2007 year
schools <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/mineduc/matricula_coords_2007.csv",header=TRUE)
names(schools)[1] <- 'codigoce'
schools <- na.omit(schools) 
schools_sf <- st_as_sf(schools, coords = c("x", "y"), crs = slv_crs)

#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info1<-slvShp_segm

#Distance to closest PNC  
distBrk<-st_distance(st_make_valid(slvShp_segm), st_make_valid(comisarias_sf), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_comisaria<-distMin

#Distance to closest road 
distBrk<-st_distance(st_make_valid(slvShp_segm), st_make_valid(roadShp), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_road80<-distMin

distBrk<-st_distance(st_make_valid(slvShp_segm), st_make_valid(roadShp14), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_road14<-distMin

#Using the centroid of the segment 
distBrk<-st_distance(segm_centroid, st_make_valid(roadShp), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$distc_road80<-distMin

distBrk<-st_distance(segm_centroid, st_make_valid(roadShp14), by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$distc_road14<-distMin

#Counting number of events per segment 
intersection <- st_intersection(x = st_make_valid(slvShp_segm), y = events_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info1<-st_join(st_make_valid(slvShp_segm_info1), int_result)
slvShp_segm_info1 <- subset(slvShp_segm_info1, select = -SEG_ID.y)
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'n'] <- 'n_events81'

#Counting number of victims per segment 
intersection <- st_intersection(x = st_make_valid(slvShp_segm), y = victims_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info1<-st_join(st_make_valid(slvShp_segm_info1), int_result)
slvShp_segm_info1 <- subset(slvShp_segm_info1, select = -SEG_ID.y)
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'n'] <- 'n_victims81'

#Counting number of schools per segment 
schools_segm <- st_join(schools_sf, st_make_valid(slvShp_segm), left=TRUE)
enroll_segm <- schools_segm %>% 
               group_by(SEG_ID) %>% 
               dplyr::summarise(secund=sum(matricula_secund), primar=sum(matricula_prim))
enroll_segm <- st_drop_geometry(enroll_segm)

slvShp_segm_info1 <- left_join(slvShp_segm_info1, enroll_segm, by = c("SEG_ID" = "SEG_ID"))


#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
slvShp_segm_info_sp <- as(slvShp_segm_info1, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=slvShp_segm_info_sp, dsn="C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="slvShp_segm_pnc", driver="ESRI Shapefile",  overwrite_layer=TRUE)







#END
