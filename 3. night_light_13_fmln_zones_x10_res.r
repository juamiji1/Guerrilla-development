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


#Directory: 
current_path ='C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/'
setwd(current_path)


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES OF FMLN ZONES:
#
#---------------------------------------------------------------------------------------

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

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')


#---------------------------------------------------------------------------------------
## PREPARING RASTERS (NLD, altitude, cacao):
#
#---------------------------------------------------------------------------------------

#Importing the 2013 night light raster 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
elevation <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
cacao <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/FAO/Cacao/res02_crav6190h_coco000a_yld.tif')
bean <- raster('C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/2-Data/Salvador/gis/FAO/Phaseolus bean/res02_crav6190h_bean000a_yld.tif')

#Aligning the CRS for all rasters 
nl_crs <- crs(nl13)
elevation <- projectRaster(elevation, crs=nl_crs)
cacao <- projectRaster(cacao, crs=nl_crs)
bean <- projectRaster(bean, crs=nl_crs)

#Checking the CRS 
nl13
crs(elevation)
crs(cacao)
crs(bean)

#Checking resolution
res(nl13)
res(elevation)
res(cacao)
res(bean)

#Aggregating the resolution of nl13 and elevation to match the cacao an bean res
nl13_x10 <- aggregate(nl13, fact = 10)
elevation_x10 <- aggregate(elevation, fact = 10)

res(nl13_x10)
res(elevation_x10)

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13_x10, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)

#Converting the raster to a same size polygon grid 
nl13Shp_pixels_sp <- rasterToPolygons(nl13_mask, dissolve=FALSE)

#Fixing the nl value 
names(nl13Shp_pixels_sp)[1] <- 'value'

#Transforming sp object to sf object 
nl13Shp_pixels <- st_as_sf(nl13Shp_pixels_sp, coords = c('y', 'x'))


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------

#Creating indicators for whether the pixel is within each FMLN zone
nl13Shp_pixels_int <- mutate(nl13Shp_pixels, within_control=as.numeric(st_intersects(nl13Shp_pixels, controlShp, sparse = FALSE)), 
                             within_expansion=as.numeric(st_intersects(nl13Shp_pixels, expansionShp, sparse = FALSE)),
                             within_disputa=as.numeric(st_intersects(nl13Shp_pixels, disputaShp, sparse = FALSE)))

#Calculating the minimum distance of each pixel to the FMLN zones 
nl13Shp_pixels_int$dist_control<-as.numeric(st_distance(nl13Shp_pixels, control_line))
nl13Shp_pixels_int$dist_expansion<-as.numeric(st_distance(nl13Shp_pixels, expansion_line))
nl13Shp_pixels_int$dist_disputa<-as.numeric(st_distance(nl13Shp_pixels, disputa_line))

# Converting from sf to sp object
nl13Shp_pixels_sp <- as(nl13Shp_pixels_int, Class='Spatial')

#Averaging rasters by night light pixel 
nl13Shp_pixels_info_sp <- extract(elevation, nl13Shp_pixels_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[8] <- 'mean_elev'
nl13Shp_pixels_info_sp <- extract(cacao, nl13Shp_pixels_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[9] <- 'mean_cacao'
nl13Shp_pixels_info_sp <- extract(bean, nl13Shp_pixels_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[10] <- 'mean_bean'

#Transforming sp object to sf object 
nl13Shp_pixels_info <- st_as_sf(nl13Shp_pixels_info_sp, coords = c('y', 'x'))

#Exporting the shape with additional info 
writeOGR(obj=nl13Shp_pixels_info_sp, dsn="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/5-Maps/Salvador/pixel_lvl_vars", layer="nl13Shp_pixels_info_sp_x10_res", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#---------------------------------------------------------------------------------------
## VISUAL CHECK
#
#---------------------------------------------------------------------------------------

#Plotting
tm_shape(nl13Shp_pixels) + 
  tm_borders()

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("value", title="Night light")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/4-Results/Salvador/plots/night_light_13_pixel.pdf")

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("mean_elev", title="Elevation")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/4-Results/Salvador/plots/elevation_pixel.pdf")

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("mean_cacao", title="Cacao yield")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/4-Results/Salvador/plots/cacao_pixel.pdf")

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("mean_bean", title="Bean yield")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Mica-projects/Guerillas_Development/4-Results/Salvador/plots/bean_pixel.pdf")






