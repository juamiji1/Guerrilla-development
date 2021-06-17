/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"

*Global of outcomes
gl out "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord c.x_coord#c.z_run_cntrl c.y_coord#c.z_run_cntrl dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"
	
foreach var of global out{

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
	*Predicting outcomes
	cap drop `var'_xb
	predict `var'_xb, xb
	*replace `var'_xb=. if elevation2<200 | river1==1	
	
}

tabstat z_run_cntrl if e(sample)==1, by(within_control) s(N mean sd min p50 max)
hist z_run_cntrl if e(sample)==1 & within_control==1, frac
*70% of the sample

*Sample indicator
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample_reg=e(sample)



keep segm_id ${out} *_xb sample_reg within_control
export delimited using "${data}\predicted_outcomes.csv", replace



*END
