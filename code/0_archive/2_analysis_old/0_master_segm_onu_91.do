/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Guerillas_Development"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\GD-draft-slv"
	gl do "C:\Github\Guerrilla-development\code"
	
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
*Fix data and set coords in csv format to work in R 
do "${do}\1_preparing_data\FV_1_prepare_matricula_coords_07.do"
do "${do}\1_preparing_data\FV_1_prepare_victims_geocoded.do"

*NOTE: before running the NEXT do-files, should run the following R script that prepare
*      the GIS data. 
*			- FV_1_preparing_GIS_p1.R
*			- FV_1_preparing_GIS_p2.R
*			- FV_1_preparing_GIS_p3.R

*Preparing Population Census data
do "${do}\1_preparing_data\FV_1_prepare_census_07_segm_lvl.do"

*Preparing Lapop data
do "${do}\1_preparing_data\FV_1_prepare_lapop_segm_lvl.do"

*Merging all data together 
do "${do}\1_preparing_data\FV_1_prepare_night_light_13_segm_lvl.do"


*-------------------------------------------------------------------------------
*	 						   2. Analysis
*
*-------------------------------------------------------------------------------








do "${do}\2_analysis\20_segm_lvl_descriptives_onu_91_high_elev.do"
do "${do}\2_analysis\21_rdd_segm_lvl_local_continuity_onu_91_dvsnd_high_elev.do"
do "${do}\2_analysis\22_rdd_segm_lvl_night_light_onu_91_dvsnd_high_elev.do"
do "${do}\2_analysis\23_rdd_segm_lvl_mechanisms_onu_91_dvsnd_high_elev.do"
do "${do}\2_analysis\24_rdd_segm_lvl_mechanisms_warage_onu_91_dvsnd_high_elev.do"

end
*-------------------------------------------------------------------------------
*	 						   3. Robust Analysis
*
*-------------------------------------------------------------------------------
do "${do}\2_analysis\25_rdd_segm_lvl_local_continuity_onu_91_dvsnd_high_elev_robust.do"
do "${do}\2_analysis\26_rdd_segm_lvl_night_light_onu_91_dvsnd_high_elev_robust.do"
do "${do}\2_analysis\27_rdd_segm_lvl_mechanisms_onu_91_dvsnd_high_elev_robust.do"



*RUNNING THE LATEST ANALYSIS 
do "${do}\2_analysis\21_rdd_lc_all.do"
do "${do}\2_analysis\22_rdd_main_all.do"
do "${do}\2_analysis\23_rdd_ineq_all.do"
do "${do}\2_analysis\24_rdd_migr_all.do"
do "${do}\2_analysis\25_rdd_conflict_all.do"
do "${do}\2_analysis\26_rdd_public_all.do"
do "${do}\2_analysis\27_rdd_elec_all.do"
do "${do}\2_analysis\27_rdd_trust_all.do"
do "${do}\2_analysis\28_rdd_labor_all.do"

do "${do}\2_analysis\21_rdd_lc_all_elev.do"
do "${do}\2_analysis\22_rdd_main_all_elev.do"
do "${do}\2_analysis\23_rdd_ineq_all_elev.do"
do "${do}\2_analysis\24_rdd_migr_all_elev.do"
do "${do}\2_analysis\25_rdd_conflict_all_elev.do"
do "${do}\2_analysis\26_rdd_public_all_elev.do"
do "${do}\2_analysis\27_rdd_elec_all_elev.do"
do "${do}\2_analysis\27_rdd_trust_all_elev.do"
do "${do}\2_analysis\28_rdd_labor_all_elev.do"

do "${do}\2_analysis\22_rdd_main_all_82.do"





*END
