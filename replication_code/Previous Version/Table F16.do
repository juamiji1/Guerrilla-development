/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if // "if abs(z_run_cntrl)<=${h}" Delete restriction to estimate an OLS

*Replicating triangular weights
cap drop tweights
tempvar absz
gen `absz'=abs(z_run_cntrl)
sum `absz'
gl h=r(max)
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var mean_educ_years "Years of Education (2007)"
la var z_wi "Wealth Index (2007)"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl1 "arcsine_nl13 mean_educ_years z_wi"

*Erasing table before exporting
local r replace

foreach var of global nl1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_main_all_OLS_draft.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nor2 nocons append 
	
}

preserve 
  insheet using "${tables}/rdd_main_all_OLS_draft.txt", nonames clear
 drop v2

replace v3 = "Night Light Luminosity" in 1
replace v4 = "" in 1
replace v4 = "" in 2
replace v4 = "Wealth Index" in 1
replace v5 = "" in 2
replace v5 = "Years of Education" in 1
insobs 1, before(4)
replace v1 = "" in 2
replace v3 = "(2013)" in 2
replace v4 = "(2007)" in 2
replace v5 = "(2007)" in 2
replace v3 = "(1)" in 3
replace v4 = "(2)" in 3
replace v5 = "(3)" in 3
replace v1= "Guerrilla control" in 5

dataout, tex save("${tables}/rdd_main_all_OLS_draft") replace nohead midborder(3)
 
restore
