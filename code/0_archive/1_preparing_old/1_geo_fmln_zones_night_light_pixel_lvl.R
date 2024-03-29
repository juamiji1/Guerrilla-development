#--------------------------------------------------------------------------------------------------
# PROJECT: Guerrillas and Development 
# TOPIC: This file prepare the spatial data at the pixel level 
# AUTHOR: JMJR
# DATE: 
#--------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------
## PACKAGES AND LIBRARIES:
#
#---------------------------------------------------------------------------------------
#install.packages('bit64')
#install.packages('raster')

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
library(matrixStats)


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

#Importing the line break for each 5 kms
#disputaBrk <- st_read(dsn = "gis/guerrilla_map", layer = "Zonas_disputa_segments")
#disputaBrk <- st_transform(disputaBrk, crs = slv_crs)

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

#Transforming sf object to sp object 
slvShp_sp <- as(slvShp, Class='Spatial')


#---------------------------------------------------------------------------------------
## PREPARING THE NIGHT LIGHT GRID:
#
#---------------------------------------------------------------------------------------
#Importing the 2013 night light raster 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
crs(nl13)
res(nl13)

#Cropping and masking the raster to fit el salvador size
nl13_crop <- crop(nl13, slvShp_sp)
nl13_mask <- mask(nl13_crop, mask=slvShp_sp)

#Converting the raster to a same size polygon grid 
nl13Shp_pixels_sp <- rasterToPolygons(nl13_mask, dissolve=FALSE)

#Fixing the nl value 
names(nl13Shp_pixels_sp)[1] <- 'value'

#Transforming sp object to sf object 
nl13Shp_pixels <- st_as_sf(nl13Shp_pixels_sp, coords = c('y', 'x'))
crs(nl13Shp_pixels)


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
#Calculating centroid of pixels
pixel_centroid <-st_centroid(nl13Shp_pixels)

#Creating indicators for whether the pixel is within each FMLN zone
nl13Shp_pixels_int <- mutate(nl13Shp_pixels, within_control=as.numeric(st_intersects(nl13Shp_pixels, controlShp, sparse = FALSE)), 
                             within_expansion=as.numeric(st_intersects(nl13Shp_pixels, expansionShp, sparse = FALSE)),
                             within_disputa=as.numeric(st_intersects(nl13Shp_pixels, disputaShp, sparse = FALSE)), 
                             within_control2=as.numeric(st_within(pixel_centroid, controlShp, sparse = FALSE)), 
                             within_expansion2=as.numeric(st_within(pixel_centroid, expansionShp, sparse = FALSE)),
                             within_disputa2=as.numeric(st_within(pixel_centroid, disputaShp, sparse = FALSE)),
                             within_control3=as.numeric(st_within(nl13Shp_pixels, controlShp, sparse = FALSE)), 
                             within_expansion3=as.numeric(st_within(nl13Shp_pixels, expansionShp, sparse = FALSE)),
                             within_disputa3=as.numeric(st_within(nl13Shp_pixels, disputaShp, sparse = FALSE)),
                             lake_int=as.numeric(st_intersects(nl13Shp_pixels, lakeShp, sparse = FALSE)), 
                             riv1_int=as.numeric(st_intersects(nl13Shp_pixels, river1Shp, sparse = FALSE)),
                             riv2_int=as.numeric(st_intersects(nl13Shp_pixels, river2Shp, sparse = FALSE)), 
                             rail_int=as.numeric(st_intersects(nl13Shp_pixels, railShp, sparse = FALSE)),
                             road_int=as.numeric(st_intersects(nl13Shp_pixels, roadShp, sparse = FALSE)))

#Calculating the minimum distance of each pixel to the FMLN zones 
nl13Shp_pixels_int$dist_control<-as.numeric(st_distance(nl13Shp_pixels, control_line))
nl13Shp_pixels_int$dist_expansion<-as.numeric(st_distance(nl13Shp_pixels, expansion_line))
nl13Shp_pixels_int$dist_disputa<-as.numeric(st_distance(nl13Shp_pixels, disputa_line))

nl13Shp_pixels_int$dist_control2<-as.numeric(st_distance(pixel_centroid, control_line))
nl13Shp_pixels_int$dist_expansion2<-as.numeric(st_distance(pixel_centroid, expansion_line))
nl13Shp_pixels_int$dist_disputa2<-as.numeric(st_distance(pixel_centroid, disputa_line))

