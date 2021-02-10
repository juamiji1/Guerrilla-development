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


## PREPARING SHAPEFILES OF FMLN ZONES:

#Directory: 
current_path ='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/5-Maps/Salvador/slv_adm_2020_shp", layer = "slv_admbnda_adm0_2020")
slv_crs <- st_crs(slvShp)

#Importing El salvador shapefile of segments 
slvShp_segm <- st_read(dsn='censo2007/shapefiles', layer = "DIGESTYC_Segmentos2007")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

names(slvShp_segm)[12] <- 'segment_id'

#Importing info of ephm segments 
ephm <- read.csv(file = 'segment_id.csv', header=T, quote='\"', colClasses = c("integer", "factor", "integer"))

#Matching segments id 
slvShp_segm_ephm <- left_join(slvShp_segm,ephm, by='segment_id', copy=FALSE)

#Number of segments we have in ephm (CHECK)
my_summary_data <- slvShp_segm_ephm %>%
  group_by(ehpm) %>%
  summarise(Count = n()) 
my_summary_data

#Transforming sf object to sp object 
slvShp_segm_ephm_sp <- as(slvShp_segm_ephm, Class='Spatial')
slvShp_sp <- as(slvShp, Class='Spatial')


## PLOTTING VISUALIZATION CHECKS:
tm_shape(slvShp_segm_ephm) + 
  tm_borders()+
  tm_fill('ehpm', palette='dodgerblue3', colorNA=NULL, title='Segment in EHPM')+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/4-Results/Salvador/plots/slv_census_segm_ehpm.pdf")



