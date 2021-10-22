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
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi"
gl educ1 "mean_educ_years literacy_rate"

*Erasing table before exporting
cap erase "${tables}\rdd_dvsnd_night_light_onu_91_conley5kms.tex"
cap erase "${tables}\rdd_dvsnd_night_light_onu_91_conley5kms.txt"
cap erase "${tables}\rdd_dvsnd_night_light_onu_91_conley10kms.tex"
cap erase "${tables}\rdd_dvsnd_night_light_onu_91_conley10kms.txt"
cap erase "${tables}\rdd_dvsnd_night_light_onu_91_conley15kms.tex"
cap erase "${tables}\rdd_dvsnd_night_light_onu_91_conley15kms.txt"

*Creating needed vars bc the command does not accept factor vars
gen cntrl_x_zrun=within_control*z_run_cntrl 
gen dc_x_zrun=dist_capital*z_run_cntrl
gen dcst_x_zrun=dist_coast*z_run_cntrl
tab control_break_fe_400, g(fe_)

*New globals to use 
gl controls "within_control cntrl_x_zrun z_run_cntrl x_coord y_coord dist_capital dist_coast dc_x_zrun dcst_x_zrun"
gl main "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"

*Estimation with Conley SE
foreach var of global main{
	
	*Setting the sample and non-omitted vars 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	reg `var' ${controls} fe_* [aw=tweights] ${if} & e(sample)==1, r

	local coln : colnames e(b)            //get the col names from the B matrix
	local leftvars=""
	
	foreach varn of local coln {            //loop thru each
		_ms_parse_parts `varn'            //_ms_parse_parts tells if it is omitted
		if !`r(omit)' {                    
			local leftvars `leftvars' `varn'        //if not omitted, add to list
		}    
	}
	local cons "_cons"
	local leftvars: list leftvars-cons
	
	*Global of vars for each outcome 
	di "`leftvars'"
	gl nonomitcov="`leftvars'"
	
	*Actual estimations using acreg package 
	acreg `var' ${nonomitcov} [pw=tweights] ${if} & e(sample)==1, spatial latitude(y_coord) longitude(x_coord) dist(5) dropsingletons 
	outreg2 using "${tables}\rdd_dvsnd_night_light_onu_91_conley5kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 5) label nonote nocons append 
	
	acreg `var' ${nonomitcov} [pw=tweights] ${if} & e(sample)==1, spatial latitude(y_coord) longitude(x_coord) dist(10) dropsingletons 
	outreg2 using "${tables}\rdd_dvsnd_night_light_onu_91_conley10kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 10) label nonote nocons append 
	
	acreg `var' ${nonomitcov} [pw=tweights] ${if} & e(sample)==1, spatial latitude(y_coord) longitude(x_coord) dist(15) dropsingletons 
	outreg2 using "${tables}\rdd_dvsnd_night_light_onu_91_conley15kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 15) label nonote nocons append 

}







*END
