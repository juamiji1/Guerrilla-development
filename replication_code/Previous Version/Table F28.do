

/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes
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
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var mean_educ_years "Years of Education (2007)"
la var z_wi "Wealth Index (2007)"

*Standardizing Suitability Index
foreach var in sibean sicoffee simaize sisugar {
	egen z_`var'=std(`var')
	gen m_`var'=(`var'>4000) if `var'!=.	
	gen g_`var'=(`var'>5500) if `var'!=.	
	gen h_`var'=(`var'>7000) if `var'!=.	
	gen vh_`var'=(`var'>8500) if `var'!=.	
}

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl1 "arcsine_nl13 z_wi mean_educ_years"


*Erasing table before exporting
foreach crop in h_sicoffee h_sisugar  {
	tab `crop'

	
	local r replace

	foreach var of global nl1{
display "`crop'" "==0"
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if} & `crop'==0 , vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/MaininLowSuitable_`crop'.tex", tex(frag) keep(within_control) nor2 addstat("Dependent mean", ${mean_y},"Bandwidth (Km)", ${h}) nonote nocons `r'
	
	local r append
	
}
}

preserve 
 insheet using "${tables}/MaininLowSuitable_h_sisugar.txt", nonames clear
save "${tables}/MaininLowSuitable_h_sisugar" , replace 
restore 


preserve 
 insheet using "${tables}/MaininLowSuitable_h_sicoffee.txt", nonames clear
 append using  "${tables}/MaininLowSuitable_h_sisugar"

drop in 2
drop in 10
replace v2 = "" in 9
replace v3 = "" in 9
replace v4 = "" in 9
insobs 2, before(1)
drop in 10
replace v1 = "Guerrilla control" in 5
replace v1 = "Guerrilla control" in 12
insobs 1, before(3)
replace v2 = "Night Light Luminosity" in 1
replace v2 = "(2013)" in 2
drop in 3
insobs 1, before(4)
replace v3 = "Wealth Index " in 1
replace v3 = "(2007)" in 2
replace v4 = "Years of Education" in 1
replace v4 = "(2007)" in 2
replace v1 = "Panel A: Areas with low suitability for coffee" in 4
replace v1 = "Panel B: Areas with low suitability for sugar" in 11

dataout, tex save("${tables}/rdd_lowsuit_cashcrops") replace nohead midborder(3)


restore 




