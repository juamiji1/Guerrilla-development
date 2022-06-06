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
library(devtools)
install_version("sf", version = "0.9.8", repos = "http://cran.us.r-project.org")

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
library("rgeos")
library(rmapshaper)
library(geojsonio)
library("viridis") 
library("qpdf")  
library("tools")
library(stringr)


#Directory: 
current_path ='C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
setwd(current_path)

#---------------------------------------------------------------------------------------
# Preparing Administrative boundaries:
#---------------------------------------------------------------------------------------
#Importing El salvador shapefile
slvShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing El salvador shapefile of segments 
slvShp_segm <- st_read(dsn='gis/maps_interim', layer = "segm07_nowater")
st_crs(slvShp)==st_crs(slvShp_segm)
slvShp_segm <-st_transform(slvShp_segm, crs=slv_crs)
st_crs(slvShp)==st_crs(slvShp_segm)

#---------------------------------------------------------------------------------------
# Preparing Guerrilla boundaries:
#---------------------------------------------------------------------------------------
#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Converting polygons to polylines
control_line <- st_read(dsn = "gis/maps_interim", layer = "control91_line")

#---------------------------------------------------------------------------------------
# Preparing data to plot predicted values
#---------------------------------------------------------------------------------------
#Importing predicted outcomes
predicted <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/predicted_outcomes_all.csv")
consult <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/info_consulting.csv")
random <- read.csv("C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/info_consulting_sample_hh_randomized.csv")

#Joining predictions to shape with info 
slvShp_segm$SEG_ID<-as.integer(slvShp_segm$SEG_ID)
slvShp_segm_join <- left_join(slvShp_segm, predicted, by = c("SEG_ID" = "segm_id"))
consult_join <- left_join(slvShp_segm, consult, by = c("SEG_ID" = "segm_id"))

#Sample of segments in the regression 
slvShp_segm_sample<-subset(slvShp_segm_join, sample_reg==1)
slvShp_segm_sample_6kms<-subset(slvShp_segm_join, z_run_cntrl<=6 & z_run_cntrl>=-6)
slvShp_segm_sample_wc0<-subset(slvShp_segm_join, within_control==0)
slvShp_segm_sample_wc1<-subset(slvShp_segm_join, within_control==1)
consult_join_oriente<-subset(consult_join, sample_reg==1 & region==3)

#---------------------------------------------------------------------------------------
# Plotting the predictions 
#---------------------------------------------------------------------------------------
#Using prediction on all census tracts 
#sf::sf_use_s2(FALSE)
tm_shape(slvShp_segm_join) + 
tm_polygons(col='arcsine_nl13_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
tmap_options(check.and.fix = TRUE)+
tm_shape(control_line) + 
tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)

tm_shape(slvShp_segm_sample) + 
  tm_polygons(col='arcsine_nl13_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
  tmap_options(check.and.fix = TRUE)+
  tm_shape(control_line) + 
  tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)

tm_shape(slvShp_segm_join) + 
tm_polygons(col='arcsine_nl13_r', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
tmap_options(check.and.fix = TRUE)+
tm_shape(control_line) + 
tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)


tm_shape(slvShp_segm_sample_6kms) + 
  tm_polygons(col='bean05_r', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
  tmap_options(check.and.fix = TRUE)+
  tm_shape(control_line) + 
  tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)

tm_shape(slvShp_segm_sample_wc1) + 
  tm_polygons(col='bean05_r', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
  tmap_options(check.and.fix = TRUE)+
  tm_shape(control_line) + 
  tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)



out_vars=c('arcsine_nl13', 'z_wi', 'mean_educ_years', 'bean05', 'maize05', 'coffe05', 'sugar05', 'h_bean05', 'h_maize05', 'h_coffee05', 
           'h_sugar05', 'prod_bean05', 'prod_maize05', 'prod_coffee05', 'prod_sugar05', 'size_comer', 'sizet_comer', 'sizec_comer',
           'sh_prod_own_comer', 'si_all_segm', 'si_comer_segm', 'si_subs_segm', 'z_index_pp', 'z_index_ep', 'z_index_ap', 'z_index_trst')

out_vars_xb=c('arcsine_nl13_xb', 'z_wi_xb', 'mean_educ_years_xb', 'bean05_xb', 'maize05_xb', 'coffe05_xb', 'sugar05_xb', 'h_bean05_xb', 'h_maize05_xb', 'h_coffee05_xb', 
           'h_sugar05_xb', 'prod_bean05_xb', 'prod_maize05_xb', 'prod_coffee05_xb', 'prod_sugar05_xb', 'size_comer_xb', 'sizet_comer_xb', 'sizec_comer_xb',
           'sh_prod_own_comer_xb', 'si_all_segm_xb', 'si_comer_segm_xb', 'si_subs_segm_xb', 'z_index_pp_xb', 'z_index_ep_xb', 'z_index_ap_xb', 'z_index_trst_xb')

