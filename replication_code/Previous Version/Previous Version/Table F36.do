/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating voting and election outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Main outcomes (Presidential 2014)
*
*-------------------------------------------------------------------------------
use "${data}/mesas14_onu_91.dta", clear 
destring codcanton, g(canton_id)

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

gl elec="sh_left sh_right sh_blanco turnout"

*-------------------------------------------------------------------------------
* 						Elections (Table)
*-------------------------------------------------------------------------------

*RDD with break fe and triangular weights 
rdrobust sh_left z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) 

local r replace
foreach var of global elec{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(cluster canton_id) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_elec14_all.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nocons `r' adec(3)
	local r append

}


*-------------------------------------------------------------------------------
* 						Main outcomes (Mayors 2015)
*
*-------------------------------------------------------------------------------
use "${data}/mesas15_onu_91.dta", clear 
destring codcanton, g(canton_id)

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

gl elec="sh_left sh_right sh_blanco turnout"

*-------------------------------------------------------------------------------
* 						Elections (Table)
*-------------------------------------------------------------------------------

*RDD with break fe and triangular weights 
rdrobust sh_left z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) 

local r replace
foreach var of global elec{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(cluster canton_id) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_elec15_all.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nocons `r' adec(3)
	
	local r append

}


preserve 
 insheet using "${tables}/rdd_elec15_all.txt", nonames clear
 save "${tables}/rdd_elec15_all", replace
restore 

preserve 
 insheet using "${tables}/rdd_elec14_all.txt", nonames clear
 append using "${tables}/rdd_elec15_all"
 
insobs 3, before(1)
drop in 5
drop in 12
replace v2 = "" in 12
replace v3 = "" in 12
replace v4 = "" in 12
replace v5 = "" in 12
replace v1 = "Panel B: 2015 Municipal elections" in 12
replace v1 = "Panel A: 2014 Presidential elections - Guerrillas' Party won" in 1
replace v2 = "Left Voting " in 2
replace v2 = "Share" in 3
replace v3 = "Share" in 3
replace v4 = "Share" in 3
replace v5 = "Share" in 3
replace v3 = "Right Voting" in 2
replace v4 = "Blank Voting" in 2
replace v5 = "Turnout" in 2
replace v1 = "Guerrilla control" in 6
replace v1 = "Guerrilla control" in 14

dataout, tex save("${tables}/rdd_elec_all_draft") replace nohead midborder(3)

restore 


cap erase "${tables}/rdd_elec15_all.dta"
*END
