/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring possible mechanisms
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
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"


*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) covs(elevation2 exz)
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
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl lap "sum_pp sum_ep sum_ap sum_trst z_index_pp z_index_ep z_index_ap z_index_trst"

*Erasing table before exporting
cap erase "${tables}\rdd_trust_all_elev.tex"
cap erase "${tables}\rdd_trust_all_elev.txt"

foreach var of global lap{
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_trust_all_elev.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}








*END