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

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc1 "elevation2 slope rugged hydrography mean_rain min_temp rail_road dist_capital" 
gl lc2 "dist_coast dist_depto mean_coffee mean_cotton mean_dryrice mean_wetrice mean_bean mean_sugarcane"

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
la var dist_coast "Distance to Coast"
la var dist_capital "Distance to Capital"
la var mean_rain "Mean Rainfall"
*la var max_temp "Maximum Temperature"
la var min_temp "Temperature"
la var rugged "Ruggedness"

*Erasing files 
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_p1.tex"
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_p1.txt"
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_p2.tex"
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91_p2.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

foreach var of global lc1{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)

	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
	
	*Table 
	reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_local_continuity_onu_91_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global lc2{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)

	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
	
	*Table 
	reghdfe `var' within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_local_continuity_onu_91_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}


*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Plot)
*-------------------------------------------------------------------------------
gl lc "elevation2 slope hydrography roads rail_road cacao bean mean_cocoa mean_bean mean_coffee mean_cotton mean_dryrice mean_maize mean_sugarcane mean_wetrice lake river2 dist_coast dist_capital mean_rain max_temp min_temp rugged"
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
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

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
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Km)") note(Mean of Outcome: ${mean_y}) name(`var', replace)
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone (Percentile 50 and up of elevation)
*-------------------------------------------------------------------------------
summ elevation2, d
gl p50=`r(p50)' 

foreach var of global lc{
	
	*Dependent's var mean
	summ `var' if elevation2>=${p50} & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=${p50} & river1==0"

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
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Km)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p50.pdf", as(pdf) replace 

}











*END

