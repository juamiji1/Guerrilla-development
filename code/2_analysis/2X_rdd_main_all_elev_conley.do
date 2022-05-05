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

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl main "arcsine_nl13 z_wi mean_educ_years"

*Erasing table before exporting
cap erase "${tables}\rdd_main_all_elev_conley2kms.tex"
cap erase "${tables}\rdd_main_all_elev_conley2kms.txt"
cap erase "${tables}\rdd_main_all_elev_conley500kms.tex"
cap erase "${tables}\rdd_main_all_elev_conley500kms.txt"
cap erase "${tables}\rdd_main_all_elev_conley4kms.tex"
cap erase "${tables}\rdd_main_all_elev_conley4kms.txt"

*Creating needed vars bc the command does not accept factor vars
gen wcxz=within_control*z_run_cntrl 
tab control_break_fe_400, g(fe_)

*New globals to use 
gl controls "within_control wcxz z_run_cntrl elevation2 exz"

*Estimation with Conley SE
foreach var of global main{

	*Actual estimations using acreg package 
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(.5) pfe1(${breakfe}) dropsingletons 
	outreg2 using "${tables}\rdd_main_all_elev_conley500kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 0.5) label nonote nocons append 
	
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(2) pfe1(${breakfe})  dropsingletons 
	outreg2 using "${tables}\rdd_main_all_elev_conley2kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 2) label nonote nocons append 	
	
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(4) pfe1(${breakfe}) dropsingletons 
	outreg2 using "${tables}\rdd_main_all_elev_conley4kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 4) label nonote nocons append 

}


*END