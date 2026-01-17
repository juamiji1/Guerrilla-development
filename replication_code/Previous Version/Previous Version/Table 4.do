/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Collapsing 2007 census to the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

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
gl if "if abs(z_run_cntrl)<=${h}"
*-------------------------------------------------------------------------------
* 					     		Population 
*	
*-------------------------------------------------------------------------------
*use "${data}/censo2007/data/poblacion.dta", clear // Uncomment when full data is available
use "${data}/censo2007/data/poblacion.dta", clear 


*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*School age at war time
gen notschl_age_war1=1 if S06P03A>=15	& 	S06P03A<30	  // 20-29 in 2007
gen notschl_age_war2=1 if S06P03A>=30	& 	S06P03A<45	  // 30-44 in 2007
gen notschl_age_war3=1 if S06P03A>=45	& 	S06P03A<61	  // 45-60 in 2007
gen notschl_age_war4=1 if S06P03A>=61	& 	S06P03A<.	  // 60+ in 2007


local r replace
forvalues j=1/4 {
preserve 
	keep if notschl_age_war`j'==1
	
	*Collapsing at the segment level 
	collapse (mean) mean_educ_years=S06P11A, by(segm_id)

	merge 1:1 segm_id using "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", keepusing(control_break_fe_400 within_control z_run_cntrl) nogen

	
	*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}


*Table
	reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ mean_educ_years if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_educ_cohorts.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	
restore
local r append
}



preserve 
  insheet using "${tables}/rdd_educ_cohorts.txt", nonames clear
 drop v2

replace v1 = "" in 2
replace v1 = "Guerrilla control" in 4
replace v1 = "Decided Schooling" in 1
replace v3 = "After" in 1
replace v4 = "During" in 1
replace v5 = "Just Before" in 1
replace v6 = "Before" in 1
replace v3 = "(1)" in 2
replace v4 = "(2)" in 2
replace v5 = "(3)" in 2
replace v6 = "(4)" in 2


dataout, tex save("${tables}/rdd_educ_cohorts") replace nohead  midborder(2)
 
restore



*END
