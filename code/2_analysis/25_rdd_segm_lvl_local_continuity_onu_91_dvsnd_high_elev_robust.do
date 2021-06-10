/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: The recommended altitud is 300 masml
------------------------------------------------------------------------------*/


*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear 

*Creating the sample for robustness
gen sampler=1 if within_control==0 & within_fmln==0
replace sampler=1 if within_control==1 & sampler==.

gen sampled=1 if (z_run_cntrl<-.03 | z_run_cntrl>.03)


*-------------------------------------------------------------------------------
* Robustness ex - Without disputed segments 
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc "elevation2 slope hydrography rail_road mean_coffee mean_cotton mean_dryrice mean_wetrice mean_bean mean_sugarcane"

*Labeling for tables 
la var elevation2 "Altitude"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway"
la var mean_coffee "Coffe Yield"
la var mean_cotton "Cotton Yield"
la var mean_dryrice "Dry Rice Yield"
la var mean_wetrice "Wet Rice Yield"
la var mean_bean "Bean Yield"
la var mean_sugarcane "Sugarcane Yield"

*Erasing files 
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_robust1.tex"
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_robust1.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0 & sampler==1, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

foreach var of global lc{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0 & sampler==1"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
	
	*Total Households
	reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_local_continuity_onu_91_robust1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}


*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Plot)
*-------------------------------------------------------------------------------
gl lc "elevation2 slope hydrography roads rail_road cacao bean mean_cocoa mean_bean mean_coffee mean_cotton mean_dryrice mean_maize mean_sugarcane mean_wetrice lake river2"
*mean_flow

foreach var of global lc{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0 & sampler==1"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
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
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25_robust1.pdf", as(pdf) replace 

}


*-------------------------------------------------------------------------------
* Robustness ex - Donut hole technique 
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check   
gl lc "elevation2 slope hydrography rail_road mean_coffee mean_cotton mean_dryrice mean_wetrice mean_bean mean_sugarcane"

*Labeling for tables 
la var elevation2 "Altitude"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway"
la var mean_coffee "Coffe Yield"
la var mean_cotton "Cotton Yield"
la var mean_dryrice "Dry Rice Yield"
la var mean_wetrice "Wet Rice Yield"
la var mean_bean "Bean Yield"
la var mean_sugarcane "Sugarcane Yield"

*Erasing files 
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_robust2.tex"
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_robust2.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0 & sampled==1, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

foreach var of global lc{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0 & sampled==1"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
	
	*Total Households
	reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_local_continuity_onu_91_robust2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Plot)
*-------------------------------------------------------------------------------
gl lc "elevation2 slope hydrography roads rail_road cacao bean mean_cocoa mean_bean mean_coffee mean_cotton mean_dryrice mean_maize mean_sugarcane mean_wetrice lake river2"
*mean_flow

foreach var of global lc{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.6
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0 & sampled==1"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25_robust2.pdf", as(pdf) replace 

}






*END
