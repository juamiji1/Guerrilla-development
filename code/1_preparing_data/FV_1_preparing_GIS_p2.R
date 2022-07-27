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

#---------------------------------------------------------------------------------------
# Importing other features:
#---------------------------------------------------------------------------------------
coopShp <- st_read(dsn = "gis/cooperatives", layer = "cooperatives")
st_crs(coopShp)<- slv_crs

#Importing conflict data location
events <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/edh_muertes_guerra_civil/events_XY.csv")
events_sf <- st_as_sf(events, coords = c("longitud", "latitud"), crs = slv_crs)

victims <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/edh_muertes_guerra_civil/victims_XY.csv")
victims_sf <- st_as_sf(victims, coords = c("longitud", "latitud"), crs = slv_crs)

#Importing location of hospitals in 2015
hospitales <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/minsalud/MINSAL_0.csv")
hospitales_sf <- st_as_sf(hospitales, coords = c("LON", "LAT"), crs = slv_crs)

#Importing location of schools in ???year
schools <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/mineduc/matricula_coords_2007.csv",header=TRUE)
names(schools)[1] <- 'codigoce'
schools <- na.omit(schools) 
schools_sf <- st_as_sf(schools, coords = c("x", "y"), crs = slv_crs)

schools80 <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/mineduc/escuelas_before_80.csv",header=TRUE)
names(schools80)[1] <- 'codigoce'
schools80 <- na.omit(schools80) 
schools80_sf <- st_as_sf(schools80, coords = c("x", "y"), crs = slv_crs)


#---------------------------------------------------------------------------------------
## PREPARING RASTERS FILES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Raster Layers:
#---------------------------------------------------------------------------------------
#Importing the rasters 
bean <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-yield/pulses/data.asc')
coffee <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-yield/coffee/data.asc')
cotton <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-yield/cotton/data.asc')
maize <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-yield/maize/data.asc')
rice <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-yield/rice/data.asc')
sugar <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-yield/sugarcane/data.asc')

plbean <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-production/pulses/data.asc')
plcoffee <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-production/coffee/data.asc')
plmaize <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-production/maize/data.asc')
plsugar <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Actual-production/sugarcane/data.asc')

pbean <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Production-gap/pulses/data.asc')
pcotton <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Production-gap/cotton/data.asc')
pmaize <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Production-gap/maize/data.asc')
price <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Production-gap/rice/data.asc')
psugar <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Production-gap/sugarcane/data.asc')

hbean <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Harvest-area/pulses/data.asc')
hmaize <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Harvest-area/maize/data.asc')
hsugar <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Harvest-area/sugarcane/data.asc')
hcoffee <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Harvest-area/coffee/data.asc')

sibean <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/SI6190/suHr_phb.tif')
simaize <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/SI6190/suHr_mze.tif')
sisugar <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/SI6190/suHr_suc.tif')
sicoffee <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/SI6190/suHr_cof.tif')

lbean <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/VSSMS/sx2Hr_phb.tif')
lmaize <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/VSSMS/sx2Hr_mze.tif')
lsugar <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/VSSMS/sx2Hr_suc.tif')
lcoffee <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/GAEZv4/VSSMS/sx2Lr_cof.tif')

