/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


import excel "${data}\gis\landuse\segm_permanentes.xls", sheet("segm_permanentes") firstrow clear

ren _all, low
ren (seg_id area percentage) (segm_id perm_area perm_sh)

tempfile P
save `P', replace 

import excel "${data}\gis\landuse\segm_anuales.xls", sheet("segm_anuales") firstrow clear

ren _all, low
ren (seg_id area percentage) (segm_id anual_area anual_sh)

tempfile A
save `A', replace 

import excel "${data}\gis\landuse\segm_granosbasicos.xls", sheet("segm_granosbasicos") firstrow clear

ren _all, low
ren (seg_id area percentage) (segm_id grain_area grain_sh)

tempfile G
save `G', replace 

import excel "${data}\gis\landuse\segm_canadeazucar.xls", sheet("segm_canadeazucar") firstrow clear

ren _all, low
ren (seg_id area percentage) (segm_id sug_area sug_sh)

tempfile Z
save `Z', replace 

import excel "${data}\gis\landuse\segm_cafe.xls", sheet("segm_cafe") firstrow clear

ren _all, low
ren (seg_id area percentage) (segm_id cof_area cof_sh)

tempfile C
save `C', replace 

*Merging to de main dataset
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

drop _merge

merge 1:1 segm_id using `P', nogen 
merge 1:1 segm_id using `A', nogen
merge 1:1 segm_id using `G', nogen 
merge 1:1 segm_id using `Z', nogen 
merge 1:1 segm_id using `C', nogen 

*Fixing vars
foreach var in perm_sh anual_sh grain_sh sug_sh cof_sh{
*	replace `var'=0 if `var'==.
	summ `var', d
	*gen d_`var'=(`var'> `r(p10)') if `var'!=. 
	gen d_`var'=(`var'>= 5) if `var'!=. 
	replace d_`var'=0 if d_`var'==.
}


/*end
replace perm_sh=0 if perm_sh==.
replace anual_sh=0 if anual_sh==.
replace grain_sh=0 if grain_sh==.
replace sug_sh=0 if sug_sh==.
replace cof_sh=0 if cof_sh==.

gen d_perm=(perm_sh>0) if perm_sh!=. 
gen d_anual=(anual_sh>0) if anual_sh!=.
gen d_grain=(grain_sh>0) if grain_sh!=.
gen d_sug=(sug_sh>0) if sug_sh!=.
gen d_cof=(cof_sh>0) if cof_sh!=.
*/

la var d_perm "Has permanent crop"
la var d_anual "Has anual crop"
la var d_grain "Has Basic grains crop"
la var d_sug "Has sugar crop"
la var d_cof "Has coffee crop"

la var perm_sh "Permanent area share"
la var anual_sh "Anual area share"
la var grain_sh "Grain area share"
la var sug_sh "Sugarcane area share"
la var cof_sh "Coffee area share"


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
 *Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
 

*-------------------------------------------------------------------------------
* 							(Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_crop_area_p1.tex"
cap erase "${tables}\rdd_crop_area_p1.txt"
cap erase "${tables}\rdd_crop_area_p2.tex"
cap erase "${tables}\rdd_crop_area_p2.txt"

gl crop1 "d_perm d_anual d_grain d_sug d_cof"
gl crop2 "perm_sh anual_sh grain_sh sug_sh cof_sh"

foreach var of global crop1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_crop_area_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global crop2{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_crop_area_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}






/*
end
reghdfe d_sug ${controls} [aw=tweights], vce(r) a(i.${breakfe}) resid

reghdfe d_grain ${controls}, vce(r) noabs resid

reghdfe d_grain ${controls} [aw=tweights] ${if}, vce(r) noabs resid

reghdfe d_sug ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
reghdfe d_grain ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid

reghdfe d_perm ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
reghdfe d_anual ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid

ttest d_sug ${if}, by(within_control)
ttest d_grain ${if}, by(within_control)


rdrobust sug_sh z_run_cntrl, all kernel(triangular)
gl h=20
gl b=e(b_l)
*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
reghdfe sug_sh ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid




*END

