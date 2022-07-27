use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"


*Conditional for all specifications
gl if "if z_run_cntrl>=-.5 & z_run_cntrl<=.05 & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/.5)) if z_run_cntrl>=-.5 & z_run_cntrl<0 & elevation2>=200 & river1==0
replace tweights=(1-abs(z_run_cntrl/.05)) if z_run_cntrl<=.05 & z_run_cntrl>=0 & elevation2>=200 & river1==0



*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13"

foreach var of global nl{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	tab within_control if e(sample)==1
	
}
