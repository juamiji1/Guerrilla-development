use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)



use "${data}/SurveyAnalysis", clear
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

* Table 1 out of 7:
global Educvars educ_years 

foreach var of global Educvars{
	local r replace
	foreach y in 1 2 3 {
		
	preserve
	gen interactioneduc=young`y'*within_control 
	*Table
	reghdfe `var' ${controls} i.young`y' interactioneduc likert_SD_Index [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/SurveyEducHet.tex", nor2 tex(frag) keep(within_control interactioneduc) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
restore

	 local r append
	}
}


preserve 
  insheet using "${tables}/SurveyEducHet.txt", nonames clear
 drop v2

insobs 2, before(1)
replace v3 = "Years of Education" in 1
replace v4 = "Years of Education" in 1
replace v5 = "Years of Education" in 1
replace v3 = "(2022)" in 2
replace v4 = "(2022)" in 2
replace v5 = "(2022)" in 2
drop in 4
replace v1 = "Guerrilla control" in 5
replace v1 = "Guerrilla control \$\times\$ Young" in 7

dataout, tex save("${tables}/SurveyEducHet") replace nohead midborder(3)
restore 

