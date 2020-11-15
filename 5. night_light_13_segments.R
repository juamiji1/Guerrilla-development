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


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES OF FMLN ZONES:
#
#---------------------------------------------------------------------------------------
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

#Directory: 
current_path ='C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/censo2007/'
setwd(current_path)

#Importing El salvador shapefile of segments 
slvShp_segm <- st_read(dsn='shapefiles', layer = "DIGESTYC_Segmentos2007")
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
nl13 <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
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


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
#Creating indicators for whether the pixel is within each FMLN zone
slvShp_segm_int <- mutate(slvShp_segm, within_control=as.numeric(st_intersects(slvShp_segm, controlShp, sparse = FALSE)), 
                             within_expansion=as.numeric(st_intersects(slvShp_segm, expansionShp, sparse = FALSE)),
                             within_disputa=as.numeric(st_intersects(slvShp_segm, disputaShp, sparse = FALSE)))

#Calculating the minimum distance of each pixel to the FMLN zones 
slvShp_segm_int$dist_control<-as.numeric(st_distance(slvShp_segm, control_line))
slvShp_segm_int$dist_expansion<-as.numeric(st_distance(slvShp_segm, expansion_line))
slvShp_segm_int$dist_disputa<-as.numeric(st_distance(slvShp_segm, disputa_line))

#Subseting to check the bordering pixels 
y<-subset(slvShp_segm_int, dist_control==0)

# Converting from sf to sp object
slvShp_segm_sp <- as(slvShp_segm_int, Class='Spatial')

#Averaging rasters by night light pixel 
detach(package:tidyr)

slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[23] <- 'mean_nl'

slvShp_segm_info_sp <- extract(elevation_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[24] <- 'mean_elev'

slvShp_segm_info_sp <- extract(cacao_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[25] <- 'mean_cacao'

slvShp_segm_info_sp <- extract(bean_mask, slvShp_segm_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[26] <- 'mean_bean'

#Median of night light pixel 
slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_info_sp, fun=median, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[27] <- 'med_nl'

slvShp_segm_info_sp <- extract(elevation_mask, slvShp_segm_info_sp, fun=median, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[28] <- 'med_elev'

slvShp_segm_info_sp <- extract(cacao_mask, slvShp_segm_info_sp, fun=median, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[29] <- 'med_cacao'

slvShp_segm_info_sp <- extract(bean_mask, slvShp_segm_info_sp, fun=median, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[30] <- 'med_bean'

#Max of night light pixel 
slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_info_sp, fun=max, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[31] <- 'max_nl'

slvShp_segm_info_sp <- extract(elevation_mask, slvShp_segm_info_sp, fun=max, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[32] <- 'max_elev'

slvShp_segm_info_sp <- extract(cacao_mask, slvShp_segm_info_sp, fun=max, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[33] <- 'max_cacao'

slvShp_segm_info_sp <- extract(bean_mask, slvShp_segm_info_sp, fun=max, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[34] <- 'max_bean'

#Min of night light pixel 
slvShp_segm_info_sp <- extract(nl13_mask, slvShp_segm_info_sp, fun=min, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[35] <- 'min_nl'

slvShp_segm_info_sp <- extract(elevation_mask, slvShp_segm_info_sp, fun=min, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[36] <- 'min_elev'

slvShp_segm_info_sp <- extract(cacao_mask, slvShp_segm_info_sp, fun=min, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[37] <- 'min_cacao'

slvShp_segm_info_sp <- extract(bean_mask, slvShp_segm_info_sp, fun=min, na.rm=TRUE, sp=TRUE)
names(slvShp_segm_info_sp)[38] <- 'min_bean'


#Exporting the shapefile 
writeOGR(obj=slvShp_segm_info_sp, dsn="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/night_lights", layer="slvShp_segm_info_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)

#Transforming sp object to sf object 
slvShp_segm_info <- st_as_sf(slvShp_segm_info_sp, coords = c('y', 'x'))

#---------------------------------------------------------------------------------------
## VISUAL CHECK:
#
#---------------------------------------------------------------------------------------
#Plotting
tm_shape(slvShp_segm_info) + 
  tm_polygons(col = "mean_nl", lwd=0.02, title="Mean of Night Light (2013)")+
  tm_layout(frame = FALSE)





#END.