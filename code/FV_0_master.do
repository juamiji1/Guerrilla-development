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
*-------------------------------------------------------------------------------
*Fix data and set coords in csv format to work in R 
*-------------------------------------------------------------------------------
do "${do}\1_preparing_data\FV_1_prepare_matricula_coords_07.do"
do "${do}\1_preparing_data\FV_1_prepare_victims_geocoded.do"

*-------------------------------------------------------------------------------
*Preparing Geospatial data in R
*-------------------------------------------------------------------------------
*NOTE: before running the NEXT do-files, should run the following R script that prepare
*      the GIS data. 
*			- FV_1_preparing_GIS_p1.R
*			- FV_1_preparing_GIS_p2.R
*			- FV_1_preparing_GIS_p3.R
*			- FV_1_prepare_GIS_canton.R
*           - FV_1_preparing_polling_stations.R

*-------------------------------------------------------------------------------
*Preparing and merging data at the segment level (census tract)
*-------------------------------------------------------------------------------
*Preparing Population Census data
do "${do}\1_preparing_data\FV_1_prepare_census_07_segm_lvl.do"

*Preparing Lapop data
do "${do}\1_preparing_data\FV_1_prepare_lapop_segm_lvl.do"

*Preparing EHPM data from Lelys WB panel
do "${do}\1_preparing_data\FV_1_prepare_ephm_segm_lvl.do"

*Preparing EHPM data from raw files
do "${do}\1_preparing_data\FV_1_prepare_ephm_sc_segm_lvl.do"

*Merging all data together 
do "${do}\1_preparing_data\FV_1_prepare_night_light_13_segm_lvl.do"

*-------------------------------------------------------------------------------
*Preparing and merging data at the polling station level 
*-------------------------------------------------------------------------------
*Presidential elections data from 2009
do "${do}\1_preparing_data\FV_1_preparing_voting09.do"

*Mayor elections data from 2014
do "${do}\1_preparing_data\FV_1_preparing_voting14.do"

*Presidential elections data from 2015
do "${do}\1_preparing_data\FV_1_preparing_voting15.do"


*-------------------------------------------------------------------------------
*	 						   2. Analysis
*
*-------------------------------------------------------------------------------
*Local continuity 
do "${do}\2_analysis\FV_2_rdd_lc_all.do"

*Main outcomes results
do "${do}\2_analysis\FV_2_rdd_main_all.do"

*NL estimates over time 
do "${do}\2_analysis\FV_2_rdd_nltime_all.do"

*Robustness of main outcomes by trimming tails of distribution usin migration rates
do "${do}\2_analysis\FV_2_rdd_educ_trimm_all.do"

*Trust an attitudes results 
do "${do}\2_analysis\FV_2_rdd_trust_all.do"

*Trust an attitudes results but calculating the inner sample ICW 
do "${do}\2_analysis\FV_2_rdd_trust_rdsample_all.do"

*Public good provision results
do "${do}\2_analysis\FV_2_rdd_public_all.do"

*Plot size and Simpson Index results
do "${do}\2_analysis\FV_2_rdd_plotsize_cenagro_all.do"

*Agricultural productivity results (FAO data)
do "${do}\2_analysis\FV_2_rdd_yield_all.do"

*Migration outcomes results
do "${do}\2_analysis\FV_2_rdd_migr_all.do"

*Using disputed areas and Donut Hole results
do "${do}\2_analysis\FV_2_rdd_conflict_all.do"

*Geolocalized victims results
do "${do}\2_analysis\FV_2_rdd_victimsgeo_all.do"

*External validity plots for Main results
do "${do}\2_analysis\FV_2_external_validity_plots_all.do"

*Education by cohort and quality of teachers' results (Censuses data)
do "${do}\2_analysis\FV_2_rdd_educage_all.do"

*Main outcomes results but with Conley SE
do "${do}\2_analysis\FV_2_rdd_main_all_conley.do"

*Placebo test to dicard altitude as driver of the effects
do "${do}\2_analysis\FV_2_elev_robustness_test.do"

*Main outcomes results for population that always lived in the same place
do "${do}\2_analysis\FV_2_rdd_main_all_always.do"

*Structural transformation results using occupation in ISIC v4
do "${do}\2_analysis\FV_2_rdd_isic_all.do"

*Inequality of real percapita income at the canton level 
do "${do}\2_analysis\FV_2_rdd_ineq_canton_all.do"

*Inequality of real percapita income and wealth index at the census tract level
do "${do}\2_analysis\FV_2_rdd_ineq_all.do"

*Agricultural cooperatives results
do "${do}\2_analysis\FV_2_rdd_coop_cenagro_all.do"

*Density and Mccrary tests 
do "${do}\2_analysis\FV_2_rdd_mccrary_all.do"

*Electoral outcomes results
do "${do}\2_analysis\FV_2_rdd_elec_all.do"

*Labor Market outcomes results
do "${do}\2_analysis\FV_2_rdd_labor_all.do"

*Heterogeneity of main outcomes by baseline characteristics of landlocked and distances
do "${do}\2_analysis\FV_2_rdd_basehet_all.do"

*Homicides and extorsions outcomes results
do "${do}\2_analysis\FV_2_rdd_crime_all.do"

*Different polynomials, kernels, and weights for main outcomes results
do "${do}\2_analysis\FV_2_rdd_main_robust_all.do"

*Public investment projects results (FISDL data)
do "${do}\2_analysis\FV_2_rdd_fisdl_all.do"

*Presence of police station results
do "${do}\2_analysis\FV_2_rdd_pnc_all.do"

*Presence of commercial stablishments' results
do "${do}\2_analysis\FV_2_rdd_cestablishments_all.do"

*Education by cohorts results (EHPM data)
do "${do}\2_analysis\FV_2_rdd_ehpm_educyrs_all.do"

*Simpson Index results at the canton level
do "${do}\2_analysis\FV_2_siindex_canton_cenagro_all.do"

*Ownership of producers results (CENAGRO data)
do "${do}\2_analysis\FV_2_rdd_owner_cenagro_all.do"

*Agricultural productivity results (CENAGRO data)
do "${do}\2_analysis\FV_2_rdd_yield_cenagro_all.do"


*-------------------------------------------------------------------------------
*	 						   3. Others
*
*-------------------------------------------------------------------------------
*Predicting outcomes using RDD at the census tract level 
do "${do}\2_analysis\FV_3_predicted_outcomes_all.do"

*Mapping the results in R 
*			- FV_3_predicted_outcomes_maps.R










*END
