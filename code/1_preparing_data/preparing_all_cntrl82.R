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
current_path ='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
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

#Importing San Salvador location 
capital <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/slv_adm_2020_shp/san_salvador.csv")
capital_sf <- st_as_sf(capital, coords = c("lon", "lat"), crs = slv_crs)

#---------------------------------------------------------------------------------------
# Preparing Guerrilla boundaries:
#---------------------------------------------------------------------------------------
#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/maps_interim", layer = "zona_control_82")
st_crs(controlShp) <- slv_crs

#Importing FMLN disputed zones
#disputaShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_fmln_onu_91")
#st_crs(disputaShp) <- slv_crs

#Converting polygons to polylines
#control_line <- st_cast(controlShp,"MULTILINESTRING")
control_line <- st_read(dsn = "gis/maps_interim", layer = "control82_line")

#disputa_line <- st_cast(disputaShp,"MULTILINESTRING")

#---------------------------------------------------------------------------------------
# Preparing other Geographic data:
#---------------------------------------------------------------------------------------
#Importing hidrography shapes
lakeShp <- st_read(dsn = "gis/Hidrografia", layer = "lagoA_merge")
lakeShp <- st_transform(lakeShp, crs = slv_crs)

river1Shp <- st_read(dsn = "gis/Hidrografia", layer = "rioA_merge")
river1Shp <- st_transform(river1Shp, crs = slv_crs)

river2Shp <- st_read(dsn = "gis/Hidrografia", layer = "rioL_merge")
river2Shp <- st_transform(river2Shp, crs = slv_crs)

railShp <- st_read(dsn = "gis/historic_rail_roads", layer = "railway_1980")
railShp <- st_transform(railShp, crs = slv_crs)

roadShp <- st_read(dsn = "gis/historic_rail_roads", layer = "roads_1980")
roadShp <- st_transform(roadShp, crs = slv_crs)

roadShp14 <- st_read(dsn = "gis/historic_rail_roads", layer = "roads_selection_2014")
roadShp14 <- st_transform(roadShp14, crs = slv_crs)
roadShp14 <- st_simplify(roadShp14, preserveTopology = FALSE, dTolerance = 10000)

#Importing and simplifying Coast shapefile 
coastShp <- st_read(dsn = "gis/Hidrografia", layer = "coast")
coastShp <- st_transform(coastShp, crs = slv_crs)
coastShp_sp <-as(coastShp, Class='Spatial')
coastShp_sp_simp <- ms_simplify(coastShp_sp, keep = 0.01)
coastSimp_sf<-st_as_sf(coastShp_sp_simp)

#Importing location of parroquias
parroquias <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/parroquias/parroquias_coord.csv")
parroquias_sf <- st_as_sf(parroquias, coords = c("longitude", "latitude"), crs = slv_crs)

#Importing location of parroquias
parr80 <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/parroquias/parr80_coord.csv")
parr80_sf <- st_as_sf(parr80, coords = c("longitude", "latitude"), crs = slv_crs)

#Importing location of parroquias franciscanas
francis <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/parroquias/francis_coord.csv")
francis_sf <- st_as_sf(francis, coords = c("longitude", "latitude"), crs = slv_crs)

#Importing location of hospitals in 2015
hospitales <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/minsalud/MINSAL_0.csv")
hospitales_sf <- st_as_sf(hospitales, coords = c("LON", "LAT"), crs = slv_crs)

#Importing location of schools in ???year
schools <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/mineduc/matricula_coords_2007.csv",header=TRUE)
names(schools)[1] <- 'codigoce'
schools <- na.omit(schools) 
schools_sf <- st_as_sf(schools, coords = c("x", "y"), crs = slv_crs)

#Importing El salvador political boundaries shapefile
deptoShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm1_2020")
muniShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm2_2020")

deptoShp_sp <-as(deptoShp, Class='Spatial')
muniShp_sp <-as(muniShp, Class='Spatial')

deptoShp_sp_simp <- ms_simplify(deptoShp_sp, keep = 0.01)
muniShp_sp_simp <- ms_simplify(muniShp_sp, keep = 0.01)

deptoSimp_sf<-st_as_sf(deptoShp_sp_simp)
muniSimp_sf<-st_as_sf(muniShp_sp_simp)

deptoLine <- st_cast(deptoSimp_sf,"MULTILINESTRING")
muniLine <- st_cast(muniSimp_sf,"MULTILINESTRING")

