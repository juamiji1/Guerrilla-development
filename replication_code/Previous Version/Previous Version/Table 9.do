

*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 
cap drop _merge 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}


gl outcomes2 "sewerage_sh garbage_sh pipes_sh electricity_sh"

local r replace

foreach var of global outcomes2{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/Table 9b.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	local r append
}

preserve 
 insheet using "${tables}/Table 9b.txt", nonames clear
drop v2
 save "${tables}/Table 9b" , replace 
restore 


use "${data}/SurveyAnalysis", clear
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

* Table 1 out of 7:
global StateIndividual p44_recode p47_recode p46_recode

local r replace 
foreach var of global StateIndividual {
	*Table
	reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/Table 9.tex", nor2 tex(frag) keep(within_control) addstat("Dependent mean", ${mean_y}) label nonote nocons `r'
	local r append
}

preserve
insheet using "${tables}/Table 9.txt", nonames clear
replace v2=""
rename (v2 v3 v4 v5) (v3 v4 v5 v6)
append using "${tables}/Table 9b"

drop in 2
drop in 9
insobs 3, before(1)
insobs 2, before(11)
replace v1 = "Guerrilla control" in 6
replace v1 = "Guerrilla control" in 15
replace v3 = "(4)" in 13
replace v4 = "(5)" in 13
replace v5 = "(6)" in 13
replace v6 = "(7)" in 13
replace v3 = "Sewerage" in 12
replace v4 = "Garbage" in 12
replace v5 = "Water" in 12
replace v6 = "Electricity" in 12
replace v1 = "Panel B: Share of Households in 2007 that Report Using" in 11
replace v1 = "Panel A: Share of Households in 2022 that Believe that" in 1
replace v3 = "" in 2
replace v4 = "Government " in 2
replace v4 = "Collects Taxes" in 3
replace v5 = "People " in 2
replace v5 = "Pay Taxes" in 3
replace v6 = "Government Agency" in 2
replace v6 = "in Community" in 3


local Pen=_N-1
gen n=_n 
replace n=90000 in `Pen'
sort n 
drop n

dataout, tex save("${tables}/t4") replace nohead  midborder(3)

restore 



foreach x in b {
preserve 
	cap erase "${tables}/Table 9.tex"
	cap erase "${tables}/Table 9.txt"
	cap erase "${tables}/Table 9.dta"
	
	cap erase "${tables}/Table 9`x'.tex"
	cap erase "${tables}/Table 9`x'.txt"
	cap erase "${tables}/Table 9`x'.dta"
restore 
}




