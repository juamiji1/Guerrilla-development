/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating victims outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Creating variables 
gen d_event=(events>0)
gen d_victim=(victims>0)

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

*Global victims
gl vic "events victims d_event d_victim"

*Erasing table before exporting

local r replace
foreach var of global vic{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_victimsgeo_all_p1.tex", tex(frag) keep(within_control) dec(3) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r' 
	
	local r append
	
}


preserve 
 insheet using "${tables}/rdd_victimsgeo_all_p1.txt", nonames clear
 

drop v2 
insobs 1, before(1)
drop in 3
replace v3 = "Total War Events" in 1
replace v4 = "Total War Victims" in 1
replace v5 = "Has a War Event" in 1
replace v6 = "Has War Victims" in 1


dataout, tex save("${tables}/rdd_victimsgeo_all_p1") replace nohead midborder(3)

restore 
