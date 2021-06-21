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
slvShp_segm <- st_read(dsn='censo2007/shapefiles', layer = "DIGESTYC_Segmentos2007")
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
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Importing FMLN disputed zones
disputaShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_fmln_onu_91")
st_crs(disputaShp) <- slv_crs

#Converting polygons to polylines
control_line <- st_cast(controlShp,"MULTILINESTRING")
expansion_line <- st_cast(expansionShp,"MULTILINESTRING")
disputa_line <- st_cast(disputaShp,"MULTILINESTRING")

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
elevation2<-resample(elevation2, elevation, method="bilinear")
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
slvShp_segm_info2$dist_disputa<-as.numeric(st_distance(slvShp_segm, disputa_line))

slvShp_segm_info2$dist_control2<-as.numeric(st_distance(slvShp_segm_centroid, control_line))
slvShp_segm_info2$dist_disputa2<-as.numeric(st_distance(slvShp_segm_centroid, disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
slvShp_segm_info2 <- mutate(slvShp_segm_info2, within_control=as.numeric(st_intersects(slvShp_segm, controlShp, sparse = FALSE)), 
                          within_disputa=as.numeric(st_intersects(slvShp_segm, disputaShp, sparse = FALSE)))

slvShp_segm_info2 <- mutate(slvShp_segm_info2, within_control2=as.numeric(st_within(slvShp_segm_centroid, controlShp, sparse = FALSE)), 
                          within_disputa2=as.numeric(st_within(slvShp_segm_centroid, disputaShp, sparse = FALSE)))

#Creating indicators for whether the segment has a river, lake or road
slvShp_segm_info2 <- mutate(slvShp_segm_info2, lake_int=as.numeric(st_intersects(slvShp_segm, lakeShp, sparse = FALSE)), 
                          riv1_int=as.numeric(st_intersects(slvShp_segm, river1Shp, sparse = FALSE)),
                          riv2_int=as.numeric(st_intersects(slvShp_segm, river2Shp, sparse = FALSE)), 
                          rail_int=as.numeric(st_intersects(slvShp_segm, railShp, sparse = FALSE)),
                          road_int=as.numeric(st_intersects(slvShp_segm, roadShp, sparse = FALSE)))

#Subseting to check the bordering segment 
y1<-subset(slvShp_segm_info2, dist_control==0)
y2<-subset(slvShp_segm_info2, dist_control2<800 & within_control2==1)

#Distance to capital and coast 
slvShp_segm_info2$dist_coast<-as.numeric(st_distance(slvShp_segm, coastSimp_sf))
slvShp_segm_info2$dist_capital<-as.numeric(st_distance(slvShp_segm, capital_sf))
slvShp_segm_info2$dist_depto<-as.numeric(st_distance(slvShp_segm, deptoLine, by_element = TRUE))
slvShp_segm_info2$dist_muni<-as.numeric(st_distance(slvShp_segm, muniLine, by_element = TRUE))


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


#---------------------------------------------------------------------------------------
## INCLUDING THE LINE BREAK FE:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info<-slvShp_segm_info3

#Sampling points int the borders for the RDD
set.seed(1234)

disputa_line_sample <- st_sample(disputa_line, 1000, type="regular")
pnt_disputaBrk_1000 <- st_cast(disputa_line_sample, "POINT")

disputa_line_sample <- st_sample(disputa_line, 400, type="regular")
pnt_disputaBrk_400 <- st_cast(disputa_line_sample, "POINT")

disputa_line_sample <- st_sample(disputa_line, 200, type="regular")
pnt_disputaBrk_200 <- st_cast(disputa_line_sample, "POINT")

disputa_line_sample <- st_sample(disputa_line, 100, type="regular")
pnt_disputaBrk_100 <- st_cast(disputa_line_sample, "POINT")

disputa_line_sample <- st_sample(disputa_line, 50, type="regular")
pnt_disputaBrk_50 <- st_cast(disputa_line_sample, "POINT")

disputa_line_sample <- st_sample(disputa_line, 25, type="regular")
pnt_disputaBrk_25 <- st_cast(disputa_line_sample, "POINT")

disputa_line_sample <- st_sample(disputa_line, 10, type="regular")
pnt_disputaBrk_10 <- st_cast(disputa_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 1000, type="regular")
pnt_controlBrk_1000 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 400, type="regular")
pnt_controlBrk_400 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 200, type="regular")
pnt_controlBrk_200 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 100, type="regular")
pnt_controlBrk_100 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 50, type="regular")
pnt_controlBrk_50 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_1000, by_element = FALSE)

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
slvShp_segm_info$dist_brk1000<-distMin
slvShp_segm_info$brkfe1000<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_400, by_element = FALSE)

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
slvShp_segm_info$dist_brk400<-distMin
slvShp_segm_info$brkfe400<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_200, by_element = FALSE)

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
slvShp_segm_info$dist_brk200<-distMin
slvShp_segm_info$brkfe200<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_100, by_element = FALSE)

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
slvShp_segm_info$dist_brk100<-distMin
slvShp_segm_info$brkfe100<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_50, by_element = FALSE)

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
slvShp_segm_info$dist_brk50<-distMin
slvShp_segm_info$brkfe50<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_25, by_element = FALSE)

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
slvShp_segm_info$dist_brk25<-distMin
slvShp_segm_info$brkfe25<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_disputaBrk_10, by_element = FALSE)

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
slvShp_segm_info$dist_brk10<-distMin
slvShp_segm_info$brkfe10<-brkIndexUnique[, 'col']

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

#Calculating the distance of each census segment to control border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_controlBrk_200, by_element = FALSE)

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
slvShp_segm_info$cntrldist_brk200<-distMin
slvShp_segm_info$cntrlbrkfe200<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_controlBrk_100, by_element = FALSE)

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
slvShp_segm_info$cntrldist_brk100<-distMin
slvShp_segm_info$cntrlbrkfe100<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(slvShp_segm_info, pnt_controlBrk_50, by_element = FALSE)

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
slvShp_segm_info$cntrldist_brk50<-distMin
slvShp_segm_info$cntrlbrkfe50<-brkIndexUnique[, 'col']


#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
slvShp_segm_info_sp_v2 <- as(slvShp_segm_info, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="slvShp_segm_info_sp_onu_91", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#---------------------------------------------------------------------------------------
## EXPORTING THE ADDITIONAL SHAPEFILES:
#
#---------------------------------------------------------------------------------------
#Exporting FE breaks shapefiles
pnt_controlBrk_400_sp <- as(pnt_controlBrk_400, Class='Spatial')
pnt_controlBrk_400_sp <-as(pnt_controlBrk_400_sp,"SpatialPointsDataFrame")

pnt_controlBrk_1000_sp <- as(pnt_controlBrk_1000, Class='Spatial')
pnt_controlBrk_1000_sp <-as(pnt_controlBrk_1000_sp,"SpatialPointsDataFrame")

writeOGR(obj=pnt_controlBrk_400_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="pnt_controlBrk_400", driver="ESRI Shapefile",  overwrite_layer=TRUE)
writeOGR(obj=pnt_controlBrk_1000_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="pnt_controlBrk_1000", driver="ESRI Shapefile",  overwrite_layer=TRUE)













#END
