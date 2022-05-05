/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


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
la var ipcf_ppp11_iqr "Interquartile Range of Income"
la var ipcf_ppp11_iqr2 "Range of Income (p90-p10)"
la var ipcf_ppp11_iqr3 "Range of Income (p95-p5)"
la var ipcf_ppp11_p50 "Median Income"
la var poverty25 "Share of Poor HH"
la var poverty4 "Share of Moderate Poor HH"
la var cooperative "Cooperative Workers"
la var assistance "Social Assistance Share"
*ipcf_ppp11_pr9010 ipcf_ppp11_pr9505 ipcf_ppp11_pr7525 hh_p2575 hh_p1090 hh_p0595

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl inc1 "ipcf_ppp11_iqr ipcf_ppp11_iqr2 ipcf_ppp11_iqr3 ipcf_ppp11_p50 poverty25 poverty4 cooperative assistance"  
gl inc2  "ln_ipcf_ppp11 ipcf_ppp11 gini_zwi iqr_zwi ipr_zwi ilr_zwi"

*Erasing table before exporting
cap erase "${tables}\rdd_ineq_all_p1.tex"
cap erase "${tables}\rdd_ineq_all_p1.txt"
cap erase "${tables}\rdd_ineq_all_p2.tex"
cap erase "${tables}\rdd_ineq_all_p2.txt"

foreach var of global inc1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global inc2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}






*END 

