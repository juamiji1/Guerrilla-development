use "${data}/SurveyAnalysis", clear
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

global LandSelling likert_p710 p83 

local r replace
foreach var of global LandSelling {
	*Table
	reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/t5.tex", nor2 tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons  `r' 
	local r append
}


preserve 
insheet using "${tables}/t5.txt", nonames clear
  
replace v1 = "Guerrilla control" in 4
drop v2 
drop in 2
insobs 3, before(1)
replace v3 = "Difficulty of" in 1
replace v3 = "Selling Land" in 2
replace v3 = "(Likert Scale)" in 3
replace v4 = "Would Sell " in 1
replace v4 = "Land" in 2
replace v4 = "(Dummy) " in 3

dataout, tex save("${tables}/t5") replace nohead  midborder(3)
 
restore



