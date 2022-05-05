/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400_fake"
gl controls "within_control_fake i.within_control_fake#c.z_run_cntrl_fake z_run_cntrl_fake"
gl controls_resid "i.within_control_fake#c.z_run_cntrl_fake z_run_cntrl_fake"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl_fake, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl_fake)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl_fake/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"
la var z_wi_iqr "Wealth Index Range (p75-p25)"
la var z_wi_iqr2 "Wealth Index Range (p95-p5)"
la var z_wi_iqr3 "Wealth Index Range (p90-p10)"
la var z_wi_p50 "Median Wealth Index"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"
*Out: z_wi_iqr z_wi_iqr2 z_wi_iqr3 z_wi_p50 

*Erasing table before exporting
cap erase "${tables}\rdd_main_fake.tex"
cap erase "${tables}\rdd_main_fake.txt"

foreach var of global nl{
	
	*Dependent's var mean
	summ `var', d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	outreg2 using "${tables}\rdd_main_fake.tex", tex(frag) keep(within_control_fake) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
	*replace `var'_r=. if e(sample)!=1

}





*END