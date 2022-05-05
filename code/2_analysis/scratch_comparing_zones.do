/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: The recommended altitud is 300 masml
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
*ALL SAMPLE
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*gl h=1.25

*gl h=round(${h}, 0.1)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

gl lc1 "elevation2 slope rugged hydrography rain_z min_temp_z max_temp_z rail_road dist_coast" 
gl lc2 "d_city45 dist_city45 dist_comms45 comms45_dens grown80_swithin high_pop80_swithin reform"
gl lc3 "d_parr80 dist_parr80 bean79 coffee79 cotton79 maize79 rice79 sugarcane79 z_crops"


*Erasing files 
cap erase "${tables}\rdd_lc_all_p1.tex"
cap erase "${tables}\rdd_lc_all_p1.txt"
cap erase "${tables}\rdd_lc_all_p2.tex"
cap erase "${tables}\rdd_lc_all_p2.txt"
cap erase "${tables}\rdd_lc_all_p3.tex"
cap erase "${tables}\rdd_lc_all_p3.txt"

*Against the distance
foreach var of global lc1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_all_p1.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
}

foreach var of global lc2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_all_p2.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc3{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_all_p3.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

*CONTROLLING BY ELEVATION
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

drop exz

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

gl lc1 "slope rugged hydrography rain_z min_temp_z max_temp_z rail_road dist_coast" 
gl lc2 "d_city45 dist_city45 dist_comms45 comms45_dens grown80_swithin high_pop80_swithin reform"
gl lc3 "d_parr80 dist_parr80 bean79 coffee79 cotton79 maize79 rice79 sugarcane79 z_crops"

*Erasing files 
cap erase "${tables}\rdd_lc_all_p1_v2.tex"
cap erase "${tables}\rdd_lc_all_p1_v2.txt"
cap erase "${tables}\rdd_lc_all_p2_v2.tex"
cap erase "${tables}\rdd_lc_all_p2_v2.txt"
cap erase "${tables}\rdd_lc_all_p3_v2.tex"
cap erase "${tables}\rdd_lc_all_p3_v2.txt"

*Against the distance
foreach var of global lc1{

	*Table
	reghdfe `var' ${controls} elevation2 c.elevation2#c.z_run_cntrl [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_all_p1_v2.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
}

foreach var of global lc2{

	*Table
	reghdfe `var' ${controls} elevation2 c.elevation2#c.z_run_cntrl [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_all_p2_v2.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc3{

	*Table
	reghdfe `var' ${controls} elevation2 c.elevation2#c.z_run_cntrl [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_all_p3_v2.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}


*-------------------------------------------------------------------------------
*NO VOLCANOS SAMPLE
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400_select"
gl controls "within_control_select i.within_control_select#c.z_run_cntrl_select z_run_cntrl_select"
gl controls_resid "i.within_control_select#c.z_run_cntrl_select z_run_cntrl_select"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl_select, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl_select)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl_select/${h})) ${if}

*Variables to use
gl lc1 "elevation2 slope rugged hydrography rain_z min_temp_z max_temp_z rail_road dist_coast" 
gl lc2 "d_city45 dist_city45 dist_comms45 comms45_dens grown80_swithin high_pop80_swithin reform"
gl lc3 "d_parr80 dist_parr80 bean79 coffee79 cotton79 maize79 rice79 sugarcane79 z_crops"

*Erasing files 
cap erase "${tables}\rdd_lc_cut_p1.tex"
cap erase "${tables}\rdd_lc_cut_p1.txt"
cap erase "${tables}\rdd_lc_cut_p2.tex"
cap erase "${tables}\rdd_lc_cut_p2.txt"
cap erase "${tables}\rdd_lc_cut_p3.tex"
cap erase "${tables}\rdd_lc_cut_p3.txt"

*Against the distance
foreach var of global lc1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_cut_p1.tex", tex(frag) keep(within_control_select) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_cut_p2.tex", tex(frag) keep(within_control_select) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc3{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_cut_p3.tex", tex(frag) keep(within_control_select) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}


*-------------------------------------------------------------------------------
*ABOVE 200mts SAMPLE
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

gl h=1.25

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Erasing files 
cap erase "${tables}\rdd_lc_mts_p1.tex"
cap erase "${tables}\rdd_lc_mts_p1.txt"
cap erase "${tables}\rdd_lc_mts_p2.tex"
cap erase "${tables}\rdd_lc_mts_p2.txt"
cap erase "${tables}\rdd_lc_mts_p3.tex"
cap erase "${tables}\rdd_lc_mts_p3.txt"

*Against the distance
foreach var of global lc1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_mts_p1.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_mts_p2.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc3{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_mts_p3.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}


*-------------------------------------------------------------------------------
*NO CAPITAL SAMPLE
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400_noslv"
gl controls "within_control_noslv i.within_control_noslv#c.z_run_cntrl_noslv z_run_cntrl_noslv"
gl controls_resid "i.within_control_noslv#c.z_run_cntrl_noslv z_run_cntrl_noslv"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl_noslv, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl_noslv)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl_noslv/${h})) ${if}

*Erasing files 
cap erase "${tables}\rdd_lc_noslv_p1.tex"
cap erase "${tables}\rdd_lc_noslv_p1.txt"
cap erase "${tables}\rdd_lc_noslv_p2.tex"
cap erase "${tables}\rdd_lc_noslv_p2.txt"
cap erase "${tables}\rdd_lc_noslv_p3.tex"
cap erase "${tables}\rdd_lc_noslv_p3.txt"

*Against the distance
foreach var of global lc1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_noslv_p1.tex", tex(frag) keep(within_control_noslv) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_noslv_p2.tex", tex(frag) keep(within_control_noslv) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}

foreach var of global lc3{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_lc_noslv_p3.tex", tex(frag) keep(within_control_noslv) addstat("Bandwidth (Km)", ${h}) nolabel nonote nocons append 
	
}


*-------------------------------------------------------------------------------
*NO COAST SAMPLE
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400_high"
gl controls "within_control_high i.within_control_high#c.z_run_cntrl_high z_run_cntrl_high"
gl controls_resid "i.within_control_high#c.z_run_cntrl_high z_run_cntrl_high"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl_high, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl_high)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl_high/${h})) ${if}

*Erasing files 
cap erase "${tables}\rdd_lc_high_p1.tex"
cap erase "${tables}\rdd_lc_high_p1.txt"
cap erase "${tables}\rdd_lc_high_p2.tex"
cap erase "${tables}\rdd_lc_high_p2.txt"
cap erase "${tables}\rdd_lc_high_p3.tex"
cap erase "${tables}\rdd_lc_high_p3.txt"

*Against the distance
foreach var of global lc1{

	*Dependent's var mean
	summ `var', d
	gl mean_all=round(r(mean), .01)

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1, d
	gl mean_s=round(r(mean), .01)
	summ `var' if e(sample)==1 & within_control_high==0, d
	gl mean_c=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_high_p1.tex", tex(frag) keep(within_control_high) addstat("Bandwidth (Km)", ${h}, "Mean (all)", ${mean_all}, "Mean (sample)", ${mean_s}, "Mean (controls)", ${mean_c}) nolabel nonote nocons append 
	
}

foreach var of global lc2{

	*Dependent's var mean
	summ `var', d
	gl mean_all=round(r(mean), .01)

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1, d
	gl mean_s=round(r(mean), .01)
	summ `var' if e(sample)==1 & within_control_high==0, d
	gl mean_c=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_high_p2.tex", tex(frag) keep(within_control_high) addstat("Bandwidth (Km)", ${h}, "Mean (all)", ${mean_all}, "Mean (sample)", ${mean_s}, "Mean (controls)", ${mean_c}) nolabel nonote nocons append 
	
}

foreach var of global lc3{

	*Dependent's var mean
	summ `var', d
	gl mean_all=round(r(mean), .01)

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1, d
	gl mean_s=round(r(mean), .01)
	summ `var' if e(sample)==1 & within_control_high==0, d
	gl mean_c=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_high_p3.tex", tex(frag) keep(within_control_high) addstat("Bandwidth (Km)", ${h}, "Mean (all)", ${mean_all}, "Mean (sample)", ${mean_s}, "Mean (controls)", ${mean_c}) nolabel nonote nocons append 
	
}




*-------------------------------------------------------------------------------
*MAIN RESULTS


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
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate z_wi_iqr z_wi_iqr2 z_wi_iqr3 z_wi_p50"

*Erasing table before exporting
cap erase "${tables}\rdd_main_all.tex"
cap erase "${tables}\rdd_main_all.txt"

foreach var of global nl{
	
	*Dependent's var mean
	summ `var', d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	outreg2 using "${tables}\rdd_main_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
	*replace `var'_r=. if e(sample)!=1

}








*END

