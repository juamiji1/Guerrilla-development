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

*Erasing table before exporting
cap erase "${tables}\rdd_dvsnd_crime_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_crime_onu_91.txt"

foreach var in homicidios{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	outreg2 using "${tables}\rdd_dvsnd_crime_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
	*replace `var'_r=. if e(sample)!=1

}

gl resid "homicidios_r" 

preserve

	gen x=round(z_run_cntrl, 0.07)
	gen n=1
	
	collapse (mean) ${resid} (sum) n, by(x)

	foreach var in homicidios_r{
		two (scatter `var' x if abs(x)<1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var' x [aweight = n] if x<0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var' x [aweight = n] if x>=0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), xlabel(-1(0.2)1) legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") name(`var', replace)
		gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

				
	}
	
restore


*Using different bandwidths
foreach var in homicidios{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

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
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y}) 
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}