#Importing homicides in 2017
homicides <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/homicidios/homicides2017.csv")
homicides$x<-as.numeric(homicides$x)
homicides$y<-as.numeric(homicides$y)
homicides <- na.omit(homicides) 
homicides_sf <- st_as_sf(homicides, coords = c("x", "y"), crs = slv_crs)

homicides_gang <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/homicidios/homicides_coord_03_16.csv")
homicides_gang$Latitud<-as.numeric(homicides_gang$Latitud)
homicides_gang$Longitud<-as.numeric(homicides_gang$Longitud)
homicides_gang <- na.omit(homicides_gang) 
homicides_gang_sf <- st_as_sf(homicides_gang, coords = c("Longitud", "Latitud"), crs = slv_crs)

#Importing communication lines in 1945
comms45 <- st_read(dsn = "gis/communications", layer = "comms_1945_line")
comms45 <- st_transform(comms45, crs = slv_crs)

#Importing cities in 1945
cities45 <- st_read(dsn = "gis/maps_interim", layer = "cities_1945")
st_crs(cities45)<- slv_crs
cities45 <- st_transform(cities45, crs = slv_crs)

#Importing cultivated area in 1980
grown80 <- st_read(dsn = "gis/maps_interim", layer = "cultivated_1980")
st_crs(grown80)<- slv_crs
grown80 <- st_transform(grown80, crs = slv_crs)

#Importing high population density area in 1980
popdens80 <- st_read(dsn = "gis/maps_interim", layer = "popdens_1980")
popdens80 <- st_transform(popdens80, crs = slv_crs)

highpopdens80 <- st_read(dsn = "gis/maps_interim", layer = "highpop_dens80")
st_crs(highpopdens80)<- slv_crs
highpopdens80 <- st_transform(highpopdens80, crs = slv_crs)


#---------------------------------------------------------------------------------------
## PREPARING RASTERS FILES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Raster Layers:
#---------------------------------------------------------------------------------------
#Importing the rasters 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
elevation <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
elevation2 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/DEM.tif')
cacao <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Cacao/res02_crav6190h_coco000a_yld.tif')
bean <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Phaseolus bean/res02_crav6190h_bean000a_yld.tif')
cocoa <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Cocoa/data.asc')
coffee <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Coffee/data.asc')
cotton <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Cotton/data.asc')
drice <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Dryland rice/data.asc')
maize <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Maize/data.asc')
bean2 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Phaseaolus bean/data.asc')
sugarcane <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Sugarcane/data.asc')
wrice <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/New/Wetland rice/data.asc')
dhydro <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/Hidrografia/dwater30.tif')
kmhydro <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/Hidrografia/kmwater30.tif')
flow <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/Hidrografia/flow.tif')

#Aligning the CRS for all rasters 
nl_crs <- crs(nl13)
elevation <- projectRaster(elevation, crs=nl_crs)
cacao <- projectRaster(cacao, crs=nl_crs)
bean <- projectRaster(bean, crs=nl_crs)

#Resampling elevation and creating slope raster
#elevation2<-resample(elevation2, elevation, method="bilinear")     <------------------------------ELEVATION RESAMPLE OFF
dhydro<-resample(dhydro, elevation, method="bilinear")
kmhydro<-resample(kmhydro, elevation, method="bilinear")
flow<-resample(flow, elevation, method="bilinear")

slope <- terrain(elevation2, opt='slope', unit='degrees', neighbors=4)
ruggedness<- spatialEco::tri(elevation2) 

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)
elevation_crop <- crop(elevation, slvShp_sp)
elevation2_crop <- crop(elevation2, slvShp_sp)
cacao_crop <- crop(cacao, slvShp_sp)
bean_crop <- crop(bean, slvShp_sp)
cocoa_crop <- crop(cocoa, slvShp_sp)
coffee_crop <- crop(coffee, slvShp_sp)
cotton_crop <- crop(cotton, slvShp_sp)
drice_crop <- crop(drice, slvShp_sp)
maize_crop <- crop(maize, slvShp_sp)
bean2_crop <- crop(bean2, slvShp_sp)
sugarcane_crop <- crop(sugarcane, slvShp_sp)
wrice_crop <- crop(wrice, slvShp_sp)

#Masking 
elevation_mask <- mask(elevation_crop, mask=slvShp_sp)
elevation2_mask <- mask(elevation2_crop, mask=slvShp_sp)
cacao_mask <- mask(cacao_crop, mask=slvShp_sp)
bean_mask <- mask(bean_crop, mask=slvShp_sp)