#Importing the rasters 
nl92 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F101992.v4b.avg_lights_x_pct.tif')
nl93 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F101993.v4b.avg_lights_x_pct.tif')
nl94 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F121994.v4b.avg_lights_x_pct.tif')
nl95 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F121995.v4b.avg_lights_x_pct.tif')
nl96 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F121996.v4b.avg_lights_x_pct.tif')
nl97 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F141997.v4b.avg_lights_x_pct.tif')
nl98 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F141998.v4b.avg_lights_x_pct.tif')
nl99 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F141999.v4b.avg_lights_x_pct.tif')
nl00 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F152000.v4b.avg_lights_x_pct.tif')
nl01 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F152001.v4b.avg_lights_x_pct.tif')
nl02 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F152002.v4b.avg_lights_x_pct.tif')
nl03 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F152003.v4b.avg_lights_x_pct.tif')
nl04 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F162004.v4b.avg_lights_x_pct.tif')
nl05 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F162005.v4b.avg_lights_x_pct.tif')
nl06 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F162006.v4b.avg_lights_x_pct.tif')
nl07 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F162007.v4b.avg_lights_x_pct.tif')
nl08 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F162008.v4b.avg_lights_x_pct.tif')
nl09 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F162009.v4b.avg_lights_x_pct.tif')
nl10 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F182010.v4c.avg_lights_x_pct.tif')
nl11 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F182011.v4c.avg_lights_x_pct.tif')
nl12 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F182012.v4c.avg_lights_x_pct.tif')
nl13 <- raster('C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw-yearly/F182013.v4c.avg_lights_x_pct.tif')

nl92_mask <- mask(crop(nl92, slvShp_sp), mask=slvShp_sp)
nl93_mask <- mask(crop(nl93, slvShp_sp), mask=slvShp_sp)
nl94_mask <- mask(crop(nl94, slvShp_sp), mask=slvShp_sp)
nl95_mask <- mask(crop(nl95, slvShp_sp), mask=slvShp_sp)
nl96_mask <- mask(crop(nl96, slvShp_sp), mask=slvShp_sp)
nl97_mask <- mask(crop(nl97, slvShp_sp), mask=slvShp_sp)
nl98_mask <- mask(crop(nl98, slvShp_sp), mask=slvShp_sp)
nl99_mask <- mask(crop(nl99, slvShp_sp), mask=slvShp_sp)
nl00_mask <- mask(crop(nl00, slvShp_sp), mask=slvShp_sp)
nl01_mask <- mask(crop(nl01, slvShp_sp), mask=slvShp_sp)
nl02_mask <- mask(crop(nl02, slvShp_sp), mask=slvShp_sp)
nl03_mask <- mask(crop(nl03, slvShp_sp), mask=slvShp_sp)
nl04_mask <- mask(crop(nl04, slvShp_sp), mask=slvShp_sp)
nl05_mask <- mask(crop(nl05, slvShp_sp), mask=slvShp_sp)
nl06_mask <- mask(crop(nl06, slvShp_sp), mask=slvShp_sp)
nl07_mask <- mask(crop(nl07, slvShp_sp), mask=slvShp_sp)
nl08_mask <- mask(crop(nl08, slvShp_sp), mask=slvShp_sp)
nl09_mask <- mask(crop(nl09, slvShp_sp), mask=slvShp_sp)
nl10_mask <- mask(crop(nl10, slvShp_sp), mask=slvShp_sp)
nl11_mask <- mask(crop(nl11, slvShp_sp), mask=slvShp_sp)
nl12_mask <- mask(crop(nl12, slvShp_sp), mask=slvShp_sp)
nl13_mask <- mask(crop(nl13, slvShp_sp), mask=slvShp_sp)

#Cropping raster to El Salvador square
bean_crop <- crop(bean, slvShp_sp)
coffee_crop <- crop(coffee, slvShp_sp)
cotton_crop <- crop(cotton, slvShp_sp)
maize_crop <- crop(maize, slvShp_sp)
rice_crop <- crop(rice, slvShp_sp)
sugar_crop <- crop(sugar, slvShp_sp)
pbean_crop <- crop(pbean, slvShp_sp)
pcotton_crop <- crop(pcotton, slvShp_sp)
pmaize_crop <- crop(pmaize, slvShp_sp)
price_crop <- crop(price, slvShp_sp)
psugar_crop <- crop(psugar, slvShp_sp)
hbean_crop <- crop(hbean, slvShp_sp)
hcoffee_crop <- crop(hcoffee, slvShp_sp)
hmaize_crop <- crop(hmaize, slvShp_sp)
hsugar_crop <- crop(hsugar, slvShp_sp)
plbean_crop <- crop(plbean, slvShp_sp)
plcoffee_crop <- crop(plcoffee, slvShp_sp)
plmaize_crop <- crop(plmaize, slvShp_sp)
plsugar_crop <- crop(plsugar, slvShp_sp)

