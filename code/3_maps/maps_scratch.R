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
current_path ='C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/'
setwd(current_path)

#Importing El salvador shapefile
slvShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_borders_census2007")
slv_crs <- st_crs(slvShp)

#Importing FMLN control zones
controlShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_control_onu_91")
st_crs(controlShp) <- slv_crs

#Importing breaks of controlled zones
pnt_controlBrk_400<- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "pnt_controlBrk_400")
pnt_controlBrk_1000<- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "pnt_controlBrk_1000")

#Importing El salvador shapefile
deptoShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm1_2020")
muniShp <- st_read(dsn = "gis/slv_adm_2020_shp", layer = "slv_admbnda_adm2_2020")

#Rivers
river1Shp <- st_read(dsn = "gis/Hidrografia", layer = "rioA_merge")
river1Shp <- st_transform(river1Shp, crs = slv_crs)

#Importing worked shapefile
slvShp_segm_info <- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "slvShp_segm_info_sp_onu_91")

#Importing Cattaneo BW Samples
slvShp_segm_sample <- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "segm_info_sample")
control_line_sample <- st_read(dsn = "gis/guerrilla_map", layer = "control_line_sample")

#Importing predicted outcomes
predicted <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/predicted_outcomes.csv")

#Joining predictions to shape with info 
slvShp_segm_info$SEG_ID<-as.integer(slvShp_segm_info$SEG_ID)
slvShp_segm_info_join <- left_join(slvShp_segm_info, predicted, by = c("SEG_ID" = "segm_id"))

#Subseting to check the bordering segment 
y1<-subset(slvShp_segm_info_join, dst_cnt==0)
y2<-subset(slvShp_segm_info_join, dst_cn2<1250 & wthn_c2==1)

#Mesas de votacion
mesas12 <- st_read(dsn = "gis/electoral_results", layer = "mesas2012")
mesas14 <- st_read(dsn = "gis/electoral_results", layer = "mesas2014")
mesas15 <- st_read(dsn = "gis/electoral_results", layer = "mesas2015")

#Counting number of mesas per segment 
intersection <- st_intersection(x = slvShp_segm_info_join, y = mesas14)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info_join<-st_join(slvShp_segm_info_join,int_result)
slvShp_segm_info_join <- subset(slvShp_segm_info_join, select = -SEG_ID.y)
names(slvShp_segm_info_join)[names(slvShp_segm_info_join) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info_join)[names(slvShp_segm_info_join) == 'n'] <- 'n_mesas14'


#---------------------------------------------------------------------------------------
## PLOTS:
#
#---------------------------------------------------------------------------------------
tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
tm_shape(deptoShp) + 
  tm_borders(lwd = 3) 

tm_shape(deptoShp) + 
  tm_borders(col='black', lwd = 1) +
  tm_shape(controlShp) + 
  tm_polygons(col='red', alpha=.4)+
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/depto_control_91.pdf")

tm_shape(muniShp) + 
  tm_borders(col='black', lwd = 1) +
  tm_shape(controlShp) + 
  tm_polygons(col='red', alpha=.4)+
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/muni_control_91.pdf")

tm_shape(slvShp_segm_info) + 
  tm_polygons(col='men_lv2', title='Altitude', palette="-RdYlGn", colorNA = "white", textNA = "Missing data", n=10, style='pretty', border.col=NA, border.alpha=0)+
  tm_shape(controlShp) + 
  tm_borders(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red2", lwd=10, title="Guerrilla Control")+
  tm_shape(river1Shp)+
  tm_borders(col='deepskyblue3', lwd = 2, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="deepskyblue3", lwd=10, title="Main Rivers")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/elev_segm.png")

tm_shape(slvShp_segm_sample)+
  tm_fill(col='slateblue1', alpha=NA)+
  tm_add_legend(type="line", col="slateblue1", lwd=10, title="Sample of Census Tracts")+
  tm_shape(slvShp_segm_info) + 
  tm_borders()+
  tm_shape(control_line_sample) + 
  tm_lines(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_add_legend(type="line", col="red2", lwd=10, title="Guerrilla-Controlled Boundary")+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_sample.png")
  
tm_shape(slvShp_segm_info) + 
  tm_borders()+
  tm_shape(pnt_controlBrk_400)+
  tm_dots(size=0.3, col='red')+
  tm_add_legend(type="symbol", col="red", title="Border breaks")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/control_breaks.png")
  
  




sample<-subset(slvShp_segm_info_join, sample_reg==1)

#Using prediction on all census tracts 
tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(slvShp_segm_info_join) + 
  tm_polygons(col='arcsine_nl13_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.col=NA, border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/arcsine_nl13_xb_all.png")

tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(slvShp_segm_info_join) + 
  tm_polygons(col='nl13_density_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/nl13_density_xb_all.png")

tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(slvShp_segm_info_join) + 
  tm_polygons(col='z_wi_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/z_wi_xb_all.png")

tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(slvShp_segm_info_join) + 
  tm_polygons(col='mean_educ_years_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='fisher', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/mean_educ_years_xb_all.png")

#Using prediction only on census tracts within Cattaneo BW 
m<-tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(sample) + 
  tm_polygons(col='arcsine_nl13_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(m, filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/arcsine_nl13_xb_sample.png")

m<-tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(sample) + 
  tm_polygons(col='nl13_density_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(m, filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/nl13_density_xb_sample.png")

m<-tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(sample) + 
  tm_polygons(col='z_wi_xb', title='Quantile cuts', palette="plasma", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(m, filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/z_wi_xb_sample.png")

m<-tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(sample) + 
  tm_polygons(col='mean_educ_years_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='quantile', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(m, filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/mean_educ_years_xb_sample.png")



#Checking the sample border
tm_shape(y1) + 
  tm_polygons(col = "dst_cnt", lwd=0.02, title="",  palette =cm.colors(1), legend.show = FALSE)+
  tm_layout(frame = FALSE)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.show=FALSE, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_intersect.png")

tm_shape(y2) + 
  tm_polygons(col = "wthn_c2", lwd=0.02,  palette =cm.colors(1), legend.show = FALSE)+
  tm_layout(frame = FALSE)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(slvShp) + 
  tm_borders()+ 
  tm_layout(legend.show=FALSE, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/segm_centroid.png")




#Mesas:
tm_shape(slvShp_segm_info_join) + 
  tm_polygons(col='n_mesas14', title='Quantile cuts', palette="-Blues", colorNA = "white", textNA = "Missing data", n=1)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/mesas1.png")

tm_shape(slvShp_segm_info_join) + 
  tm_borders()+
  tm_shape(mesas14)+
  tm_dots(size=0.2, col='red')+
  tm_add_legend(type="symbol", col="red", title="Mesas 2014")+
  tm_layout(legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/mesas2.png")












#END.





