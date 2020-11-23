# PROJECT: 
# TOPIC: 
# AUTHOR: JMJR
# DATE: 

#install.packages('bit64')
#install.packages('raster')
install.packages('exactextractr')

## LIBRARIES:
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
current_path ='C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/'
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


#---------------------------------------------------------------------------------------
## PREPARING RASTERS (NLD, altitude, cacao):
#
#---------------------------------------------------------------------------------------
#Importing the rasters 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
elevation <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
cacao <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/FAO/Cacao/res02_crav6190h_coco000a_yld.tif')
bean <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/FAO/Phaseolus bean/res02_crav6190h_bean000a_yld.tif')

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
  

#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
#Calculating centroid of segments
slvShp_segm_centroid <-st_centroid(slvShp_segm)

#Calculating the minimum distance of each pixel to the FMLN zones 
slvShp_segm_int <- slvShp_segm
slvShp_segm_int$dist_control<-as.numeric(st_distance(slvShp_segm_centroid, control_line))
slvShp_segm_int$dist_expansion<-as.numeric(st_distance(slvShp_segm_centroid, expansion_line))
slvShp_segm_int$dist_disputa<-as.numeric(st_distance(slvShp_segm_centroid, disputa_line))

slvShp_segm_int$dist_control2<-as.numeric(st_distance(slvShp_segm, control_line))
slvShp_segm_int$dist_expansion2<-as.numeric(st_distance(slvShp_segm, expansion_line))
slvShp_segm_int$dist_disputa2<-as.numeric(st_distance(slvShp_segm, disputa_line))

#Creating indicators for whether the pixel is within each FMLN zone
slvShp_segm_int <- mutate(slvShp_segm_int, within_control=as.numeric(st_within(slvShp_segm_centroid, controlShp, sparse = FALSE)), 
                          within_expansion=as.numeric(st_within(slvShp_segm_centroid, expansionShp, sparse = FALSE)),
                          within_disputa=as.numeric(st_within(slvShp_segm_centroid, disputaShp, sparse = FALSE)))

slvShp_segm_int <- mutate(slvShp_segm_int, within_control2=as.numeric(st_intersects(slvShp_segm, controlShp, sparse = FALSE)), 
                          within_expansion2=as.numeric(st_intersects(slvShp_segm, expansionShp, sparse = FALSE)),
                          within_disputa2=as.numeric(st_intersects(slvShp_segm, disputaShp, sparse = FALSE)))

#Creating indicators for whether the pixel is within each FMLN zone
slvShp_segm_int <- mutate(slvShp_segm_int, lake_int=as.numeric(st_intersects(slvShp_segm, lakeShp, sparse = FALSE)), 
                             riv1_int=as.numeric(st_intersects(slvShp_segm, river1Shp, sparse = FALSE)),
                             riv2_int=as.numeric(st_intersects(slvShp_segm, river2Shp, sparse = FALSE)))

#Subseting to check the bordering pixels 
y1<-subset(slvShp_segm_int, dist_control<1000)
y2<-subset(slvShp_segm_int, within_control==1)


# Converting from sf to sp object
slvShp_segm_sp <- as(slvShp_segm_int, Class='Spatial')
#Averaging rasters by night light pixel 
#etach(package:tidyr)

slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[32] <- 'mean_nl'

slvShp_segm_info_sp <- extract(elevation_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[33] <- 'mean_elev'

slvShp_segm_info_sp <- extract(cacao_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[34] <- 'mean_cacao'

slvShp_segm_info_sp <- extract(bean_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[35] <- 'mean_bean'

#Weighted mean of night light pixel 
slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE, weights=TRUE)
names(slvShp_segm_info_sp)[36] <- 'wmean_nl1'

#Not taking into account the zeros 
slvShp_segm_info_sp <- extract(nl13_mask_zeros, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[37] <- 'mean_nl_z'

slvShp_segm_info_sp <- extract(nl13_mask_zeros, slvShp_segm_info_sp, fun=median, na.rm=TRUE, sp=TRUE, weights=TRUE)
names(slvShp_segm_info_sp)[38] <- 'wmean_nl_z'

#Transforming sp object to sf object 
slvShp_segm_info <- st_as_sf(slvShp_segm_info_sp, coords = c('y', 'x'))

slvShp_segm_info$mean_nl2 <- exact_extract(nl13_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$mean_elev2 <- exact_extract(elevation_mask, slvShp_segm_info, 'mean')
slvShp_segm_info$wmean_nl2 <- exact_extract(nl13_mask, slvShp_segm_info, 'weighted_mean', weights=area(nl13_mask))
slvShp_segm_info$wmean_elev2 <- exact_extract(elevation_mask, slvShp_segm_info, 'weighted_mean', weights=area(elevation_mask))

# Converting from sf to sp object
slvShp_segm_info_sp_v2 <- as(slvShp_segm_info, Class='Spatial')

#Exporting the shapefile 
writeOGR(obj=slvShp_segm_info_sp_v2, dsn="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/nl_segm_lvl_vars", layer="slvShp_segm_info_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#---------------------------------------------------------------------------------------
## VISUAL CHECK:
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
  tm_shape(slvShp_segm_centroid) + 
  tm_dots()

tm_shape(y2) + 
  tm_polygons(col = "within_control", lwd=0.02, title="Within control")+
  tm_layout(frame = FALSE)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(slvShp_segm_centroid) + 
  tm_dots()





#END.