sibean_crop <- crop(sibean, slvShp_sp)
sicoffee_crop <- crop(sicoffee, slvShp_sp)
simaize_crop <- crop(simaize, slvShp_sp)
sisugar_crop <- crop(sisugar, slvShp_sp)

lbean_crop <- crop(lbean, slvShp_sp)
lcoffee_crop <- crop(lcoffee, slvShp_sp)
lmaize_crop <- crop(lmaize, slvShp_sp)
lsugar_crop <- crop(lsugar, slvShp_sp)


#---------------------------------------------------------------------------------------
## AVERAGING RASTERS BY SEGMENT LEVEL:
#
#---------------------------------------------------------------------------------------
slvShp_segm_info1<-slvShp_segm

#Extracting mean
slvShp_segm_info1$bean05 <- exact_extract(bean_crop, slvShp_segm, 'mean')
slvShp_segm_info1$coffee05 <- exact_extract(coffee_crop, slvShp_segm, 'mean')
slvShp_segm_info1$cotton05 <- exact_extract(cotton_crop, slvShp_segm, 'mean')
slvShp_segm_info1$maize05 <- exact_extract(maize_crop, slvShp_segm, 'mean')
slvShp_segm_info1$rice05 <- exact_extract(rice_crop, slvShp_segm, 'mean')
slvShp_segm_info1$sugar05 <- exact_extract(sugar_crop, slvShp_segm, 'mean')

slvShp_segm_info1$pro_bean05 <- exact_extract(plbean_crop, slvShp_segm, 'mean')
slvShp_segm_info1$pro_maize05 <- exact_extract(plmaize_crop, slvShp_segm, 'mean')
slvShp_segm_info1$pro_sugar05 <- exact_extract(plsugar_crop, slvShp_segm, 'mean')
slvShp_segm_info1$pro_coffee05 <- exact_extract(plcoffee_crop, slvShp_segm, 'mean')

slvShp_segm_info1$gap_bean05 <- exact_extract(pbean_crop, slvShp_segm, 'mean')
slvShp_segm_info1$gap_cotton05 <- exact_extract(pcotton_crop, slvShp_segm, 'mean')
slvShp_segm_info1$gap_maize05 <- exact_extract(pmaize_crop, slvShp_segm, 'mean')
slvShp_segm_info1$gap_rice05 <- exact_extract(price_crop, slvShp_segm, 'mean')
slvShp_segm_info1$gap_sugar05 <- exact_extract(psugar_crop, slvShp_segm, 'mean')

slvShp_segm_info1$hbean05 <- exact_extract(hbean_crop, slvShp_segm, 'mean')
slvShp_segm_info1$hcoffee05 <- exact_extract(hcoffee_crop, slvShp_segm, 'mean')
slvShp_segm_info1$hmaize05 <- exact_extract(hmaize_crop, slvShp_segm, 'mean')
slvShp_segm_info1$hsugar05 <- exact_extract(hsugar_crop, slvShp_segm, 'mean')

slvShp_segm_info1$sibean <- exact_extract(sibean_crop, slvShp_segm, 'mean')
slvShp_segm_info1$sicoffee <- exact_extract(sicoffee_crop, slvShp_segm, 'mean')
slvShp_segm_info1$simaize <- exact_extract(simaize_crop, slvShp_segm, 'mean')
slvShp_segm_info1$sisugar <- exact_extract(sisugar_crop, slvShp_segm, 'mean')

