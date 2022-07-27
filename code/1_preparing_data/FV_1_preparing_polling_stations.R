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
# Preparing Centros de Votacion:
#---------------------------------------------------------------------------------------
mesas14 <- st_read(dsn = "gis/electoral_results", layer = "mesas2014_depmuni")
mesas15 <- st_read(dsn = "gis/electoral_results", layer = "mesas2015_depmuni")
mesas12 <- st_read(dsn = "gis/electoral_results", layer = "mesas2012")


#---------------------------------------------------------------------------------------
## CALCULATING THE NEEDED TOPOLOGICAL RELATIONS:
#
#---------------------------------------------------------------------------------------
mesas14_2<-mesas14

#Calculating the minimum distance of each mesa to the FMLN zones 
mesas14_2$dist_control<-as.numeric(st_distance(mesas14_2, control_line))
mesas14_2$dist_disputa<-as.numeric(st_distance(mesas14_2, disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
mesas14_2 <- mutate(mesas14_2, within_control=as.numeric(st_intersects(mesas14_2, controlShp, sparse = FALSE)), 
                            within_disputa=as.numeric(st_intersects(mesas14_2, disputaShp, sparse = FALSE)))

mesas15_2<-mesas15

#Calculating the minimum distance of each mesa to the FMLN zones 
mesas15_2$dist_control<-as.numeric(st_distance(mesas15_2, control_line))
mesas15_2$dist_disputa<-as.numeric(st_distance(mesas15_2, disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
mesas15_2 <- mutate(mesas15_2, within_control=as.numeric(st_intersects(mesas15_2, controlShp, sparse = FALSE)), 
                    within_disputa=as.numeric(st_intersects(mesas15_2, disputaShp, sparse = FALSE)))

mesas12_2<-mesas12

#Calculating the minimum distance of each mesa to the FMLN zones 
mesas12_2$dist_control<-as.numeric(st_distance(mesas12_2, control_line))
mesas12_2$dist_disputa<-as.numeric(st_distance(mesas12_2, disputa_line))

#Creating indicators for whether the segment is within each FMLN zone
mesas12_2 <- mutate(mesas12_2, within_control=as.numeric(st_intersects(mesas12_2, controlShp, sparse = FALSE)), 
                    within_disputa=as.numeric(st_intersects(mesas12_2, disputaShp, sparse = FALSE)))

#---------------------------------------------------------------------------------------
## INCLUDING THE LINE BREAK FE:
#
#---------------------------------------------------------------------------------------
mesas14_info<-mesas14_2

#Sampling points int the borders for the RDD
set.seed(1234)

disputa_line_sample <- st_sample(disputa_line, 400, type="regular")
pnt_disputaBrk_400 <- st_cast(disputa_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 400, type="regular")
pnt_controlBrk_400 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(mesas14_info, pnt_disputaBrk_400, by_element = FALSE)

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
mesas14_info$dist_brk400<-distMin
mesas14_info$brkfe400<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(mesas14_info, pnt_controlBrk_400, by_element = FALSE)

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
mesas14_info$cntrldist_brk400<-distMin
mesas14_info$cntrlbrkfe400<-brkIndexUnique[, 'col']


# Mesas 2015
mesas15_info<-mesas15_2

#Sampling points int the borders for the RDD
set.seed(1234)

disputa_line_sample <- st_sample(disputa_line, 400, type="regular")
pnt_disputaBrk_400 <- st_cast(disputa_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 400, type="regular")
pnt_controlBrk_400 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(mesas15_info, pnt_disputaBrk_400, by_element = FALSE)

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
mesas15_info$dist_brk400<-distMin
mesas15_info$brkfe400<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(mesas15_info, pnt_controlBrk_400, by_element = FALSE)

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
mesas15_info$cntrldist_brk400<-distMin
mesas15_info$cntrlbrkfe400<-brkIndexUnique[, 'col']



# Mesas 2012
mesas12_info<-mesas12_2

#Sampling points int the borders for the RDD
set.seed(1234)

disputa_line_sample <- st_sample(disputa_line, 400, type="regular")
pnt_disputaBrk_400 <- st_cast(disputa_line_sample, "POINT")

control_line_sample <- st_sample(control_line, 400, type="regular")
pnt_controlBrk_400 <- st_cast(control_line_sample, "POINT")

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(mesas12_info, pnt_disputaBrk_400, by_element = FALSE)

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
mesas12_info$dist_brk400<-distMin
mesas12_info$brkfe400<-brkIndexUnique[, 'col']

#Calculating the distance of each census segment to disputed border breaks
distBrk<-st_distance(mesas12_info, pnt_controlBrk_400, by_element = FALSE)

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
mesas12_info$cntrldist_brk400<-distMin
mesas12_info$cntrlbrkfe400<-brkIndexUnique[, 'col']



#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
mesas14_info_sp <- as(mesas14_info, Class='Spatial')
mesas15_info_sp <- as(mesas15_info, Class='Spatial')
mesas12_info_sp <- as(mesas12_info, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=mesas14_info_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="mesas14_info_sp_onu_91", driver="ESRI Shapefile",  overwrite_layer=TRUE, layer_options = "ENCODING=UTF-8")

writeOGR(obj=mesas15_info_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="mesas15_info_sp_onu_91", driver="ESRI Shapefile",  overwrite_layer=TRUE, layer_options = "ENCODING=UTF-8")

writeOGR(obj=mesas12_info_sp, dsn="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/nl_segm_lvl_vars", layer="mesas12_info_sp_onu_91", driver="ESRI Shapefile",  overwrite_layer=TRUE, layer_options = "ENCODING=UTF-8")











#END


