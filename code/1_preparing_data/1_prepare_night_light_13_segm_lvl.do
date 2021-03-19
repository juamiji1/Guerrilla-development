/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Preparing night light dat at the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

/*gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development\code"
gl path "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}
*/


*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
shp2dta using "${data}/gis\nl_segm_lvl_vars\slvShp_segm_info_sp", data("${data}/temp\slvShp_segm_info_sp.dta") coord("${data}/temp\slvShp_segm_info_coord.dta") genid(pixel_id) genc(coord) replace 
shp2dta using "${data}/gis\nl_segm_lvl_vars\slvShp_segm_info_sp_onu_91", data("${data}/temp\slvShp_segm_info_sp_onu_91.dta") coord("${data}/temp\slvShp_segm_info_coord_onu_91.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_segm_info_sp.dta", clear

*Keeping only important vars 
rename (SEG_ID wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_nl mean_lv mean_cc mean_bn wmn_nl1 mn_nl_z wmn_nl_ sm_lv_1 sm_lv_2 sm_lv_3 sm_lv_4 men_nl2 men_lv2 wmn_nl2 wmn_lv2 lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2 rail_nt road_nt n_hosp n_sch matricl ds_1000 brk1000 dst_400 brkf400 dst_200 brkf200 dst_100 brkf100 dst_b50 brkfe50 dst_b25 brkfe25 dst_b10 brkfe10) (segm_id within_control within_expansion within_disputed dist_control dist_expansion dist_disputed nl13_density elevation cacao bean wmean_nl1 mean_nl_z wmean_nl_z sum_elev_1 sum_elev_2 sum_elev_3 sum_elev_4 mean_nl2 mean_elev2 wmean_nl2 wmean_elev2 lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 rail roads total_hospitals total_schools total_matricula dist_disputa_breaks_1000 disputa_break_fe_1000 dist_disputa_breaks_400 disputa_break_fe_400 dist_disputa_breaks_200 disputa_break_fe_200 dist_disputa_breaks_100 disputa_break_fe_100 dist_disputa_breaks_50 disputa_break_fe_50 dist_disputa_breaks_25 disputa_break_fe_25 dist_disputa_breaks_10 disputa_break_fe_10) 

keep segm_id within_control within_expansion within_disputed dist_control dist_expansion dist_disputed nl13_density elevation cacao bean wmean_nl1 mean_nl_z wmean_nl_z sum_elev_1 sum_elev_2 sum_elev_3 sum_elev_4 mean_nl2 mean_elev2 wmean_nl2 wmean_elev2 lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 rail roads total_hospitals total_schools total_matricula dist_disputa_breaks_* disputa_break_fe_* x_coord y_coord 

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.

*Fixing missings 
replace total_hospitals=0 if total_hospitals==.
replace total_schools=0 if total_schools==.
replace total_matricula=0 if total_matricula==.

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_expansion=dist_expansion/1000
replace dist_disputed=dist_disputed/1000

replace dist_control_v2=dist_control_v2/1000
replace dist_expansion_v2=dist_expansion_v2/1000
replace dist_disputed_v2=dist_disputed_v2/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn= dist_expansion 
replace z_run_xpsn= -1*dist_expansion if within_expansion==0

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)

*Fixing the running variables (version 2)
gen z_run_cntrl_v2= dist_control_v2 
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn_v2= dist_expansion_v2 
replace z_run_xpsn_v2= -1*dist_expansion_v2 if within_expansion_v2==0

gen z_run_dsptd_v2= dist_disputed_v2 
replace z_run_dsptd_v2= -1*dist_disputed_v2 if within_disputed_v2==0

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

*Labelling for results 
la var nl13_density "Night light density (2013)"
la var z_run_cntrl "Distance to nearest control zone (border to border)"
la var z_run_xpsn "Distance to nearest expansion zone (border to border)"
la var z_run_dsptd "Distance to nearest disputed zone (border to border)"
la var z_run_cntrl_v2 "Distance to nearest control zone (centroid to border)"
la var z_run_xpsn_v2 "Distance to nearest expansion zone (centroid to border)"
la var z_run_dsptd_v2 "Distance to nearest disputed zone (centroid to border)"
la var within_control "Pixel within control zone (intersection)"
la var within_expansion "Pixel within expansion zone (intersection)" 
la var within_disputed "Pixel within disputed zone (intersection)"
la var within_control_v2 "Pixel within control zone (intersection)"
la var within_expansion_v2 "Pixel within expansion zone (intersection)" 
la var within_disputed_v2 "Pixel within disputed zone (intersection)"


*-------------------------------------------------------------------------------
* 					Merging the census 2007 data 
*
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 segm_id using "${data}/temp\census07_segm_lvl.dta", nogen 


