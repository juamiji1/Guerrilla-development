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
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"

foreach var in good_roof2 good_floor2 good_wall2 S03P13A S03P13D S03P13E S03P13J{
	gen cv_`var'=sqrt((1-`var')/`var')
	gen gini_`var'=1-`var'
}

gen ratio_roof=bad_roof/good_roof
gen ratio_floor=bad_floor/good_floor
gen ratio_wall=bad_wall/good_wall

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

*Labels for outcomes
la var ipcf_ppp11_iqr "Interquartile Range of Income"
la var ipcf_ppp11_iqr2 "Range of Income (p90-p10)"
la var ipcf_ppp11_iqr3 "Range of Income (p95-p5)"
la var ipcf_ppp11_p50 "Median Income"
la var poverty25 "Share of Poor HH"
la var poverty4 "Share of Moderate Poor HH"
la var cooperative "Cooperative Workers"
la var assistance "Social Assistance Share"
la var S03P13J "Share of HH with Car"
la var S03P13E "Share of HH with Washing Machine"
la var S03P13D "Share of HH with Fridge"
la var S03P13A "Share of HH with TV"
la var good_roof  "High Quality Roof (Share)"
la var good_floor "High Quality Floor (Share)"
la var good_wall "High Quality Wall (Share)"
la var gini_zwi "Gini (Wealth Index)"
la var ipr_zwi "p90 and p10 ratio"
la var ilr_zwi "p90 and p50 ratio"

*ipcf_ppp11_pr9010 ipcf_ppp11_pr9505 ipcf_ppp11_pr7525 hh_p2575 hh_p1090 hh_p0595

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl inc "ipcf_ppp11_iqr ipcf_ppp11_iqr2 ipcf_ppp11_iqr3 ipcf_ppp11_p50 poverty25 poverty4 cooperative assistance"  
gl ineq1 "gini_zwi ipr_zwi ilr_zwi ratio_floor ratio_roof ratio_wall"
gl ineq2 "gini_good_roof gini_good_floor gini_good_wall gini_S03P13A gini_S03P13D gini_S03P13E gini_S03P13J"
gl ineq3 "cv_good_roof cv_good_floor cv_good_wall cv_S03P13A cv_S03P13D cv_S03P13E cv_S03P13J"
  

*Erasing table before exporting
cap erase "${tables}\rdd_ineq_all_elev.tex"
cap erase "${tables}\rdd_ineq_all_elev.txt"
cap erase "${tables}\rdd_ineq_all_elev_p2.tex"
cap erase "${tables}\rdd_ineq_all_elev_p2.txt"
cap erase "${tables}\rdd_ineq_all_elev_p3.tex"
cap erase "${tables}\rdd_ineq_all_elev_p3.txt"
cap erase "${tables}\rdd_ineq_all_elev_p4.tex"
cap erase "${tables}\rdd_ineq_all_elev_p4.txt"

foreach var of global inc{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_elev.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global ineq1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_elev_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global ineq2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_elev_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global ineq3{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_elev_p4.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}







*END
