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

disputaShp <- st_read(dsn = "gis/guerrilla_map", layer = "zona_fmln_onu_91")
st_crs(disputaShp) <- slv_crs

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

sample<-subset(slvShp_segm_info_join, sample_reg==1)

#Subseting to check the bordering segment 
y1<-subset(slvShp_segm_info_join, dst_cnt==0)
y2<-subset(slvShp_segm_info_join, dst_cn2<1250 & wthn_c2==1)
y_c<-subset(sample, within_control==0)
y_t<-subset(sample, within_control==1)
y_c2<-subset(slvShp_segm_info_join, z_run_cntrl<0 & z_run_cntrl>=-2 & within_control==0)
y_t2<-subset(slvShp_segm_info_join, z_run_cntrl>=0 & z_run_cntrl<=2 & within_control==1)
y_c4<-subset(slvShp_segm_info_join, z_run_cntrl<0 & z_run_cntrl>=-4 & within_control==0)
y_t4<-subset(slvShp_segm_info_join, z_run_cntrl>=0 & z_run_cntrl<=4 & within_control==1)

aggregate(slvShp_segm_info_join$z_run_cntrl, by=list(Category=slvShp_segm_info_join$within_control), FUN=min)
aggregate(slvShp_segm_info_join$z_run_cntrl, by=list(Category=slvShp_segm_info_join$within_control), FUN=max)
aggregate(slvShp_segm_info_join$z_run_cntrl, by=list(Category=slvShp_segm_info_join$within_control), FUN=mean)

#Mesas de votacion
mesas12 <- st_read(dsn = "gis/electoral_results", layer = "mesas2012")
mesas14 <- st_read(dsn = "gis/nl_segm_lvl_vars", layer = "mesas14_info_sp_onu_91")
mesas15 <- st_read(dsn = "gis/electoral_results", layer = "mesas2015")

shares09 <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/mesas09_sh.csv")
shares14 <- read.csv("C:/Users/jmjimenez/Dropbox/My-Research/Guerillas_Development/2-Data/Salvador/mesas14_sh.csv")

#Counting number of mesas per segment 
intersection <- st_intersection(x = slvShp_segm_info_join, y = mesas14)
int_result <- intersection %>% 
  group_by(SEG_ID) %>% 
  dplyr::summarise(n=n())

slvShp_segm_info_join<-st_join(slvShp_segm_info_join,int_result)
slvShp_segm_info_join <- subset(slvShp_segm_info_join, select = -SEG_ID.y)
names(slvShp_segm_info_join)[names(slvShp_segm_info_join) == 'SEG_ID.x'] <- 'SEG_ID'
names(slvShp_segm_info_join)[names(slvShp_segm_info_join) == 'n'] <- 'n_mesas14'

#Joining mesas to voting shares 
mesas14_join09 <- left_join(mesas14, shares09, by = c("Name" = "mesa_shape"))
mesas14_join14 <- left_join(mesas14, shares14, by = c("Name" = "mesa_shape"))

mesas14_join09 <- na.omit(mesas14_join09, col="sh_left")
mesas14_join14 <- na.omit(mesas14_join14, col="sh_left")

winl09<-subset(mesas14_join09, win_left==1)
winr09<-subset(mesas14_join09, win_left==0)
winl14<-subset(mesas14_join14, win_left==1)
winr14<-subset(mesas14_join14, win_left==0)


#---------------------------------------------------------------------------------------
## PLOTS:
#
#---------------------------------------------------------------------------------------
tm_shape(slvShp) + 
  tm_borders(col='black', lwd = .5) +
  tm_shape(disputaShp) + 
  tm_polygons(col='pink', lwd=1, alpha=.7)+
  tm_add_legend(type="line", col="pink", lwd=10, title="Disputed Area")+
  tm_shape(controlShp) + 
  tm_polygons(col='red', lwd=1, alpha=.7)+
  tm_add_legend(type="line", col="red", lwd=10, title="Under Guerrilla Control")+
  tm_layout(frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/control_disputed_91.pdf")

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

tm_shape(control_line_sample) + 
  tm_lines()+
  tm_shape(slvShp_segm_info_join) + 
  tm_polygons(col='literacy_rate_xb', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=10, style='fisher', border.alpha=0)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/literacy_rate_xb_all.png")


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



tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_shape(winr09)+
  tm_dots(size=0.4, col='blue2', alpha = 0.4)+
  tm_shape(winl09)+
  tm_dots(size=0.6, col='red3')+
  tm_add_legend(type="symbol", col="red3", title="Won left in 2009")+
  tm_layout(legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/mesas09_left.png")

tm_shape(slvShp) + 
  tm_borders()+
  tm_shape(winr14)+
  tm_dots(size=0.4, col='blue2', alpha = 0.4)+
  tm_shape(winl14)+
  tm_dots(size=0.6, col='red3', alpha = 0.4)+
  tm_add_legend(type="symbol", col="red3", title="Won left in 2014")+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 2, lty = "solid", alpha = NA) +
  tm_layout(legend.title.size =1, frame = FALSE)
tmap_save(filename="C:/Users/jmjimenez/Dropbox/Apps/Overleaf/GD-draft-slv/plots/mesas14_left.png")









#END.



#Using prediction only on census tracts within Cattaneo BW 
  tm_shape(sample) + 
  tm_polygons(col='within_control', title='Quantile cuts', palette="inferno", colorNA = "white", textNA = "Missing data", n=2, border.alpha=0)

      tm_shape(control_line_sample) + 
  tm_lines(col='red', lwd = 3, lty = "solid", alpha = NA)+
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(legend.outside = TRUE, legend.outside.position = "left", legend.outside.size=0.12, legend.title.size =1, frame = FALSE)

tm_shape(y_c)+
  tm_fill(col='slateblue1', alpha=NA)+
  tm_shape(y_t)+
  tm_fill(col='pink', alpha=.5)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red2', lwd = 3, lty = "solid", alpha = NA) 
  
tm_shape(y_c2)+
  tm_fill(col='slateblue1', alpha=NA)+
  tm_shape(y_t2)+
  tm_fill(col='pink', alpha=.5)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red2', lwd = 3, lty = "solid", alpha = NA) 

tm_shape(y_c4)+
  tm_fill(col='slateblue1', alpha=NA)+
  tm_shape(y_t4)+
  tm_fill(col='pink', alpha=.5)+
  tm_shape(control_line_sample) + 
  tm_lines(col='red2', lwd = 3, lty = "solid", alpha = NA) +
  tm_shape(controlShp) + 
  tm_borders(col='red', lwd = 3, lty = "dotted")+
  tm_layout(frame = FALSE)+
  tm_shape(slvShp_segm_info) + 
  tm_borders()+

  
  
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







