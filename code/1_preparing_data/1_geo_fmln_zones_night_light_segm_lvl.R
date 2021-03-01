#--------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development 
# TOPIC: This file prepare the spatial data at the segment level 
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


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES OF FMLN ZONES:
#
#---------------------------------------------------------------------------------------
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

#Converting polygons to polylines
control_line <- st_cast(controlShp,"MULTILINESTRING")
expansion_line <- st_cast(expansionShp,"MULTILINESTRING")
disputa_line <- st_cast(disputaShp,"MULTILINESTRING")

#Importing El salvador shapefile of segments 
slvShp_segm <- st_read(dsn='censo2007/shapefiles', layer = "DIGESTYC_Segmentos2007")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#Transforming sf object to sp object 
slvShp_segm_sp <- as(slvShp_segm, Class='Spatial')
slvShp_sp <- as(slvShp, Class='Spatial')

#Importing location of hospitals in 2015
hospitales <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/minsalud/MINSAL_0.csv")
hospitales_sf <- st_as_sf(hospitales, coords = c("LON", "LAT"), crs = slv_crs)

#Importing location of schools in ???year
schools <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/mineduc/matricula_coords_2007.csv",header=TRUE)
names(schools)[1] <- 'codigoce'
schools <- na.omit(schools) 
schools_sf <- st_as_sf(schools, coords = c("x", "y"), crs = slv_crs)


#---------------------------------------------------------------------------------------
## PREPARING RASTERS (NLD, altitude, cacao):
#
#---------------------------------------------------------------------------------------
#Importing the rasters 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
elevation <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
cacao <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Cacao/res02_crav6190h_coco000a_yld.tif')
bean <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Phaseolus bean/res02_crav6190h_bean000a_yld.tif')

#Aligning the CRS for all rasters 
nl_crs <- crs(nl13)
elevation <- projectRaster(elevation, crs=nl_crs)
cacao <- projectRaster(cacao, crs=nl_crs)
bean <- projectRaster(bean, crs=nl_crs)

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)
elevation_crop <- crop(elevation, slvShp_sp)
elevation_mask <- mask(elevation_crop, mask=slvShp_sp)
cacao_crop <- crop(cacao, slvShp_sp)
cacao_mask <- mask(cacao_crop, mask=slvShp_sp)
bean_crop <- crop(bean, slvShp_sp)
bean_mask <- mask(bean_crop, mask=slvShp_sp)

#Not considering zeros 
nl13_mask_zeros <- reclassify(nl13_mask, c(-Inf,0, NA))

#Different cut offs of elevation 
elev_0<- reclassify(elevation_mask, c(0,500, 1, 500, Inf, NA))
elev_500<- reclassify(elevation_mask, c(0,500, NA, 500, 1000, 1, 1000, Inf, NA))
elev_1000<- reclassify(elevation_mask, c(0,1000, NA, 1000, 1500, 1, 1500, Inf, NA))
elev_1500<- reclassify(elevation_mask, c(0,1500, NA, 1500, Inf, 1))

#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
#Calculating centroid of segments
slvShp_segm_centroid <-st_centroid(slvShp_segm)

#Calculating the minimum distance of each segment to the FMLN zones 
slvShp_segm_int <- slvShp_segm

slvShp_segm_int$dist_control<-as.numeric(st_distance(slvShp_segm, control_line))
slvShp_segm_int$dist_expansion<-as.numeric(st_distance(slvShp_segm, expansion_line))
slvShp_segm_int$dist_disputa<-as.numeric(st_distance(slvShp_segm, disputa_line))

