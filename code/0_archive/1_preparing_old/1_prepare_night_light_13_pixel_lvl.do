/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Preparing night light dat at the pixel level 
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
shp2dta using "${data}/gis\nl_pixel_lvl_vars\nl13Shp_pixels_info_sp", data("${data}/temp\nl13Shp_pixels_info.dta") coord("${data}/temp\nl13Shp_pixels_info_coord.dta") genid(pixel_id) genc(coord) replace 
shp2dta using "${data}/gis\nl_pixel_lvl_vars\nl13Shp_pixels_info_sp_onu_91", data("${data}/temp\nl13Shp_pixels_info_onu_91.dta") coord("${data}/temp\nl13Shp_pixels_info_coord_onu_91.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\nl13Shp_pixels_info", clear

*Renaming variables
rename (value wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_lv men_lv2 men_slp mean_cc mean_bn lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2 wthn_c3 wthn_x3 wthn_d3 rail_nt road_nt ds_1000 brk1000 dst_400 brkf400 dst_200 brkf200 dst_100 brkf100 dst_b50 brkfe50 dst_b25 brkfe25 dst_b10 brkfe10 cnt_200 cntr200 cnt_100 cntr100 cntr_50 cntrl50) (nl13_density within_control within_expansion within_disputed dist_control dist_expansion dist_disputed elevation elevation2 slope cacao bean lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 within_control_v3 within_expansion_v3 within_disputed_v3 rail roads dist_disputa_breaks_1000 disputa_break_fe_1000 dist_disputa_breaks_400 disputa_break_fe_400 dist_disputa_breaks_200 disputa_break_fe_200 dist_disputa_breaks_100 disputa_break_fe_100 dist_disputa_breaks_50 disputa_break_fe_50 dist_disputa_breaks_25 disputa_break_fe_25 dist_disputa_breaks_10 disputa_break_fe_10 dist_control_breaks_200 control_break_fe_200 dist_control_breaks_100 control_break_fe_100 dist_control_breaks_50 control_break_fe_50)

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.

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
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 

gen z_run_xpsn_v2= dist_expansion_v2 
replace z_run_xpsn_v2= -1*dist_expansion_v2 if within_expansion_v2==0

gen z_run_dsptd_v2= dist_disputed_v2 
replace z_run_dsptd_v2= -1*dist_disputed_v2 if within_disputed_v2==0

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

*Fixing the new data
gen within_fmln=(within_disputed==1 | within_control==1)
rename z_run_dsptd z_run_fmln
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
la var within_disputed "Pixel within disputed zone (intersection)"
la var within_control_v2 "Pixel within control zone (intersection)"
la var within_expansion_v2 "Pixel within expansion zone (intersection)" 
la var within_disputed_v2 "Pixel within disputed zone (intersection)"
la var within_fmln "Within any FMLN zone"
la var within_control "Within FMLN-dominated zone"

*Saving the data 
save "${data}/night_light_13_pxl_lvl.dta", replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\nl13Shp_pixels_info_onu_91", clear

*Renaming variables
rename (value wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_lv men_lv2 men_slp mean_cac mean_bn lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2 wthn_c3 wthn_x3 wthn_d3 rail_nt road_nt ds_1000 brk1000 dst_400 brkf400 dst_200 brkf200 dst_100 brkf100 dst_b50 brkfe50 dst_b25 brkfe25 dst_b10 brkfe10 cnt_200 cntr200 cnt_100 cntr100 cntr_50 cntrl50 mean_coc men_cff mn_cttn men_drc mean_mz men_bn2 mn_sgrc men_wrc sm_dhyd sm_kmhy) (nl13_density within_control within_expansion within_disputed dist_control dist_expansion dist_disputed elevation elevation2 slope cacao bean lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 within_control_v3 within_expansion_v3 within_disputed_v3 rail roads dist_disputa_breaks_1000 disputa_break_fe_1000 dist_disputa_breaks_400 disputa_break_fe_400 dist_disputa_breaks_200 disputa_break_fe_200 dist_disputa_breaks_100 disputa_break_fe_100 dist_disputa_breaks_50 disputa_break_fe_50 dist_disputa_breaks_25 disputa_break_fe_25 dist_disputa_breaks_10 disputa_break_fe_10 dist_control_breaks_200 control_break_fe_200 dist_control_breaks_100 control_break_fe_100 dist_control_breaks_50 control_break_fe_50 mean_cocoa mean_coffee mean_cotton mean_dryrice mean_maize mean_bean2 mean_sugarcane mean_wetrice sum_dhydro sum_kmhydro)

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.

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
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 

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

*Saving the data 
save "${data}/night_light_13_pxl_lvl_onu_91.dta", replace 





*END
