/*-----------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating the RDD predictions 
DATE:

NOTES: I merged region to the night_light_13_segm_lvl_onu_91_nowater.dta to 
create sample_try.dta
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Preparing the set-up
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater", clear

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
*Calculating RDD predictions
*-------------------------------------------------------------------------------
*Global of outcomes
gl outcomes "arcsine_nl13 z_wi mean_educ_years"

*Against the distance
foreach var of global outcomes{
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
}

foreach var of global outcomes{
	*Predicting outcomes
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_xb
	predict `var'_xb, xb
	
	gen `var'_xb_m=`var'_xb
	replace `var'_xb_m=. if `var'==.
}

rename segm_id SEG_ID
keep SEG_ID *_xb* z_run_cntrl


foreach v in arcsine_nl13_xb mean_educ_years_xb z_wi_xb {
	gen insamp_`v'=`v'
	replace insamp_`v'=. if abs(z_run_cntrl)>15
}

export excel using "${data}/Predicted_Outcomes.xls", replace firstrow(var)




*END
