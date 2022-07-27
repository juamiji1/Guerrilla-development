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
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=1
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

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
gl inc "ipcf_ppp11_iqr ipcf_ppp11_iqr2 ipcf_ppp11_iqr3 ipcf_ppp11_p50 poverty25 poverty4 cooperative assistance"  

*Erasing table before exporting
cap erase "${tables}\rdd_dvsnd_ephm_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_ephm_onu_91.txt"

foreach var of global inc{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	outreg2 using "${tables}\rdd_dvsnd_ephm_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
	*replace `var'_r=. if e(sample)!=1

}


/*Global of outcomes
gl inc "ipcf_ppp11_iqr ipcf_ppp11_p50 poverty25_sh poverty4_sh cooperative_sh assistance_sh"  

*Erasing table before exporting
cap erase "${tables}\rdd_dvsnd_ephm_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_ephm_onu_91.txt"

foreach var of global inc{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	outreg2 using "${tables}\rdd_dvsnd_ephm_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
	*replace `var'_r=. if e(sample)!=1

}




*END 


