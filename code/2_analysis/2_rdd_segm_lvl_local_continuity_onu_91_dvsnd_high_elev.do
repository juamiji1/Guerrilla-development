/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: The recommended altitud is 300 masml
------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Descriptives of the elevation distribution
*-------------------------------------------------------------------------------
*Pixel level data 
use "${data}/night_light_13_pxl_lvl_onu_91.dta", clear 

*Checking the elevation distribution 
hist elevation2, freq xtitle("Elevation (mamsl)")
gr export "${plots}\hist_elev_pxl.pdf", as(pdf) replace 

summ elevation2, d
tabstat elevation2, by(within_fmln) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)
tabstat elevation2, by(within_control) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)

*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear 

*Checking the elevation distribution 
hist elevation2, freq xtitle("Elevation (mamsl)")
gr export "${plots}\hist_elev_segm.pdf", as(pdf) replace 

summ elevation2, d
tabstat elevation2, by(within_fmln) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)
tabstat elevation2, by(within_control) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone (high vs low estimates)
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="fmln_break_fe_400"

*Creating matrices to export estimates
forval i=1/4{
	mat coef`i'=J(3,40,.)
}

local h=0.1
forval c=1/40{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h'
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h' & elevation2>=300, vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h' & elevation2<300, vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef3[1,`c']= r(estimate) 
	mat coef3[2,`c']= r(lb)
	mat coef3[3,`c']= r(ub)
	
	*Estimating elevation results
	reghdfe max_elev within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef4[1,`c']= r(estimate) 
	mat coef4[2,`c']= r(lb)
	mat coef4[3,`c']= r(ub)
	
	local h=`h'+0.1
}

forval i=1/4{
	mat coln coef`i'= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
}

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91_high.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91_low.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91_all.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_max_elev_bw_robustness_segm_91.pdf", as(pdf) replace 

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
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_local_continuity_onu_91.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=300, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

foreach var of global lc{
	
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
	outreg2 using "${tables}\rdd_dvsnd_local_continuity_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Plot)
*-------------------------------------------------------------------------------
gl lc "elevation2 slope hydrography roads rail_road cacao bean mean_cocoa mean_bean mean_coffee mean_cotton mean_dryrice mean_maize mean_sugarcane mean_wetrice mean_flow lake river1 river2"

foreach var of global lc{
	
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

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone (Percentile 50 and up of elevation)
*-------------------------------------------------------------------------------
summ elevation2, d
gl p50=`r(p50)' 

foreach var of global lc{
	
	*Dependent's var mean
	summ `var' if elevation2>=${p50}, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & elevation2>=${p50}"

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
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p50.pdf", as(pdf) replace 

}











*END

