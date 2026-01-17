/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating crime outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Preparing the set-up 
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

*-------------------------------------------------------------------------------
* 						Crime outcomes (Table)
*-------------------------------------------------------------------------------

*Global of outcomes
gl crime "homicidios delinc extorsion3"


la var delinc "Victim of crime"
la var extorsion3 "Victim of extorsion"

local r replace
foreach var of global crime{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_crime_all.tex", tex(frag) keep(within_control) nor2 dec(3) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nocons `r' 
	local r append 
	
}

preserve 
 insheet using "${tables}/rdd_crime_all.txt", nonames clear
 
insobs 2, before(1)
replace v2 = "Homicides" in 1
replace v2 = "(2017)" in 2
replace v3 = "Victim of Any Crime" in 1
replace v3 = "(2004-2016)" in 2
replace v4 = "Victim of Gang Extortion" in 1
replace v4 = "(2004-2016)" in 2
drop in 4
replace v1 = "Guerrilla control" in 5

dataout, tex save("${tables}/rdd_crime_all") replace nohead midborder(3)

restore 




*END
