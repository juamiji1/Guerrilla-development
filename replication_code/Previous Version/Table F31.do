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
gl controls "within_control"
gl if "if abs(z_run_cntrl)<=${h}"

* Table 1 out of 7:

global ReasonsforStaying p51cat1 p51cat2 p51cat3 p51cat4


local r replace
foreach var of global ReasonsforStaying {
	*Table
	reghdfe `var' ${controls}  [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/t5_reasonsforstaying.tex", nor2 tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) dec(3) label nonote nocons `r'
	
	local r append
}

preserve 

 insheet using "${tables}/t5_reasonsforstaying.txt", nonames clear

 
insobs 2, before(1)
drop in 4
replace v3 = "Economic Opportunity" in 1
replace v3 = "(Dummy)" in 2
replace v4 = "Social Ties" in 1
replace v4 = "(Dummy)" in 2
replace v5 = "Inability to Leave" in 1
replace v5 = "(Dummy)" in 2
replace v6 = "Owns Land" in 1
replace v6 = "(Dummy)" in 2

dataout, tex save("${tables}/t5_reasonsforstaying") replace nohead midborder(4)

restore 
