/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Calculating education years by cohort (Census data)
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
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Creating vars 
gen tea_enroll= teachers/total_matricula
gen enroll_pop= total_matricula/total_pop
gen prim_pop= matricula_primaria/total_pop
gen sec_pop= matricula_secundaria/total_pop

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
la var mean_educ_years_wsage "School age at war"
la var mean_educ_years_wnsage "Non-school age at war"
la var mean_educ_years_sage "School age after war"

*-------------------------------------------------------------------------------
*            Educ years and teachers quality (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl ed1 "mean_educ_years_wsage literacy_rate_wsage"
gl ed2 "mean_educ_years_wnsage literacy_rate_wnsage"
gl ed3 "mean_educ_years_sage literacy_rate_sage"
gl ed  "mean_educ_years_wsage mean_educ_years_wnsage mean_educ_years_sage"
gl qual "total_matricula matricula_primaria matricula_secundaria enroll_pop prim_pop sec_pop teachers tea_enroll high_skl1 high_skl2 high_skl3"

*Erasing table before exporting
cap erase "${tables}\rdd_main_educage_p1.tex"
cap erase "${tables}\rdd_main_educage_p1.txt"
cap erase "${tables}\rdd_main_educage_p2.tex"
cap erase "${tables}\rdd_main_educage_p2.txt"
cap erase "${tables}\rdd_main_educage_p3.tex"
cap erase "${tables}\rdd_main_educage_p3.txt"
cap erase "${tables}\rdd_main_educage.tex"
cap erase "${tables}\rdd_main_educage.txt"
cap erase "${tables}\rdd_main_educqual.tex"
cap erase "${tables}\rdd_main_educqual.txt"

foreach var of global ed1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_educage_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global ed2{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_educage_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global ed3{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_educage_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global ed{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_educage.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global qual{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_educqual.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}





*END 
