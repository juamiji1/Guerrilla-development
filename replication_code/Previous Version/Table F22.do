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

gl qual "teachers high_skl1 high_skl2 high_skl3 daily_water_sh"

*Erasing table before exporting

local r replace 
foreach var of global qual{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/rdd_main_educqual.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	
	local r append
}

preserve 
  insheet using "${tables}/rdd_main_educqual.txt", nonames clear
drop v2 

replace v1 = "Guerrilla control" in 4
insobs 2, before(1)
drop in 4
replace v3 = "Total" in 1
replace v3 = "Teachers" in 2
replace v4 = "Certified " in 1
replace v4 = "Teachers" in 2
replace v5 = "Certified Teachers" in 1
replace v5 = "with High School" in 2
replace v6 = "Teachers with " in 1
replace v6 = "High School" in 2
replace v7 = "Daily Water" in 1
replace v7 = "Frequency" in 2

dataout, tex save("${tables}/rdd_main_educqual") replace nohead midborder(3)
restore 





*END 
