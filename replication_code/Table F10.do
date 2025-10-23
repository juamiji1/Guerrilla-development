/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Robusteness test using elevation differences 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* Preparing the data to have a structure where the unit of observation is the 
* pair of census tracts that are neighbors 
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

gen estsample=1 if abs(z_run_cntrl)<=${h}

keep segm_id arcsine_nl13 nl13_density wmean_nl1 elevation2 within_control z_run_cntrl z_wi mean_educ_years estsample control_break_fe_400

tempfile INFO
save `INFO', replace 

*Importing neighbo matrices 
import excel "${data}\nbr_matrix_p3.xls", sheet("nbr_matrix_p3") firstrow clear

tempfile P3
save `P3', replace 

import excel "${data}\nbr_matrix_p2.xls", sheet("nbr_matrix_p2") firstrow clear

tempfile P2
save `P2', replace 

import excel "${data}\nbr_matrix_p1.xls", sheet("nbr_matrix_p1") firstrow clear
append using `P2' `P3'

ren (src_SEG_ID nbr_SEG_ID) (segm_id_cntr segm_id)

drop OBJECTID LENGTH NODE_COUNT

*Merging info of pairs
merge m:1 segm_id using `INFO', keep(3) nogen 
ren (arcsine_nl13 nl13_density wmean_nl1 elevation2 within_control z_run_cntrl z_wi mean_educ_years estsample control_break_fe_400) nbr_=
ren segm_id segm_id_nbr 
ren segm_id_cntr segm_id

merge m:1 segm_id using `INFO', keep(3) nogen 

*Calculating the differences 
gen diff_elevation2= elevation2 - nbr_elevation2
gen diff_nl13_density= nl13_density - nbr_nl13_density
gen diff_arcsine_nl13= arcsine_nl13 - nbr_arcsine_nl13
gen diff_wmean_nl1= wmean_nl1-nbr_wmean_nl1
gen diff_z_wi= z_wi - nbr_z_wi
gen diff_mean_educ_years= mean_educ_years - nbr_mean_educ_years

*Keeping only the pair of neighbors that have the positive difference in alttitud 
keep if diff_elevation2>0

summ diff_elevation2, d

*-------------------------------------------------------------------------------
* Sample of neighbor pairs with a difference between 15 and 20 masl
*-------------------------------------------------------------------------------
gen sample=1 if diff_elevation2>=15 & diff_elevation2<21

reg diff_arcsine_nl13 if sample==1 & within_control==0 & nbr_within_control==0, r
reg diff_nl13_density if sample==1 & within_control==0 & nbr_within_control==0, r
reg diff_wmean_nl1 if sample==1 & within_control==0 & nbr_within_control==0, r

*Arcsine results
reg diff_elevation2 if sample==1, r
outreg2 using "${tables}/rdd_all_elev_placebo_p1.tex", tex(frag) replace nor2 
reg diff_arcsine_nl13 if sample==1, r
outreg2 using "${tables}/rdd_all_elev_placebo_p1.tex", tex(frag) append nor2
reg diff_arcsine_nl13 if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_elev_placebo_p1.tex", tex(frag) append nor2

*-------------------------------------------------------------------------------
* Sample of neighbor pairs with a difference between 21 and 100 masl
*-------------------------------------------------------------------------------
*Arcsine results
reg diff_elevation2 if diff_elevation2>=20  & diff_elevation2<=100, r
outreg2 using "${tables}/rdd_all_elev_placebo_p1.tex", tex(frag) append nor2
reg diff_arcsine_nl13 if diff_elevation2>=20  & diff_elevation2<=100, r
outreg2 using "${tables}/rdd_all_elev_placebo_p1.tex", tex(frag) append nor2
reg diff_arcsine_nl13 if diff_elevation2>=20  & diff_elevation2<=100 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_elev_placebo_p1.tex", tex(frag) append nor2


*Education years results
reg diff_mean_educ_years if sample==1, r
outreg2 using "${tables}/rdd_all_elev_placebo_p2.tex", tex(frag) replace nor2
reg diff_mean_educ_years if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_elev_placebo_p2.tex", tex(frag) append nor2
reg diff_mean_educ_years if diff_elevation2>=20 & diff_elevation2<=100, r
outreg2 using "${tables}/rdd_all_elev_placebo_p2.tex", tex(frag) append nor2
reg diff_mean_educ_years if diff_elevation2>=20 & diff_elevation2<=100 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_elev_placebo_p2.tex", tex(frag) append nor2

*Wealth Score results
reg diff_z_wi if sample==1
outreg2 using "${tables}/rdd_all_elev_placebo_p3.tex", tex(frag) replace nor2
reg diff_z_wi if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_elev_placebo_p3.tex", tex(frag) append nor2
reg diff_z_wi if diff_elevation2>=20 & diff_elevation2<=100, r
outreg2 using "${tables}/rdd_all_elev_placebo_p3.tex", tex(frag) append nor2
reg diff_z_wi if diff_elevation2>=20 & diff_elevation2<=100 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_elev_placebo_p3.tex", tex(frag) append nor2