#Not considering zeros 
nl13_mask_zeros <- reclassify(nl13_mask, c(-Inf,0, NA))

#Different cut offs of elevation 
elev_0<- reclassify(elevation_mask, c(0,500, 1, 500, Inf, NA))
elev_500<- reclassify(elevation_mask, c(0,500, NA, 500, 1000, 1, 1000, Inf, NA))
elev_1000<- reclassify(elevation_mask, c(0,1000, NA, 1000, 1500, 1, 1500, Inf, NA))
elev_1500<- reclassify(elevation_mask, c(0,1500, NA, 1500, Inf, 1))
elev_high<- reclassify(elevation2_mask, c(0,399, NA))

#---------------------------------------------------------------------------------------
# Preparing Raster Staks:
#---------------------------------------------------------------------------------------
#Rain
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/precipitation", 
                       pattern='.tif$', all.files=TRUE, full.names=TRUE)
rastlist7579 <- rastlist[169:228]

rainStack <- stack(rastlist)
rainStack <- crop(rainStack, slvShp_sp)
rainMean<-raster::calc(rainStack, fun=mean, na.rm = T)
#rainMean <- stackApply(rainStack, indices =  rep(1,nlayers(rainStack)), fun = "mean", na.rm = T)
rainSd <- raster::calc(rainStack, fun=sd, na.rm = T)
rainMean_mask<-mask(rainMean ,slvShp_sp)
rainSd_mask<-mask(rainSd ,slvShp_sp)

rainStack7579 <- stack(rastlist7579)
rainStack7579 <- crop(rainStack7579, slvShp_sp)
rainMean7579 <- raster::calc(rainStack7579, fun=mean, na.rm = T)
rainMean_mask7579<-mask(rainMean7579 ,slvShp_sp)

rain_z_mask=(rainMean_mask7579-rainMean_mask)/rainSd_mask

#Maxtemp
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/temperature/maxtemp", 
                       pattern='.tif$', all.files=TRUE, full.names=TRUE)
rastlist7579 <- rastlist[169:228]

maxtempStack <- stack(rastlist)
maxtempStack <- crop(maxtempStack, slvShp_sp)
maxtempMean <- raster::calc(maxtempStack, fun=mean, na.rm = T)
maxtempSd <- raster::calc(maxtempStack, fun=sd, na.rm = T)
maxtempMean_mask<-mask(maxtempMean,slvShp_sp)
maxtempSd_mask<-mask(maxtempSd,slvShp_sp)

maxtempStack7579 <- stack(rastlist7579)
maxtempStack7579 <- crop(maxtempStack7579, slvShp_sp)
maxtempMean7579 <- raster::calc(maxtempStack7579, fun=mean, na.rm = T)
maxtempMean_mask7579<-mask(maxtempMean7579 ,slvShp_sp)

maxtemp_z_mask=(maxtempMean_mask7579-maxtempMean_mask)/maxtempSd_mask

#Mintemp
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/temperature/mintemp", 
                       pattern='.tif$', all.files=TRUE, full.names=TRUE)
rastlist7579 <- rastlist[169:228]

mintempStack <- stack(rastlist)
mintempStack <- crop(mintempStack, slvShp_sp)
mintempMean <- raster::calc(mintempStack, fun=mean, na.rm = T)
mintempSd <- raster::calc(mintempStack, fun=sd, na.rm = T)
mintempMean_mask<-mask(mintempMean,slvShp_sp)
mintempSd_mask<-mask(mintempSd,slvShp_sp)

mintempStack7579 <- stack(rastlist7579)
mintempStack7579 <- crop(mintempStack7579, slvShp_sp)
mintempMean7579 <- raster::calc(mintempStack7579, fun=mean, na.rm = T)
mintempMean_mask7579<-mask(mintempMean7579 ,slvShp_sp)

mintemp_z_mask=(mintempMean_mask7579-mintempMean_mask)/mintempSd_mask

#Bean
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Agro-climatic yield/Bean", 
                       pattern='.asc$', all.files=TRUE, full.names=TRUE)
rastlist6179 <- rastlist[1:19]
beanStack6179 <- stack(rastlist6179)
beanStack6179 <- crop(beanStack6179, slvShp_sp)
beanMean6179 <- raster::calc(beanStack6179, fun=mean, na.rm = T)
beanMean6179_mask<-mask(beanMean6179 ,slvShp_sp)

#Coffee 
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Agro-climatic yield/Coffee", 
                       pattern='.asc$', all.files=TRUE, full.names=TRUE)