slvShp_segm_int$dist_control2<-as.numeric(st_distance(slvShp_segm_centroid, control_line))
slvShp_segm_int$dist_expansion2<-as.numeric(st_distance(slvShp_segm_centroid, expansion_line))
slvShp_segm_int$dist_disputa2<-as.numeric(st_distance(slvShp_segm_centroid, disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
slvShp_segm_int <- mutate(slvShp_segm_int, within_control=as.numeric(st_intersects(slvShp_segm, controlShp, sparse = FALSE)), 
                          within_expansion=as.numeric(st_intersects(slvShp_segm, expansionShp, sparse = FALSE)),
                          within_disputa=as.numeric(st_intersects(slvShp_segm, disputaShp, sparse = FALSE)))

slvShp_segm_int <- mutate(slvShp_segm_int, within_control2=as.numeric(st_within(slvShp_segm_centroid, controlShp, sparse = FALSE)), 
                          within_expansion2=as.numeric(st_within(slvShp_segm_centroid, expansionShp, sparse = FALSE)),
                          within_disputa2=as.numeric(st_within(slvShp_segm_centroid, disputaShp, sparse = FALSE)))

#Creating indicators for whether the segment is within each FMLN zone
slvShp_segm_int <- mutate(slvShp_segm_int, lake_int=as.numeric(st_intersects(slvShp_segm, lakeShp, sparse = FALSE)), 
                          riv1_int=as.numeric(st_intersects(slvShp_segm, river1Shp, sparse = FALSE)),
                          riv2_int=as.numeric(st_intersects(slvShp_segm, river2Shp, sparse = FALSE)), 
                          rail_int=as.numeric(st_intersects(slvShp_segm, railShp, sparse = FALSE)),
                          road_int=as.numeric(st_intersects(slvShp_segm, roadShp, sparse = FALSE)))

#Subseting to check the bordering segment 
y1<-subset(slvShp_segm_int, dist_control==0)
y2<-subset(slvShp_segm_int, dist_control2<800 & within_control2==1)

# Converting from sf to sp object
slvShp_segm_sp <- as(slvShp_segm_int, Class='Spatial')

#---------------------------------------------------------------------------------------
## AVERAGING RASTERS BY SEGMENT LEVEL:
#
#---------------------------------------------------------------------------------------
detach(package:tidyr)

slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[34] <- 'mean_nl'

slvShp_segm_info_sp <- extract(elevation_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[35] <- 'mean_elev'

slvShp_segm_info_sp <- extract(cacao_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[36] <- 'mean_cacao'

slvShp_segm_info_sp <- extract(bean_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[37] <- 'mean_bean'

#Weighted mean of night light pixel 
slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE, weights=TRUE)
names(slvShp_segm_info_sp)[38] <- 'wmean_nl1'

#Not taking into account the zeros 
slvShp_segm_info_sp <- extract(nl13_mask_zeros, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[39] <- 'mean_nl_z'

slvShp_segm_info_sp <- extract(nl13_mask_zeros, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE, weights=TRUE)
names(slvShp_segm_info_sp)[40] <- 'wmean_nl_z'

#Count of different elevations
slvShp_segm_info_sp <- extract(elev_0, slvShp_segm_info_sp, fun=sum, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[41] <- 'sum_elev_1'

slvShp_segm_info_sp <- extract(elev_500, slvShp_segm_info_sp, fun=sum, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[42] <- 'sum_elev_2'

slvShp_segm_info_sp <- extract(elev_1000, slvShp_segm_info_sp, fun=sum, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[43] <- 'sum_elev_3'

slvShp_segm_info_sp <- extract(elev_1500, slvShp_segm_info_sp, fun=sum, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[44] <- 'sum_elev_4'

#Transforming sp object to sf object 
slvShp_segm_info <- st_as_sf(slvShp_segm_info_sp, coords = c('y', 'x'))

slvShp_segm_info$mean_nl2 <- exact_extract(nl13_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$mean_elev2 <- exact_extract(elevation_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$wmean_nl2 <- exact_extract(nl13_mask, slvShp_segm_info, 'weighted_mean', weights=area(nl13_mask))
slvShp_segm_info$wmean_elev2 <- exact_extract(elevation_mask, slvShp_segm_info, 'weighted_mean', weights=area(elevation_mask))

#---------------------------------------------------------------------------------------
## COUNTING OBJECTS OF INTEREST WITHIN SEGMENTS:
#
#---------------------------------------------------------------------------------------
#Counting number of hospitals per segment 
intersection <- st_intersection(x = slvShp_segm_info, y = hospitales_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  count()

slvShp_segm_info<-st_join(slvShp_segm_info,int_result)
slvShp_segm_info <- subset(slvShp_segm_info, select = -SEG_ID.y)
names(slvShp_segm_info)[names(slvShp_segm_info) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info)[names(slvShp_segm_info) == 'n'] <- 'n_hosp'

#Counting number of schools per segment 
intersection <- st_intersection(x = slvShp_segm_info, y = schools_sf)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  summarise(n=n(), matricula=sum(matricula))

slvShp_segm_info<-st_join(slvShp_segm_info,int_result)
slvShp_segm_info <- subset(slvShp_segm_info, select = -SEG_ID.y)
names(slvShp_segm_info)[names(slvShp_segm_info) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info)[names(slvShp_segm_info) == 'n'] <- 'n_sch'

#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
slvShp_segm_info_sp_v2 <- as(slvShp_segm_info, Class='Spatial')

#Exporting the shapefile 
writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="slvShp_segm_info_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#---------------------------------------------------------------------------------------
## VISUAL CHECKS:
#
#---------------------------------------------------------------------------------------
#Plotting
tm_shape(slvShp_segm_info) + 
  tm_polygons(col = "mean_nl", lwd=0.02, title="Mean of Night Light (2013)")+
  tm_layout(frame = FALSE)

tm_shape(y1) + 
  tm_polygons(col = "dist_control", lwd=0.02, title="")+
  tm_layout(frame = FALSE)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(slvShp) + 
  tm_borders()+ 
  tm_layout(legend.show=FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_nl13_cntrl_intersect.pdf")

tm_shape(y2) + 
  tm_polygons(col = "within_control", lwd=0.02, title="Within control")+
  tm_layout(frame = FALSE)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(slvShp) + 
  tm_borders()+ 
  tm_layout(legend.show=FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_nl13_cntrl_centroid.pdf")

#Hospitals and segments map 
tm_shape(slvShp_segm_info) + 
  tm_polygons(col = "n_hosp", lwd=0.02, title="N hosp)")+
  tm_layout(frame = FALSE)

#Hospitals and segments map 
tm_shape(slvShp_segm_info) + 
  tm_borders()+
  tm_shape(hospitales_sf) + 
  tm_dots(size=0.2,col="red")+
  tm_add_legend(type="symbol", col="red", title="Hospital")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_hospitals.pdf")


tm_shape(slvShp_segm_info) + 
  tm_polygons(col = "n_hosp", lwd=0.02, title="Number of Hospitals")+
  tm_layout(frame = FALSE)

#Schools and segments map 
tm_shape(slvShp_segm_info) + 
  tm_borders()+
  tm_shape(schools_sf) + 
  tm_dots(size=0.2,col="blue")+
  tm_add_legend(type="symbol", col="blue", title="Centro Educativo")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_schools.pdf")










#END.
