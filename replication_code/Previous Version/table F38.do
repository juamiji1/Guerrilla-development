/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring attitudes mechanism 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
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

*Labels
la var sum_pp "Political Participation (sum)"
la var sum_ep "Engagement with Politicians (sum)"
la var sum_ap "Non-Democratic Engagement (sum)"
la var sum_trst "Trust in Institutions (sum)"
la var z_index_pp "Political Participation (ICW)"
la var z_index_ep "Engagement with Political (ICW)"
la var z_index_ap "Non-Democratic Engagement (ICW)"
la var z_index_trst "Trust in Institutions (ICW)"

*-------------------------------------------------------------------------------
* 						   Attitudes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes

gl lap5 "aprobacion5 aprobacion6 aprobacion7 aprobacion8 sum_ap"
 
*Erasing table before exporting

local r replace

foreach var of global lap5{
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_expropriation_all_draft.tex", tex(frag) keep(within_control) dec(3) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nocons `r'
	
	local r append

}

preserve 
 insheet using "${tables}/rdd_expropriation_all_draft.txt", nonames clear

insobs 2, before(1)
drop in 4
replace v1 = "Guerrilla control" in 5
replace v2 = "Invading " in 1
replace v2 = "Property" in 2
replace v3 = "Occupying " in 1
replace v3 = "Buildings" in 2
replace v4 = "Overturn " in 1
replace v4 = "the Government" in 2
replace v5 = "Taking the Law in " in 1
replace v5 = "Own Hands" in 2
replace v6 = "Non-Democratic " in 1
replace v6 = "Engagement (sum)" in 2

dataout, tex save("${tables}/rdd_expropriation_all_draft") replace nohead midborder(3)

restore 
 




*END