rastlist6179 <- rastlist[1:19]
coffeeStack6179 <- stack(rastlist6179)
coffeeStack6179 <- crop(coffeeStack6179, slvShp_sp)
coffeeMean6179 <- raster::calc(coffeeStack6179, fun=mean, na.rm = T)
coffeeMean6179_mask<-mask(coffeeMean6179 ,slvShp_sp)

#Cotton
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Agro-climatic yield/Cotton", 
                       pattern='.asc$', all.files=TRUE, full.names=TRUE)
rastlist6179 <- rastlist[1:19]
cottonStack6179 <- stack(rastlist6179)
cottonStack6179 <- crop(cottonStack6179, slvShp_sp)
cottonMean6179 <- raster::calc(cottonStack6179, fun=mean, na.rm = T)
cottonMean6179_mask<-mask(cottonMean6179 ,slvShp_sp)

#Maize
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Agro-climatic yield/Maize", 
                       pattern='.asc$', all.files=TRUE, full.names=TRUE)
rastlist6179 <- rastlist[1:19]
maizeStack6179 <- stack(rastlist6179)
maizeStack6179 <- crop(maizeStack6179, slvShp_sp)
maizeMean6179 <- raster::calc(maizeStack6179, fun=mean, na.rm = T)
maizeMean6179_mask<-mask(maizeMean6179 ,slvShp_sp)

#Rice
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Agro-climatic yield/Rice-wetland", 
                       pattern='.asc$', all.files=TRUE, full.names=TRUE)
rastlist6179 <- rastlist[1:19]
riceStack6179 <- stack(rastlist6179)
riceStack6179 <- crop(riceStack6179, slvShp_sp)
riceMean6179 <- raster::calc(riceStack6179, fun=mean, na.rm = T)
riceMean6179_mask<-mask(riceMean6179 ,slvShp_sp)

#Sugarcane
rastlist <- list.files(path = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Agro-climatic yield/Sugarcane", 
                       pattern='.asc$', all.files=TRUE, full.names=TRUE)
rastlist6179 <- rastlist[1:19]
sugarcaneStack6179 <- stack(rastlist6179)
sugarcaneStack6179 <- crop(sugarcaneStack6179, slvShp_sp)
sugarcaneMean6179 <- raster::calc(sugarcaneStack6179, fun=mean, na.rm = T)
sugarcaneMean6179_mask <-mask(sugarcaneMean6179 ,slvShp_sp)


#---------------------------------------------------------------------------------------
## AVERAGING RASTERS BY SEGMENT LEVEL:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info1<-slvShp_segm

