/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes outcomes accounting by conflict 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*-------------------------------------------------------------------------------
* DIFFERENTIATTNG BY TYPE OF ZONES		
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control within_disputa i.within_disputa#c.z_run_cntrl i.within_control#c.z_run_cntrl z_run_cntrl"

gen within_disputa=(within_fmln==1 & within_control==0)

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
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education (2007)"
la var z_wi "Wealth Index (2007)"
la var z_wi_iqr "Wealth Index Range (p75-p25)"
la var z_wi_iqr2 "Wealth Index Range (p95-p5)"
la var z_wi_iqr3 "Wealth Index Range (p90-p10)"
la var z_wi_p50 "Median Wealth Index"
la var within_disputa "Disputed area"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl1 "arcsine_nl13 z_wi mean_educ_years"

local r replace
foreach var of global nl1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_conflict_all_draft.tex", tex(frag) keep(within_control within_disputa) addstat("Bandwidth (Km)", ${h},"Dependent mean", ${mean_y}) label nonote nor2 nocons `r'
	local r append
	
}


preserve 
  insheet using "${tables}/rdd_conflict_all_draft.txt", nonames clear
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

dataout, tex save("${tables}/rdd_conflict_all_draft") replace nohead midborder(2)
 
restore


*END