out_vars_xb_m=c('arcsine_nl13_xb_m', 'z_wi_xb_m', 'mean_educ_years_xb_m', 'bean05_xb_m', 'maize05_xb_m', 'coffe05_xb_m', 'sugar05_xb_m', 'h_bean05_xb_m', 'h_maize05_xb_m', 'h_coffee05_xb_m', 
              'h_sugar05_xb_m', 'prod_bean05_xb_m', 'prod_maize05_xb_m', 'prod_coffee05_xb_m', 'prod_sugar05_xb_m', 'size_comer_xb_m', 'sizet_comer_xb_m', 'sizec_comer_xb_m',
              'sh_prod_own_comer_xb_m', 'si_all_segm_xb_m', 'si_comer_segm_xb_m', 'si_subs_segm_xb_m', 'z_index_pp_xb_m', 'z_index_ep_xb_m', 'z_index_ap_xb_m', 'z_index_trst_xb_m')


for(var in out_vars_xb){
  
  map_name<-paste0("C:/Users/juami/Dropbox/Overleaf/GD-draft-slv/plots/",var,"_heatmap.png")
  
  var_map<-tm_shape(slvShp_segm_join) + 
    tm_polygons(col=var, title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
    tmap_options(check.and.fix = TRUE)+
    tm_shape(control_line) + 
    tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
    tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
    
  tmap_save(var_map, filename=map_name)
}

for(var in out_vars){
  
  map_name<-paste0("C:/Users/juami/Dropbox/Overleaf/GD-draft-slv/plots/",var,"_heatmap.png")
  
  var_map<-tm_shape(slvShp_segm_join) + 
    tm_polygons(col=var, title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
    tmap_options(check.and.fix = TRUE)+
    tm_shape(control_line) + 
    tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
    tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
  
  tmap_save(var_map, filename=map_name)
}

for(var in out_vars_xb){
  
  map_name<-paste0("C:/Users/juami/Dropbox/Overleaf/GD-draft-slv/plots/",var,"_heatmap_sample.png")
  
  var_map<-tm_shape(slvShp_segm_sample) + 
    tm_polygons(col=var, title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
    tmap_options(check.and.fix = TRUE)+
    tm_shape(control_line) + 
    tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
    tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
  
  tmap_save(var_map, filename=map_name)
}

for(var in out_vars_xb_m){
  
  map_name<-paste0("C:/Users/juami/Dropbox/Overleaf/GD-draft-slv/plots/",var,"_heatmap_sample.png")
  
  var_map<-tm_shape(slvShp_segm_sample) + 
    tm_polygons(col=var, title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
    tmap_options(check.and.fix = TRUE)+
    tm_shape(control_line) + 
    tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)+
    tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
  
  tmap_save(var_map, filename=map_name)
}


map_name<-paste0("C:/Users/juami/Dropbox/Overleaf/GD-draft-slv/plots/",'pop',"_heatmap_sample.png")
var_map<-tm_shape(consult_join_oriente) + 
  tm_polygons(col='total_pop', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
  tmap_options(check.and.fix = TRUE)
tmap_save(var_map, filename=map_name)

map_name<-paste0("C:/Users/juami/Dropbox/Overleaf/GD-draft-slv/plots/",'borders',".png")
var_map<-tm_shape(consult_join_oriente) + 
  tm_borders()+
  tmap_options(check.and.fix = TRUE)+
  tm_shape(control_line) + 
  tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)
tmap_save(var_map, filename=map_name)

#---------------------------------------------------------------------------------------
## EXPORTING THE SHAPEFILE WITH ALL INFORMATION:
#
#---------------------------------------------------------------------------------------
# Converting from sf to sp object
export <- as(consult_join_oriente, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=export, dsn="C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer="oriente_consult", driver="ESRI Shapefile",  overwrite_layer=TRUE)
#slvShp_segm_info1 <- st_read(dsn = "C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim", layer = "slvShp_segm_yield05")


#---------------------------------------------------------------------------------------
## SAMPLE AFTER RANDOMIZATION:
#
#---------------------------------------------------------------------------------------
centroid<-st_centroid(consult_join_oriente)
centroid <- centroid %>%
  dplyr::mutate(lon = sf::st_coordinates(.)[,1],
                lat = sf::st_coordinates(.)[,2])
centroid<-centroid[,c('SEG_ID','lon','lat')]
st_geometry(centroid)<-NULL


random<-random[, c('segm_id','total_household_survey', 'in_survey', 'n_households_survey')]
colnames(random)[1] <- "SEG_ID"

random_centroid <- left_join(random, centroid, by="SEG_ID")

consult_join_oriente2<-consult_join_oriente[ ,c('DEPTO','COD_DEP','MPIO','COD_MUN','CANTON','COD_CAN','SEG_ID','within_control')]
shape_survey<-left_join(consult_join_oriente2, random_centroid, by="SEG_ID")
shape_survey<-subset(shape_survey, in_survey==1)

#Checking 
tm_shape(shape_survey) + 
  tm_borders()+
  tm_shape(control_line) + 
  tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)

tm_shape(consult_join_oriente) + 
  tm_borders()+
  tm_shape(control_line) + 
  tm_lines(col='red', lwd = 1, lty = "solid", alpha = NA)

#Export 
# Converting from sf to sp object
shape_survey <-st_transform(shape_survey, crs=slv_crs)
export_shape_survey <- as(shape_survey, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=export_shape_survey, dsn="C:/Users/juami/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/gis/maps_interim/segm_consult", layer="segm_survey", driver="ESRI Shapefile",  overwrite_layer=TRUE)

