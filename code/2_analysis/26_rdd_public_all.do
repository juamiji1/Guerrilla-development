/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring possible mechanisms
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Creating vars per habitant
gen hosp_pop=total_hospitals/total_pop
gen schl_pop=total_schools/total_pop

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

*-------------------------------------------------------------------------------
* 				Mechanisms related to household conditions
*-------------------------------------------------------------------------------
gl hh "sewerage_sh pipes_sh electricity_sh garbage_sh total_hospitals total_schools dist_hosp dist_schl hosp_pop schl_pop road14_dens public_pet"

*Labeling for tables 
la var total_household "Total Households"
la var owner_sh "Ownership Rate"
la var sanitary_sh "Sanitary Service Rate"
la var sewerage_sh  "Sewerage Service Rate"
la var pipes_sh "Water Access Rate"
la var daily_water_sh "Daily Water Rate"
la var electricity_sh "Electricity Rate"
la var garbage_sh "Garbage Rate"
la var total_hospitals "Total Hospitals"
la var total_schools "Total Schools"
la var road14 "Roads (2014)"
la var length_road14 "Roads (Kms)"
la var road14_dens "Road density (2014)"
la var public_pet "Public Workers"

*Erasing files 
cap erase "${tables}\rdd_public_all.tex"
cap erase "${tables}\rdd_public_all.txt"
	
*Tables
foreach var of global hh{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) keepsingleton
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_public_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* Plots
*-------------------------------------------------------------------------------
gl lc "sewerage_sh pipes_sh electricity_sh garbage_sh total_hospitals total_schools dist_hosp dist_schl road14_dens public_pet"
gl resid "sewerage_sh_r pipes_sh_r electricity_sh_r garbage_sh_r total_hospitals_r total_schools_r dist_hosp_r dist_schl_r road14_dens_r public_pet_r"

*Against the distance
foreach var of global lc{
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
}

preserve

	gen x=round(z_run_cntrl, 0.08)
	gen n=1
	
	collapse (mean) ${resid} (sum) n, by(x)

	foreach var of global resid{
		two (scatter `var' x if abs(x)<1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var' x [aweight = n] if x<0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var' x [aweight = n] if x>=0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), xlabel(-1(0.2)1) legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") name(`var', replace)
		gr export "${plots}\rdplot_all_`var'.pdf", as(pdf) replace 

				
	}
	
restore

*Different Badwidths
foreach var of global lc{
	
	*Dependent's var mean
	summ `var', d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

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
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Km)") note(Mean of Outcome: ${mean_y}) name(`var', replace)
	gr export "${plots}\rdd_all_`var'_bwrobust.pdf", as(pdf) replace 

}






gl hh "sanitary_sh exclusive_sanitary electric_cook owner_sh "

*Labeling for tables 
la var exclusive_sanitary "Exclusive sanitary"

*Erasing files 
cap erase "${tables}\rdd_public_all_p2.tex"
cap erase "${tables}\rdd_public_all_p2.txt"
	
*Tables
foreach var of global hh{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) keepsingleton
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_public_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}



*END








*END






*END 



*END





*END
