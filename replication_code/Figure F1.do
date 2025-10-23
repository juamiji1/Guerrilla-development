
	
	/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

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
la var arcsine_nl13 "Arcsine"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"


*-------------------------------------------------------------------------------
* Plots
*-------------------------------------------------------------------------------
gl lc "arcsine_nl13 z_wi mean_educ_years"
gl resid "arcsine_nl13_r z_wi_r mean_educ_years_r"

*Different Badwidths
foreach var of global lc{
	
	global yr -.5 0
	global yl -.5(.1)0
	
	if "`var'"=="mean_educ_years" {
		global yr -1.5 0
	global yl -1.5(.3)0
	}
	
	*Dependent's var mean
	summ `var', d
	gl mean_y=string(round(r(mean), .01),"%03.2f")
	
		
	*Creating matrix to export estimates
	mat coef=J(3,46,.)
	
	*Estimations
	local h=0.5
	forval c=1/46{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h'"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) yscale(r(${yr})) ylabel(${yl},labsize(small)) xlabel(1 "0.5" 6 "1.0" 11 "1.5" 16 "2.0" 21 "2.5" 26 "3.0" 31 "3.5" 36 "4.0" 41 "4.5" 46 "5.0" ,labsize(small)) l2title("Coefficient magnitude") b2title("Bandwidth (Km)") note(Mean of Outcome: ${mean_y}) name(`var', replace) graphregion(color(white))
	gr export "${plots}/rdd_all_`var'_bwrobust_05to5kms.pdf", as(pdf) replace 

}


*END




