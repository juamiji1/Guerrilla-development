/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: The recommended altitud is 300 masml
------------------------------------------------------------------------------*/

*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Creating needed vars 
gen dens_pop_bornbef80=pop_bornbef80_always/AREA_K

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

*Standardizing Suitability Index
foreach var in sibean sicoffee simaize sisugar {
	egen z_`var'=std(`var')
}

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc1 "elevation2 slope rugged hydrography rail_road d_city45 dist_city45" 
gl lc2 "dist_comms45 comms45_dens reform grown80_swithin d_parr80 dist_parr80 dist_schl80"
gl lc3 "z_crops bean79 coffee79 cotton79 maize79 rice79 sugarcane79"
gl lc4 "pop_bornbef80_always dens_pop_bornbef80 mean_educ_years_wnsage sh_before_war_child sh_before_war_inmigrant sh_before_war_outmigrant high_pop80_swithin"
gl lc5 "sibean sicoffee simaize sisugar z_sibean z_sicoffee z_simaize z_sisugar"

*Labeling for tables 
la var elevation2 "Altitude"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway"
la var coffee79 "Coffe Yield"
la var cotton79 "Cotton Yield"
la var maize79 "Maize Yield"
la var rice79 "Wet Rice Yield"
la var bean79 "Bean Yield"
la var sugarcane79 "Sugarcane Yield"
la var dist_coast "Distance to Coast"
la var dist_capital "Distance to Capital"
la var rain_z "Rainfall"
la var max_temp_z "Max Temperature"
la var min_temp_z "Min Temperature"
la var d_city45 "Had a City/Village"
la var dist_city45 "Distance to City/Village"
la var dist_comms45 "Distance to Comms"
la var comms45_dens "Comms Density"
la var high_pop80_swithin "Within high populated"
la var reform "Had Land Reform"
la var d_parr80 "Had a Parish"
la var dist_parr80 "Distance to Parish"
la var grown80_swithin "Within cultivated area"
la var z_crops "Z-Yield of All Crops"
la var dist_schl80 "Distance to School"
la var pop_bornbef80_always "Population"
la var dens_pop_bornbef80 "Population density"
la var mean_educ_years_wnsage "Years of education"
la var sh_before_war_child "Natality Rate"
la var sh_before_war_inmigrant "In-migration (share)"
la var sh_before_war_outmigrant "Out-migration (share)"
la var sibean "Suitability Index Bean"
la var sicoffee "Suitability Index Coffee"
la var simaize "Suitability Index Maize"
la var sisugar "Suitability Index Sugarcane"

*Erasing files 
cap erase "${tables}\rdd_lc_all_p1.tex"
cap erase "${tables}\rdd_lc_all_p1.txt"
cap erase "${tables}\rdd_lc_all_p2.tex"
cap erase "${tables}\rdd_lc_all_p2.txt"
cap erase "${tables}\rdd_lc_all_p3.tex"
cap erase "${tables}\rdd_lc_all_p3.txt"
cap erase "${tables}\rdd_lc_all_p4.tex"
cap erase "${tables}\rdd_lc_all_p4.txt"
cap erase "${tables}\rdd_lc_all_p5.tex"
cap erase "${tables}\rdd_lc_all_p5.txt"

foreach var of global lc1{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global lc2{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lc3{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_all_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lc4{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_all_p4.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lc5{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_all_p5.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* Plots
*-------------------------------------------------------------------------------
gl lc "elevation2 slope rugged hydrography rail_road d_city45 dist_city45 dist_comms45 comms45_dens high_pop80_swithin reform grown80_swithin d_parr80 dist_parr80 z_crops bean79 coffee79 cotton79 maize79 rice79 sugarcane79"
gl resid "elevation2_r slope_r rugged_r hydrography_r rail_road_r d_city45_r dist_city45_r dist_comms45_r comms45_dens_r high_pop80_swithin_r reform_r grown80_swithin_r d_parr80_r dist_parr80_r z_crops_r bean79_r coffee79_r cotton79_r maize79_r rice79_r sugarcane79_r"


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


*-------------------------------------------------------------------------------
* Summary stats 
*-------------------------------------------------------------------------------
*Labeling for this table
la var elevation2 "Altitude"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway"
la var coffee79 "Coffe Potential Yield"
la var cotton79 "Cotton Potential Yield"
la var maize79 "Maize Potential Yield"
la var rice79 "Wet Rice Potential Yield"
la var bean79 "Bean Potential Yield"
la var sugarcane79 "Sugarcane Potential Yield"
la var dist_coast "Distance to Coast"
la var dist_capital "Distance to Capital"
la var rain_z "Rainfall"
la var max_temp_z "Max Temperature"
la var min_temp_z "Min Temperature"
la var d_city45 "Had a City/Village"
la var dist_city45 "Distance to City/Village"
la var dist_comms45 "Distance to Comms"
la var comms45_dens "Comms Density"
la var high_pop80_swithin "High Populated area"
la var reform "Had Land Reform"
la var d_parr80 "Had a Parish"
la var dist_parr80 "Distance to Parish"
la var grown80_swithin "Cultivated area"
la var z_crops "Z-Potential Yield"
la var dist_schl80 "Distance to School"
la var pop_bornbef80_always "Total Population"
la var dens_pop_bornbef80 "Population density"
la var mean_educ_years_wnsage "Years of Education"
la var sh_before_war_child "Natality Rate"
la var sh_before_war_inmigrant "In-migration (Share)"
la var sh_before_war_outmigrant "Out-migration (Share)"
la var sibean "Bean Suitability Index"
la var sicoffee "Coffee Suitability Index" 
la var simaize "Maize Suitability Index" 
la var sisugar "Sugarcane Suitability Index"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gen sample =( abs(z_run_cntrl)<=${h})

*Descriptives for the sample chosen 
tabstat $lc1 $lc2 $lc3 $lc4 sibean sicoffee simaize sisugar if sample==1, s(mean N) save
tabstatmat A
mat A=A'

tabstat $lc1 $lc2 $lc3 $lc4 sibean sicoffee simaize sisugar if sample==0, s(mean N) save
tabstatmat B
mat B=B'

mat S=A,B

tempfile X
frmttable using `X', statmat(S) ctitle("", "Mean", "Obs", "Mean", "Obs") sdec(3,0,3,0) varlabels fragment tex nocenter replace  	
filefilter `X' "${tables}/summary_stats_lc_all.tex", from("{tabular}\BS\BS") to("{tabular}") replace







*END