#Extracting mean
slvShp_segm_info1$nl <- exact_extract(nl13_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$elev <- exact_extract(elevation_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$elev2 <- exact_extract(elevation2, slvShp_segm_info1, 'mean')
slvShp_segm_info1$slope <- exact_extract(slope, slvShp_segm_info1, 'mean')
slvShp_segm_info1$rugged <- exact_extract(ruggedness, slvShp_segm_info1, 'mean')
slvShp_segm_info1$cocoa <- exact_extract(cocoa_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$coffee <- exact_extract(coffee_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$cotton <- exact_extract(cotton_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$drice <- exact_extract(drice_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$maize <- exact_extract(maize_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$bean <- exact_extract(bean2_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$sugarcane <- exact_extract(sugarcane_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$wrice <- exact_extract(wrice_crop, slvShp_segm_info1, 'mean')
slvShp_segm_info1$flow <- exact_extract(flow, slvShp_segm_info1, 'mean')
slvShp_segm_info1$rain <- exact_extract(rainMean_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$rainz <- exact_extract(rain_z_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$maxtemp <- exact_extract(maxtempMean_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$mintemp <- exact_extract(mintempMean_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$maxtempz <- exact_extract(maxtemp_z_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$mintempz <- exact_extract(mintemp_z_mask, slvShp_segm_info1, 'mean')

slvShp_segm_info1$bean79 <- exact_extract(beanMean6179_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$coffee79 <- exact_extract(coffeeMean6179_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$cotton79 <- exact_extract(cottonMean6179_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$maize79 <- exact_extract(maizeMean6179_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$rice79 <- exact_extract(riceMean6179_mask, slvShp_segm_info1, 'mean')
slvShp_segm_info1$sugarcane79 <- exact_extract(sugarcaneMean6179_mask, slvShp_segm_info1, 'mean')

#Extracting sum
slvShp_segm_info1$sum_dhydro <- exact_extract(dhydro, slvShp_segm_info1, 'sum')
slvShp_segm_info1$sum_kmhydro <- exact_extract(kmhydro, slvShp_segm_info1, 'sum')

#Extracting weighted mean
slvShp_segm_info1$wmean_nl <- exact_extract(nl13_mask, slvShp_segm_info1, 'weighted_mean', weights=area(nl13_mask))

#High elevation segments only
slvShp_segm_info1<-mutate(slvShp_segm_info1, high_elev=elev2)
slvShp_segm_info1$high_elev[slvShp_segm_info1$high_elev < 200] <-NA


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info2<-slvShp_segm_info1

#Calculating centroid of segments
slvShp_segm_centroid <-st_centroid(slvShp_segm)

#Extracting coordinates as matrix for future use
segm_centroid_coords <- do.call(rbind, st_geometry(slvShp_segm_centroid)) %>% 
  as_tibble() %>% setNames(c("lon","lat"))
segm_centroid_coords <- segm_centroid_coords %>% as.data.frame() %>%
  data.matrix()

#Calculating the minimum distance of each segment to the FMLN zones 
slvShp_segm_info2$dist_control<-as.numeric(st_distance(slvShp_segm, control_line))
#slvShp_segm_info2$dist_disputa<-as.numeric(st_distance(slvShp_segm, disputa_line))

slvShp_segm_info2$dist_control2<-as.numeric(st_distance(slvShp_segm_centroid, control_line))
#slvShp_segm_info2$dist_disputa2<-as.numeric(st_distance(slvShp_segm_centroid, disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
slvShp_segm_info2 <- mutate(slvShp_segm_info2, within_control=as.numeric(st_intersects(slvShp_segm, controlShp, sparse = FALSE)))
                            

slvShp_segm_info2 <- mutate(slvShp_segm_info2, within_control2=as.numeric(st_within(slvShp_segm_centroid, controlShp, sparse = FALSE)))

#Creating indicators for whether the segment has a river, lake or road, comms
slvShp_segm_info2 <- mutate(slvShp_segm_info2, lake_int=as.numeric(st_intersects(slvShp_segm, lakeShp, sparse = FALSE)), 
                            riv1_int=as.numeric(st_intersects(slvShp_segm, river1Shp, sparse = FALSE)),
                            riv2_int=as.numeric(st_intersects(slvShp_segm, river2Shp, sparse = FALSE)), 
                            rail_int=as.numeric(st_intersects(slvShp_segm, railShp, sparse = FALSE)),
                            road_int=as.numeric(st_intersects(slvShp_segm, roadShp, sparse = FALSE)),
                            road14_int=as.numeric(st_intersects(slvShp_segm, roadShp14, sparse = FALSE)),
                            comms45_int=as.numeric(st_intersects(slvShp_segm, comms45, sparse = FALSE)))

#Creating indicators for whether the segment is within a cultivated or a high population density area in 1980
slvShp_segm_info2 <- mutate(slvShp_segm_info2, highpopdens=as.numeric(st_intersects(slvShp_segm, popdens80, sparse = FALSE)),
                            cultivated=as.numeric(st_intersects(slvShp_segm, grown80, sparse = FALSE)),
                            pop_w=as.numeric(st_within(slvShp_segm, popdens80, sparse = FALSE)),
                            grown_w=as.numeric(st_within(slvShp_segm, grown80, sparse = FALSE)),
                            maxpopdens=as.numeric(st_intersects(slvShp_segm, highpopdens80, sparse = FALSE)),
                            maxpop_w=as.numeric(st_within(slvShp_segm, highpopdens80, sparse = FALSE)))

#Calculating road length in each census tract for 2014
int <- sf::st_intersection(st_make_valid(roadShp14), st_make_valid(slvShp_segm)) %>% 
  dplyr::mutate(len = sf::st_length(geometry))
int2 <- int[, c('SEG_ID', 'len')]
out <- dplyr::group_by(int2, SEG_ID) %>%
  dplyr::summarize(len_road = sum(len)) %>%
  as.data.frame()
out$len_road <- as.numeric(out$len_road)
out <- out[, c('SEG_ID', 'len_road')]

slvShp_segm_info2 <- left_join(slvShp_segm_info2, out, by="SEG_ID")
slvShp_segm_info2 <- mutate(slvShp_segm_info2, road_dens=len_road/(1000*AREA_KM2))

#Subseting to check the bordering segment 
y1<-subset(slvShp_segm_info2, dist_control==0)
y2<-subset(slvShp_segm_info2, dist_control2<800 & within_control2==1)

#Distance to capital and coast 
slvShp_segm_info2$dist_coast<-as.numeric(st_distance(slvShp_segm, coastSimp_sf))
slvShp_segm_info2$dist_capital<-as.numeric(st_distance(slvShp_segm, capital_sf))
slvShp_segm_info2$dist_depto<-as.numeric(st_distance(slvShp_segm, deptoLine, by_element = TRUE))
slvShp_segm_info2$dist_muni<-as.numeric(st_distance(slvShp_segm, muniLine, by_element = TRUE))

#Distance to closest parroquia 
distBrk<-st_distance(slvShp_segm, parr80_sf, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info2$dist_parr80<-distMin

#Distance to closest communicaion line 
distBrk<-st_distance(slvShp_segm, comms45, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info2$dist_comms<-distMin

#Distance to closest city in 1945 
distBrk<-st_distance(slvShp_segm, cities45, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info2$dist_city45<-distMin

#Calculating comms lines' length in each census tract for 2014
int = st_intersection(st_make_valid(comms45), st_make_valid(slvShp_segm)) %>% 
  dplyr::mutate(len = sf::st_length(geometry))
int2 <- int[, c('SEG_ID', 'len')]
out <- dplyr::group_by(int2, SEG_ID) %>%
  dplyr::summarize(len_comms = sum(len)) %>%
  as.data.frame()
out$len_comms <- as.numeric(out$len_comms)
out <- out[, c('SEG_ID', 'len_comms')]

slvShp_segm_info2 <- left_join(slvShp_segm_info2, out, by="SEG_ID")
slvShp_segm_info2 <- mutate(slvShp_segm_info2, comms_dens=len_comms/(1000*AREA_KM2))


#---------------------------------------------------------------------------------------
## COUNTING OBJECTS OF INTEREST WITHIN SEGMENTS:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info3<-slvShp_segm_info2

#Counting number of hospitals per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = hospitales_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_hosp'

#Counting number of schools per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = schools_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n(), matricula=sum(matricula))

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_sch'

#Counting number of parroquias per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = parroquias_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3 <-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_parr'

#Counting number of parroquias before 1980 per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = parr80_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_pa80'

#Counting number of parroquias franciscanas per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = francis_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_fran'

#Counting number of homicides per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = homicides_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_homicides'

intersection <- st_intersection(x = slvShp_segm_info3, y = homicides_gang_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_homicides_gangs'

#Counting number of cities in 1945 per segment 
intersection <- st_intersection(x = slvShp_segm_info3, y = cities45)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info3<-st_join(slvShp_segm_info3,int_result)
slvShp_segm_info3 <- subset(slvShp_segm_info3, select = -SEG_ID.y)
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info3)[names(slvShp_segm_info3) == 'n'] <- 'n_cities45'


#---------------------------------------------------------------------------------------
## INCLUDING THE LINE BREAK FE:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info<-slvShp_segm_info3

#Sampling points int the borders for the RDD
set.seed(1234)

control_line_sample <- st_sample(control_line, 1000, type="regular")
pnt_controlBrk_1000 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 400, type="regular")
pnt_controlBrk_400 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_controlBrk_1000, by_element = FALSE)

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
distBrk<-st_distance(slvShp_segm_info, pnt_controlBrk_400, by_element = FALSE)

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
save.image(file='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/temp/segm_info_nowater_cntrl82.RData')

# Converting from sf to sp object
slvShp_segm_info_sp_v2 <- as(slvShp_segm_info, Class='Spatial')

#Exporting the all data shapefile
#writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="slvShp_segm_info_sp_onu_91", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="slvShp_segm_nowater_info_sp_82", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#---------------------------------------------------------------------------------------
## EXPORTING THE ADDITIONAL SHAPEFILES:
#
#---------------------------------------------------------------------------------------
#Exporting FE breaks shapefiles
pnt_controlBrk_400_sp <- as(pnt_controlBrk_400, Class='Spatial')
pnt_controlBrk_400_sp <-as(pnt_controlBrk_400_sp,"SpatialPointsDataFrame")

pnt_controlBrk_1000_sp <- as(pnt_controlBrk_1000, Class='Spatial')
pnt_controlBrk_1000_sp <-as(pnt_controlBrk_1000_sp,"SpatialPointsDataFrame")

writeOGR(obj=pnt_controlBrk_400_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="pnt_controlBrk_400", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=pnt_controlBrk_1000_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="pnt_controlBrk_1000", driver="ESRI Shapefile",  overwrite_layer=TRUE)



#END....
