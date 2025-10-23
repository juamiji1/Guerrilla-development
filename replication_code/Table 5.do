clear all 

use "${data}/temp/census9207_canton_lvl.dta", clear 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl92 z_run_cntrl, all kernel(triangular)
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
la var arcsine_nl92 "Arcsine (1992)"
la var ln_nl92 "Logarithm (1992)"
la var nl92_density "Level (1992)"
la var mean_educ_years92 "Years of Education (1992)"
la var z_wi92 "Wealth Index (1992)"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl1 "arcsine_nl92 z_wi92 mean_educ_years92"

*Erasing table before exporting
local r replace 

foreach var of global nl1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_main_all_canton.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nor2 nocons `r'
	local r append
}

preserve 
	insheet using "${tables}/rdd_main_all_canton.txt", nonames clear
	drop v2

	replace v3 = "Night Light Luminosity" in 1
	replace v4 = "" in 1
	replace v4 = "" in 2
	replace v4 = "Wealth Index" in 1
	replace v5 = "" in 2
	replace v5 = "Years of Education" in 1
	insobs 1, before(4)
	replace v1 = "" in 2
	replace v3 = "(1992)" in 2
	replace v4 = "(1992)" in 2
	replace v5 = "(1992)" in 2
	replace v3 = "(1)" in 3
	replace v4 = "(2)" in 3
	replace v5 = "(3)" in 3
	replace v1= "Guerrilla control" in 5

	dataout, tex save("${tables}/rdd_main_all_canton_draft") replace nohead midborder(2)
	 
restore





*END
