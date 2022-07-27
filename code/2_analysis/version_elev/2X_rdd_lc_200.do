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

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc1 "elevation2 slope rugged hydrography rail_road d_city45 dist_city45" 
gl lc2 "dist_comms45 comms45_dens high_pop80_swithin reform grown80_swithin d_parr80 dist_parr80"
gl lc3 "z_crops bean79 coffee79 cotton79 maize79 rice79 sugarcane79"

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

*Erasing files 
cap erase "${tables}\rdd_lc_200_p1.tex"
cap erase "${tables}\rdd_lc_200_p1.txt"
cap erase "${tables}\rdd_lc_200_p2.tex"
cap erase "${tables}\rdd_lc_200_p2.txt"
cap erase "${tables}\rdd_lc_200_p3.tex"
cap erase "${tables}\rdd_lc_200_p3.txt"

foreach var of global lc1{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_200_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global lc2{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_200_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global lc3{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_lc_200_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}






*END
