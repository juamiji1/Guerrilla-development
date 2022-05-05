*-------------------------------------------------------------------------------
* 						Main outcomes (Presidential 2009)
*
*-------------------------------------------------------------------------------
use "${data}/mesas09_onu_91.dta", clear
destring codcanton, g(canton_id)

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

gl elec="sh_left sh_right sh_blanco turnout"

*-------------------------------------------------------------------------------
* 						Elections (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_elec09_all.tex"
cap erase "${tables}\rdd_elec09_all.txt"

*RDD with break fe and triangular weights 
rdrobust sh_left z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) 

foreach var of global elec{

	*Table
	reghdfe `var' ${controls} [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_elec09_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}


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
*Erasing table before exporting
cap erase "${tables}\rdd_elec14_all.tex"
cap erase "${tables}\rdd_elec14_all.txt"

*RDD with break fe and triangular weights 
rdrobust sh_left z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) 

foreach var of global elec{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(cluster canton_id) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_elec14_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

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
*Erasing table before exporting
cap erase "${tables}\rdd_elec15_all.tex"
cap erase "${tables}\rdd_elec15_all.txt"

*RDD with break fe and triangular weights 
rdrobust sh_left z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) 

foreach var of global elec{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(cluster canton_id) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_elec15_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}








*END