slvShp_segm_info1$lbean <- exact_extract(lbean_crop, slvShp_segm, 'mean')
slvShp_segm_info1$lcoffee <- exact_extract(lcoffee_crop, slvShp_segm, 'mean')
slvShp_segm_info1$lmaize <- exact_extract(lmaize_crop, slvShp_segm, 'mean')
slvShp_segm_info1$lsugar <- exact_extract(lsugar_crop, slvShp_segm, 'mean')

slvShp_segm_info1$nl92_y <- exact_extract(nl92_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl93_y <- exact_extract(nl93_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl94_y <- exact_extract(nl94_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl95_y <- exact_extract(nl95_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl96_y <- exact_extract(nl96_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl97_y <- exact_extract(nl97_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl98_y <- exact_extract(nl98_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl99_y <- exact_extract(nl99_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl00_y <- exact_extract(nl00_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl01_y <- exact_extract(nl01_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl02_y <- exact_extract(nl02_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl03_y <- exact_extract(nl03_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl04_y <- exact_extract(nl04_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl05_y <- exact_extract(nl05_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl06_y <- exact_extract(nl06_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl07_y <- exact_extract(nl07_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl08_y <- exact_extract(nl08_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl09_y <- exact_extract(nl09_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl10_y <- exact_extract(nl10_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl11_y <- exact_extract(nl11_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl12_y <- exact_extract(nl12_mask, slvShp_segm, 'mean')
slvShp_segm_info1$nl13_y <- exact_extract(nl13_mask, slvShp_segm, 'mean')


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
#Distance to closest cooperative 
distBrk<-st_distance(slvShp_segm, coopShp, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_coop<-distMin

#Distance to closest hospital 
distBrk<-st_distance(slvShp_segm, hospitales_sf, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_hosp<-distMin

#Distance to closest school 
distBrk<-st_distance(slvShp_segm, schools_sf, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_schl<-distMin

distBrk<-st_distance(slvShp_segm, schools80_sf, by_element = FALSE)
distMatrix<-distBrk %>% as.data.frame() %>%
  data.matrix()
distMin<-rowMins(distMatrix)
slvShp_segm_info1$dist_schl80<-distMin

#Counting number of cooperatives per segment 
intersection <- st_intersection(x = slvShp_segm_info1, y = coopShp)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info1<-st_join(slvShp_segm_info1,int_result)
slvShp_segm_info1 <- subset(slvShp_segm_info1, select = -SEG_ID.y)
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'n'] <- 'n_coop'

#Counting number of events per segment 
intersection <- st_intersection(x = slvShp_segm_info1, y = events_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info1<-st_join(slvShp_segm_info1,int_result)
slvShp_segm_info1 <- subset(slvShp_segm_info1, select = -SEG_ID.y)
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'n'] <- 'n_events'

#Counting number of victims per segment 
intersection <- st_intersection(x = slvShp_segm_info1, y = victims_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info1<-st_join(slvShp_segm_info1,int_result)
slvShp_segm_info1 <- subset(slvShp_segm_info1, select = -SEG_ID.y)
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'n'] <- 'n_victims'

#Counting number of schools per segment 
intersection <- st_intersection(x = slvShp_segm_info1, y = schools_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(teachers=sum(docentes), high_skl1=sum(acreditado), high_skl2=sum(acreditado_more), high_skl3=sum(more_bachiller))

slvShp_segm_info1<-st_join(slvShp_segm_info1,int_result)
slvShp_segm_info1 <- subset(slvShp_segm_info1, select = -SEG_ID.y)
names(slvShp_segm_info1)[names(slvShp_segm_info1) == 'SEG_ID.x'] <- 'SEG_ID'


#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
slvShp_segm_info_sp <- as(slvShp_segm_info1, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=slvShp_segm_info_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="slvShp_segm_yield05", driver="ESRI Shapefile",  overwrite_layer=TRUE)
#slvShp_segm_info1 <- st_read(dsn = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer = "slvShp_segm_yield05")








#END
