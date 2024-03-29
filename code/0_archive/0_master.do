/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "jmjimenez" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Guerillas_Development"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Apps\Overleaf\GD-draft-slv"
	gl do "C:\Users/`c(username)'\Documents\GitHub\Guerrilla-development\code"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\2-Data\Salvador"
gl maps "${localpath}\5-Maps\Salvador"
gl tables "${overleafpath}\tables"
gl plots "${overleafpath}\plots"

cd "${data}"

*Setting a pre-scheme for plots
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray


*-------------------------------------------------------------------------------
*	 						1. Preparing the Data
*
*-------------------------------------------------------------------------------
do "${do}\1_preparing_data\1_prepare_matricula_coords_07.do"
*NOTE: before running the do-files, should run the following R scripts that prepare
*      the GIS data. 
*			- 1_geo_fmln_zones_night_light_pixel_lvl.R
*			- 1_geo_fmln_zones_night_light_segm_lvl.R
*			- 1_geo_fmln_zones_night_light_pixel_lvl_onu_91.R
*			- 1_geo_fmln_zones_night_light_segm_lvl_onu_91.R

do "${do}\1_preparing_data\1_prepare_census_07_segm_lvl.do"
do "${do}\1_preparing_data\1_prepare_night_light_13_pixel_lvl.do"
do "${do}\1_preparing_data\1_prepare_night_light_13_segm_lvl.do"


*-------------------------------------------------------------------------------
*	 						   2. RDD Analysis
*
*-------------------------------------------------------------------------------
*Results using the 1981 map
*do "${do}\2_analysis\2_rdd_pixel_lvl.do"
*do "${do}\2_analysis\2_rdd_segm_lvl.do"
*do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms.do"

*Results using the 1982 map
do "${do}\2_analysis\2_rdd_pixel_lvl_cia_82_dvsnd.do"
do "${do}\2_analysis\2_rdd_pixel_lvl_cia_82_gvsng.do"
do "${do}\2_analysis\2_rdd_pixel_lvl_cia_82_gvsng_interac.do"

do "${do}\2_analysis\2_rdd_segm_lvl_cia_82_dvsnd.do"
do "${do}\2_analysis\2_rdd_segm_lvl_cia_82_gvsng.do"
do "${do}\2_analysis\2_rdd_segm_lvl_cia_82_gvsng_interac.do"

do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms_cia_82_dvsnd.do"
do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms_cia_82_gvsng.do"
do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms_cia_82_gvsng_interac.do"

*Results using the 1991 map
do "${do}\2_analysis\2_rdd_pixel_lvl_onu_91_dvsnd.do"
do "${do}\2_analysis\2_rdd_pixel_lvl_onu_91_gvsng.do"
do "${do}\2_analysis\2_rdd_pixel_lvl_onu_91_gvsng_interac.do"

do "${do}\2_analysis\2_rdd_segm_lvl_onu_91_dvsnd.do"
do "${do}\2_analysis\2_rdd_segm_lvl_onu_91_gvsng.do"
do "${do}\2_analysis\2_rdd_segm_lvl_onu_91_gvsng_interac.do"

do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms_onu_91_dvsnd.do"
do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms_onu_91_gvsng.do"
do "${do}\2_analysis\2_rdd_segm_lvl_mechanisms_onu_91_gvsng_interac.do"










gr close _all








*END