#Subseting to check the bordering pixels 
y1<-subset(nl13Shp_pixels_int, dist_control==0)
y2<-subset(nl13Shp_pixels_int, dist_control2<800 & within_control2==1)


#---------------------------------------------------------------------------------------
## cALCULATING RASTER OUTCOMES AT THE PIXEL LEVEL:
#
#---------------------------------------------------------------------------------------
nl13Shp_pixels_sp <- as(nl13Shp_pixels_int, Class='Spatial')
crs(nl13Shp_pixels_sp)

writeOGR(obj=nl13Shp_pixels_sp, dsn="guerrilla_map", layer="nl13Shp_pixels_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)

##Adding geographical controls information to the pixel shape
#Importing rasters 
nl13 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/night_lights/raw/F182013.v4c.avg_lights_x_pct.tif')
elevation <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/SLV_msk_alt.vrt')
elevation2 <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/altitud/DEM.tif')
cacao <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Cacao/res02_crav6190h_coco000a_yld.tif')
bean <- raster('C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/FAO/Phaseolus bean/res02_crav6190h_bean000a_yld.tif')

#Aligning the CRS for all rasters 
nl_crs <- crs(nl13)
elevation <- projectRaster(elevation, crs=nl_crs)
elevation2 <- projectRaster(elevation2, crs=nl_crs)
cacao <- projectRaster(cacao, crs=nl_crs)
bean <- projectRaster(bean, crs=nl_crs)

elevation2<-resample(elevation2, elevation, method="bilinear")
slope <- terrain(elevation2, opt='slope', unit='degrees', neighbors=4)

#Masking Elevation
elevation_crop <- crop(elevation, slvShp_sp)
elevation2_crop <- crop(elevation2, slvShp_sp)
elevation_mask <- mask(elevation_crop, mask=slvShp_sp)
elevation2_mask <- mask(elevation2_crop, mask=slvShp_sp)

#Checking the CRS 
crs(elevation)
crs(cacao)
crs(bean)

#Checking resolution
res(nl13)
res(elevation)
res(cacao)
res(bean)

#Averaging rasters by night light pixel 
.rs.unloadPackage("tidyr")
nl13Shp_pixels_info_sp <- extract(elevation, nl13Shp_pixels_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[22] <- 'mean_elev'
nl13Shp_pixels_info_sp <- extract(cacao, nl13Shp_pixels_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[23] <- 'mean_cacao'
nl13Shp_pixels_info_sp <- extract(bean, nl13Shp_pixels_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[24] <- 'mean_bean'
nl13Shp_pixels_info_sp <- extract(elevation2, nl13Shp_pixels_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[25] <- 'mean_elev2'
nl13Shp_pixels_info_sp <- extract(slope, nl13Shp_pixels_info_sp, fun=mean, na.rm=TRUE, sp=TRUE)
names(nl13Shp_pixels_info_sp)[26] <- 'mean_slope'

#TRansforming from sp to sf 
nl13Shp_pixels_info_v2 <- st_as_sf(nl13Shp_pixels_info_sp, coords = c('y', 'x'))

#---------------------------------------------------------------------------------------
## INCLUDING THE LINE BREAK FE:
#
#---------------------------------------------------------------------------------------
#Sampling points int he borders for the RDD
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

control_line_sample <- st_sample(control_line, 200, type="regular")
pnt_controlBrk_200 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 100, type="regular")
pnt_controlBrk_100 <- st_cast(control_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 50, type="regular")
pnt_controlBrk_50 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_1000, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk1000<-distMin
nl13Shp_pixels_info_v2$brkfe1000<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_400, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk400<-distMin
nl13Shp_pixels_info_v2$brkfe400<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_200, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk200<-distMin
nl13Shp_pixels_info_v2$brkfe200<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_100, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk100<-distMin
nl13Shp_pixels_info_v2$brkfe100<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_50, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk50<-distMin
nl13Shp_pixels_info_v2$brkfe50<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_25, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk25<-distMin
nl13Shp_pixels_info_v2$brkfe25<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_disputaBrk_10, by_element = FALSE)

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
nl13Shp_pixels_info_v2$dist_brk10<-distMin
nl13Shp_pixels_info_v2$brkfe10<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_controlBrk_200, by_element = FALSE)

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
nl13Shp_pixels_info_v2$cntrldist_brk200<-distMin
nl13Shp_pixels_info_v2$cntrlbrkfe200<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_controlBrk_100, by_element = FALSE)

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
nl13Shp_pixels_info_v2$cntrldist_brk100<-distMin
nl13Shp_pixels_info_v2$cntrlbrkfe100<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(nl13Shp_pixels_info_v2, pnt_controlBrk_50, by_element = FALSE)

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
nl13Shp_pixels_info_v2$cntrldist_brk50<-distMin
nl13Shp_pixels_info_v2$cntrlbrkfe50<-brkIndexUnique[, 'col']


#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE AS AN SP OBJECT:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
nl13Shp_pixels_info_sp_v2 <- as(nl13Shp_pixels_info_v2, Class='Spatial')

#Exporting the shape with additional info 
writeOGR(obj=nl13Shp_pixels_info_sp_v2, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_pixel_lvl_vars", layer="nl13Shp_pixels_info_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)


#---------------------------------------------------------------------------------------
## PLOTTING VISUALIZATION CHECKS:
#
#---------------------------------------------------------------------------------------
tm_shape(nl13Shp_pixels_int) + 
  tm_polygons('within_control', palette='Greys', alpha= .25) +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(control_line)+
  tm_lines(col='red') +
  tm_shape(slvShp) + 
  tm_borders()

tm_shape(disputa_line)+
  tm_lines(col='red') +
  tm_shape(slvShp) + 
  tm_borders()

tmap_mode("plot")

tm_shape(y1) + 
  tm_polygons(col = "dist_control", lwd=0.02, title="")+
  tm_layout(frame = FALSE)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(slvShp) + 
  tm_borders()+ 
  tm_layout(legend.show=FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/4-Results/Salvador/plots/pixel_nl13_cntrl_intersect.pdf")

tm_shape(y2) + 
  tm_polygons(col = "within_control", lwd=0.02, title="Within control")+
  tm_layout(frame = FALSE)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(slvShp) + 
  tm_borders()+ 
  tm_layout(legend.show=FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/4-Results/Salvador/plots/pixel_nl13_cntrl_centroid.pdf")

#Exporting map of night light density and FMLN zones
tm_shape(nl13_mask) + 
  tm_raster(title='Night Light Density (2013)') +
  tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(disputaShp) + 
  tm_borders(col='pink', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="pink", lwd=10, title="FMLN-Disputed zone")+
  tm_shape(expansionShp) + 
  tm_borders(col='blue', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="blue", lwd=10, title="FMLN-Expansion zone")+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red", lwd=10, title="FMLN-Dominated zone")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.15, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/night_light_13_salvador.pdf")

#Exporting map of elevation and FMLN zones
tm_shape(elevation_mask) + 
  tm_raster(title='Elevation', palette="-RdYlGn") +
  tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(disputaShp) + 
  tm_borders(col='pink', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="pink", lwd=10, title="FMLN-Disputed Zone")+
  tm_shape(expansionShp) + 
  tm_borders(col='blue', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="blue", lwd=10, title="FMLN-Expansion zone")+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red", lwd=10, title="FMLN-Dominated Zone")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.15, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/elevation_salvador.pdf")


tm_shape(nl13Shp_pixels) + 
  tm_borders()

tm_shape(elevation) + 
  tm_raster(title='Elevation')

tm_shape(cacao) + 
  tm_raster(title='Cacao')

tm_shape(bean) + 
  tm_raster(title='Bean')

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("value", title="Night light")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/night_light_13_pixel.pdf")

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("mean_elev", title="Elevation")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/elevation_pixel.pdf")

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("mean_cacao", title="Cacao yield")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/cacao_pixel.pdf")

tm_shape(nl13Shp_pixels_info) +
  tm_polygons("mean_bean", title="Bean yield")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/bean_pixel.pdf")


tm_shape(slvShp) + 
  tm_borders(col='black', lwd = 1, lty = "solid", alpha = NA)+
  tm_shape(pnt_disputaBrk_200) +
  tm_symbols(col = "pink", scale = .5)+
  tm_add_legend(type="symbol", col="pink", title="Border break")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/disputa_border_break_fe.pdf")

tm_shape(slvShp) + 
  tm_borders(col='black', lwd = 1, lty = "solid", alpha = NA)+
  tm_shape(pnt_controlBrk_200) +
  tm_symbols(col = "red", scale = .5)+
  tm_add_legend(type="symbol", col="red", title="Border break")+
  tm_layout(frame = FALSE)








#END.

