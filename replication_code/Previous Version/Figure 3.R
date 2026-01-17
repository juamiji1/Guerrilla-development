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
#install.packages("data.table", dependencies=TRUE)
#install.packages("rgdal")
#install.packages("rgeos")
#install.packages("ggplot2")
#install.packages("ggrepel")
#install.packages("sf")
#install.packages("sp")
#install.packages("ggpubr")
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("scales") 
#install.packages("tidyverse")
#install.packages("lubridate")
#install.packages("gtools")
#install.packages("foreign")
#install.packages("readxl")
#install.packages("ggmap")
#install.packages("maps")
#install.packages("gganimate")
#install.packages("gifski")
#install.packages("transformr")
#install.packages("tmap")
#install.packages("raster")
#install.packages("exactextractr")
#install.packages("matrixStats")
#install.packages("rgeos")
#install.packages("rmapshaper")
#install.packages("geojsonio")
#install.packages("viridis") 
#install.packages("qpdf")  
#install.packages("tools")  

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
library("readxl")
library(ggmap)
library(maps)
library(gganimate)
library(gifski)
library(transformr)
library(tmap)
library(raster)
#library(exactextractr)
#library(matrixStats)
library("rgeos")
library(rmapshaper)
library(geojsonio)
library("viridis") 
library("qpdf")  
library("tools")  


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES:
#
#---------------------------------------------------------------------------------------
#Directory: 
current_path ='/Users/bj6385/Desktop/Guerrillas 2023 Replication/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing FMLN control zones
controlShp <- st_read(dsn = "Data/gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

disputaShp <- st_read(dsn = "Data/gis/guerrilla_map", layer = "zona_fmln_onu_91")
st_crs(disputaShp) <- slv_crs

#Importing breaks of controlled zones
pnt_controlBrk_400<- st_read(dsn = "Data/gis/nl_segm_lvl_vars", layer = "pnt_controlBrk_400")
pnt_controlBrk_1000<- st_read(dsn = "Data/gis/nl_segm_lvl_vars", layer = "pnt_controlBrk_1000")

#Importing El salvador shapefile
deptoShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_admbnda_adm1_2020")
muniShp <- st_read(dsn = "Data/gis/slv_adm_2020_shp", layer = "slv_admbnda_adm2_2020")

#Importing worked shapefile
slvShp_segm_info <- st_read(dsn = "Data/gis/nl_segm_lvl_vars", layer = "slvShp_segm_info_sp_onu_91")

# Importing outcomes: 
Outcomes <- read_excel("Data/Predicted_Outcomes.xls")
slvShp_segm_info <- full_join(slvShp_segm_info, Outcomes, by = "SEG_ID")

#Rivers
river1Shp <- st_read(dsn = "Data/gis/Hidrografia", layer = "rioA_merge")
river1Shp <- st_transform(river1Shp, crs = slv_crs)


#---------------------------------------------------------------------------------------
## PLOTS:
#
#---------------------------------------------------------------------------------------

tm_shape(slvShp_segm_info) + 
  tm_polygons(col='insamp_arcsine_nl13_xb', title='Night Lights', palette="inferno", colorNA = "white", textNA = "Not in Sample", n=10, style='pretty', border.col=NA, border.alpha=0)+
  tmap_options(check.and.fix = TRUE)+
  tm_shape(controlShp) + 
  tm_borders(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red2", lwd=10, title="Guerrilla Control")+
  tm_shape(river1Shp)+
  tm_borders(col='deepskyblue3', lwd = 2, lty = "solid", alpha = NA) +
  tm_scale_bar(position=c("left", "bottom")) +
  tm_add_legend(type="line", col="deepskyblue3", lwd=10, title="Main Rivers")+
  tm_scale_bar(position=c("left", "bottom")) +
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="Plots/insamp_nl.png")



tm_shape(slvShp_segm_info) + 
  tm_polygons(col='insamp_mean_educ_years_xb', title='Mean Education Years', palette="inferno", colorNA = "white", textNA = "Not in Sample", n=10, style='pretty', border.col=NA, border.alpha=0)+
  tm_shape(controlShp) + 
  tm_borders(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red2", lwd=10, title="Guerrilla Control")+
  tm_shape(river1Shp)+
  tm_borders(col='deepskyblue3', lwd = 2, lty = "solid", alpha = NA) +
  tm_scale_bar(position=c("left", "bottom")) +
  tm_add_legend(type="line", col="deepskyblue3", lwd=10, title="Main Rivers")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="Plots/insamp_mean_educ_years.png")




tm_shape(slvShp_segm_info) + 
  tm_polygons(col='insamp_z_wi_xb', title='Wealth Index', palette="inferno", colorNA = "white", textNA = "Not in Sample", n=10, style='pretty', border.col=NA, border.alpha=0)+
  tm_shape(controlShp) + 
  tm_borders(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red2", lwd=10, title="Guerrilla Control")+
  tm_shape(river1Shp)+
  tm_borders(col='deepskyblue3', lwd = 2, lty = "solid", alpha = NA) +
  tm_scale_bar(position=c("left", "bottom")) +
  tm_add_legend(type="line", col="deepskyblue3", lwd=10, title="Main Rivers")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="Plots/insamp_wealth.png")
