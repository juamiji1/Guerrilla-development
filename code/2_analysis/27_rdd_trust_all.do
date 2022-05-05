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
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl lap1 "z_index_pp z_index_ep z_index_ap z_index_trst"
gl lap2 "sum_pp sum_ep sum_ap sum_trst"
gl lap3 "sitecon reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon paz_sitpol asist_reu conf_com_high conf_com_low"
gl lap4 "reu_relig_high reu_esc_high reu_com_high reu_prof_high asist_reu_high reu_relig_low reu_esc_low reu_com_low reu_prof_low asist_reu_low"
 
*Erasing table before exporting
cap erase "${tables}\rdd_trust_all_p1.tex"
cap erase "${tables}\rdd_trust_all_p1.txt"
cap erase "${tables}\rdd_trust_all_p2.tex"
cap erase "${tables}\rdd_trust_all_p2.txt"
cap erase "${tables}\rdd_trust_all_p3.tex"
cap erase "${tables}\rdd_trust_all_p3.txt"
cap erase "${tables}\rdd_trust_all_p4.tex"
cap erase "${tables}\rdd_trust_all_p4.txt"

foreach var of global lap1{
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_trust_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lap2{
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_trust_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lap3{
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_trust_all_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lap4{
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_trust_all_p4.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}








*END