*Saving the data 
save "${data}/night_light_13_segm_lvl.dta", replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_segm_info_sp_onu_91.dta", clear

*Keeping only important vars 
rename (SEG_ID wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_nl mean_lv mean_cc mean_bn wmn_nl1 mn_nl_z wmn_nl_ sm_lv_1 sm_lv_2 sm_lv_3 sm_lv_4 men_nl2 men_lv2 wmn_nl2 wmn_lv2 lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2 rail_nt road_nt n_hosp n_sch matricl ds_1000 brk1000 dst_400 brkf400 dst_200 brkf200 dst_100 brkf100 dst_b50 brkfe50 dst_b25 brkfe25 dst_b10 brkfe10 cnt_200 cntr200 cnt_100 cntr100 cntr_50 cntrl50) (segm_id within_control within_expansion within_disputed dist_control dist_expansion dist_disputed nl13_density elevation cacao bean wmean_nl1 mean_nl_z wmean_nl_z sum_elev_1 sum_elev_2 sum_elev_3 sum_elev_4 mean_nl2 mean_elev2 wmean_nl2 wmean_elev2 lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 rail roads total_hospitals total_schools total_matricula dist_disputa_breaks_1000 disputa_break_fe_1000 dist_disputa_breaks_400 disputa_break_fe_400 dist_disputa_breaks_200 disputa_break_fe_200 dist_disputa_breaks_100 disputa_break_fe_100 dist_disputa_breaks_50 disputa_break_fe_50 dist_disputa_breaks_25 disputa_break_fe_25 dist_disputa_breaks_10 disputa_break_fe_10 dist_control_breaks_200 control_break_fe_200 dist_control_breaks_100 control_break_fe_100 dist_control_breaks_50 control_break_fe_50) 

keep segm_id within_control within_expansion within_disputed dist_control dist_expansion dist_disputed nl13_density elevation cacao bean wmean_nl1 mean_nl_z wmean_nl_z sum_elev_1 sum_elev_2 sum_elev_3 sum_elev_4 mean_nl2 mean_elev2 wmean_nl2 wmean_elev2 lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 rail roads total_hospitals total_schools total_matricula dist_disputa_breaks_* disputa_break_fe_* x_coord y_coord dist_control_breaks_* control_break_fe_* 

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.

*Fixing missings 
replace total_hospitals=0 if total_hospitals==.
replace total_schools=0 if total_schools==.
replace total_matricula=0 if total_matricula==.

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_expansion=dist_expansion/1000
replace dist_disputed=dist_disputed/1000

replace dist_control_v2=dist_control_v2/1000
replace dist_expansion_v2=dist_expansion_v2/1000
replace dist_disputed_v2=dist_disputed_v2/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn= dist_expansion 
replace z_run_xpsn= -1*dist_expansion if within_expansion==0

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)

*Fixing the running variables (version 2)
gen z_run_cntrl_v2= dist_control_v2 
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn_v2= dist_expansion_v2 
replace z_run_xpsn_v2= -1*dist_expansion_v2 if within_expansion_v2==0

gen z_run_dsptd_v2= dist_disputed_v2 
replace z_run_dsptd_v2= -1*dist_disputed_v2 if within_disputed_v2==0

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

*Fixing the new data
replace within_disputed=1 if within_control==1 & within_disputed==0
rename (within_disputed z_run_dsptd) (within_fmln z_run_fmln)
rename disputa_* fmln_*

*Labelling for results 
la var nl13_density "Night light density (2013)"
la var z_run_cntrl "Distance to nearest control zone (border to border)"
la var z_run_xpsn "Distance to nearest expansion zone (border to border)"
la var z_run_dsptd "Distance to nearest disputed zone (border to border)"
la var z_run_cntrl_v2 "Distance to nearest control zone (centroid to border)"
la var z_run_xpsn_v2 "Distance to nearest expansion zone (centroid to border)"
la var z_run_dsptd_v2 "Distance to nearest disputed zone (centroid to border)"
*la var within_control "Pixel within control zone (intersection)"
la var within_expansion "Pixel within expansion zone (intersection)" 
*la var within_disputed "Pixel within disputed zone (intersection)"
la var within_control_v2 "Pixel within control zone (intersection)"
la var within_expansion_v2 "Pixel within expansion zone (intersection)" 
la var within_disputed_v2 "Pixel within disputed zone (intersection)"

la var within_fmln "Within any FMLN zone"
la var within_control "Within FMLN-dominated zone"

*-------------------------------------------------------------------------------
* 					Merging the census 2007 data 
*
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 segm_id using "${data}/temp\census07_segm_lvl.dta", nogen 


*Saving the data 
save "${data}/night_light_13_segm_lvl_onu_91.dta", replace 






*END
