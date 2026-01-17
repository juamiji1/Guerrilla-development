/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Results for agricultural productivity (FAO data)
DATE: 
AUTHORS: 
RA: JMJR

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* RDD results
* 
*-------------------------------------------------------------------------------
*Census segment level data 
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

*-------------------------------------------------------------------------------
* Preparing the different measures of yield and total production 
*-------------------------------------------------------------------------------
summ bean05 maize05 coffe05 sugar05
summ h_bean05 h_maize05 h_coffee05 h_sugar05

gl yld "bean05 maize05 coffe05 sugar05"
gl is "h_bean05 h_maize05 h_coffee05 h_sugar05"
gl prod "prod_bean05 prod_maize05 prod_coffee05 prod_sugar05"

foreach var of global yld{
	egen p = pctile(`var'), p(2)
	*summ `var', d
	gen p`var'=(`var'>p)
	*replace `var'=. if `var'<=p
	drop p
}

foreach var of global yld{
	replace `var'=. if `var'==0
}

foreach var of global is{
	summ `var', d
	*gen p`var'=(`var'> 0)
	*gen p`var'=(`var'>  `r(p5)')
	
	egen p = pctile(`var'), p(2)
	gen p`var'=(`var'>p)
	drop p
	
}

foreach var of global prod{
	gen d`var'=(`var'>0)

	egen p = pctile(`var'), p(2)
	gen p2`var'=(`var'>p)
	drop p
}

*Area from Km2 to Has 
gen segm_area=AREA_K*100 

foreach var of global is{
	gen s`var'=`var'/segm_area
}

*-------------------------------------------------------------------------------
* Actual crops' yield results (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl pd "prod_bean05 prod_maize05 prod_coffee05 prod_sugar05"
gl sh "sh_bean05 sh_maize05 sh_coffee05 sh_sugar05"
gl yld "bean05 maize05 coffe05 sugar05"


*Erasing files 
local r replace 
foreach var of global pd{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_yld_all_p7.tex", tex(frag) keep(within_control) nor2 addstat("Dependent mean", ${mean_y})  nonote nocons `r'
	local r append
}

local r replace 
foreach var of global sh{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_yld_all_p5.tex", tex(frag) keep(within_control) nor2 addstat("Dependent mean", ${mean_y})  nonote nocons `r'
	local r append
}


local r replace 
foreach var of global yld{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_yld_all_p1.tex", tex(frag) keep(within_control) nor2 addstat("Dependent mean", ${mean_y},"Bandwidth (Km)", ${h}) nonote nocons `r'
	
	local r 
}




foreach var in 1 5 {
preserve 
 insheet using "${tables}/rdd_yld_all_p`var'.txt", nonames clear
save "${tables}/rdd_yld_all_p`var'" , replace 
restore 
}

preserve 
 insheet using "${tables}/rdd_yld_all_p7.txt", nonames clear
 append using  "${tables}/rdd_yld_all_p5"
 append using  "${tables}/rdd_yld_all_p1"
 
 
insobs 3, before(1)
drop in 5
replace v2 = "Bean" in 3
replace v3 = "Maize" in 3
replace v4 = "Coffe " in 3
replace v5 = "Sugarcane" in 3

replace v1 = "Guerrilla control" in 6
replace v1 = "Guerrilla control" in 14
replace v1 = "Guerrilla control" in 22
replace v2 = "" in 12
replace v3 = "" in 12
replace v4 = "" in 12
replace v5 = "" in 12
drop in 11
drop in 18
replace v2 = "" in 18
replace v3 = "" in 18
replace v4 = "" in 18
replace v5 = "" in 18
replace v1 = "Panel A: Crop Production in 2005 (1,000 Tons)" in 1
replace v1 = "Panel B: Share of harvest in 2005 (Has)" in 11
replace v1 = "Panel C: Actual Crops' Yield in 2005 (Tons/Ha)" in 18
replace v2 = "Subsistence crops" in 2
replace v4 = "Cash crops" in 2

dataout, tex save("${tables}/rdd_yld_all_draft") replace nohead midborder(4)
restore 











*END

