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
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*gl h=round(${h}, 0.1)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc "elevation2 slope rugged hydrography rain_z min_temp_z max_temp_z rail_road dist_capital dist_coast dist_depto mean_cocoa mean_coffee mean_cotton mean_dryrice mean_wetrice mean_bean mean_sugarcane"

foreach var of global lc{
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
}

*Against the distance
foreach var in elevation2 slope rugged{
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
	*Predicting outcomes
	cap drop `var'_xb
	predict `var'_xb, xb
	
}

reghdfe elevation2 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample=e(sample)


keep segm_id elevation2* slope* rugged* control_break_fe_400 sample within_control
export excel using "${data}/gis\maps_interim\predicted_outcomes_nowater.xls", firstrow(variables) replace

log using "${do}\within_break_differences.txt", text replace 

local felist=""
levelsof control_break_fe_400 if sample==1, local(fe)
foreach n of local fe{	
	dis "----------BREAK is `n'"
	*Checking obs 
	tabstat elevation2 if control_break_fe_400==`n' & sample==1, by(within_control) s(N) save
	mat X1=r(Stat1) 
	mat X2=r(Stat2) 
	
	if X1[1,1]!=. & X2[1,1]!=.{
		ttest elevation2 if control_break_fe_400==`n' & sample==1, by(within_control)
		
		if `r(p_l)'<=0.1{
			local felist `felist' `n'
			dis "`felist'"
		}
	} 
}

gl felist="`felist'"
dis "${felist}"


 
log c








