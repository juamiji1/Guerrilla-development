/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of outcomes
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1"

*Global of border FE for all estimate
gl breakfe="fmln_break_fe_400"

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted Level"


*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
cap erase "${tables}\rdd_dvsnd_night_light_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_night_light_onu_91.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=300, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

foreach var of global nl{
	
	*Dependent's var mean
	summ `var' if elevation2>=300, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)

	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=300"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
	*Total Households
	reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_night_light_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Plot)
*-------------------------------------------------------------------------------
foreach var of global nl{
	
	*Dependent's var mean
	summ `var' if elevation2>=300, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=300"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h'
		
		*Total Households
		reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}





*END