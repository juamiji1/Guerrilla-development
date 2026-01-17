use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"


*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) 
*covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

use "${data}/SurveyAnalysis", clear
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

global Occupation Ocuprin1 Ocuprin2 Ocuprin4 Ocuprin3 Ocuprin5

local r replace 
foreach var of global Occupation {
	*Table
	reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/t8.tex", nor2 tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	local r append
}


preserve 
  insheet using "${tables}/t8.txt", nonames clear

drop v2 

replace v1 = "Guerrilla control" in 7
insobs 2, before(1)
drop in 4
drop in 4
drop in 4
drop in 4
replace v3 = "Agriculture" in 1
replace v4 = "Sales" in 1
replace v5 = "Works in Own " in 1
replace v5 = "Household" in 2
replace v6 = "Works as an " in 1
replace v6 = "Employee" in 2
replace v7 = "Other" in 1
dataout, tex save("${tables}/t8") replace nohead midborder(3)
restore 


