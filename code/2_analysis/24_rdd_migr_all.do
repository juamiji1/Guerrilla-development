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

*-------------------------------------------------------------------------------
* 					Mechanisms related to migration
*-------------------------------------------------------------------------------
gl migr "sh_war_migrant sh_migrant years_left remittance_rate war_remittance always_sh mother_sh arrived_war year_arrive"
gl migrheduc "sh_war_migrant_heduc sh_migrant_heduc years_left_heduc remittance_rate_heduc war_remittance_heduc always_heduc mother_heduc arrived_war_heduc year_arrive_heduc"

gl migr1 "sh_war_migrant war_migrant war_migrant_pop sh_migrant total_migrant total_migrant_pop years_left"
gl migr2 "sh_war_migrant_heduc war_migrant_heduc war_migrant_pop_heduc sh_migrant_heduc total_migrant_heduc total_migrant_pop_heduc years_left_heduc"
gl migr3 "always_sh mother_sh arrived_war year_arrive"
gl migr4 "always_heduc mother_heduc year_arrive_heduc arrived_war_heduc"
gl migr5 "war_migrant_pop total_migrant_pop years_left remittance_rate war_remittance always_sh mother_sh arrived_war year_arrive"
gl migr6 "war_migrant_pop_leduc total_migrant_pop_leduc years_left_leduc always_leduc mother_leduc arrived_war_leduc year_arrive_leduc"

*Labeling for tables 
la var sh_war_migrant "Share of Migrants during control"
la var war_migrant "Migrants during control"
la var sh_migrant "Share of Migrants"
la var total_migrant "Total migrants"
la var years_left "Years since departure"
la var war_migrant_pop "Migrants during control over population"
la var total_migrant_pop "Share of Migrants over population"

la var sh_war_migrant_heduc "Share of Migrants during control"
la var war_migrant_heduc "Migrants during control"
la var sh_migrant_heduc "Share of Migrants"
la var total_migrant_heduc "Total migrants"
la var years_left_heduc "Years since departure"
la var war_migrant_pop_heduc "Migrants during control over population"
la var total_migrant_pop_heduc "Share of Migrants over population"

la var always_sh "Share of Always lived"
la var mother_sh "Share of Same tract as mother"
la var year_arrive "Years since arrival"
la var arrived_war "Share of Arrived during control"

la var always_heduc "Share of Always lived"
la var mother_heduc "Share of Same tract as mother"
la var year_arrive_heduc "Years since arrival"
la var arrived_war_heduc "Share of Arrived during control"

la var remittance_rate "Received Remittance"
la var war_remittance "War Remittance"

*Erasing files 
cap erase "${tables}\rdd_migr_all.tex"
cap erase "${tables}\rdd_migr_all.txt"
cap erase "${tables}\rdd_migr_all_heduc.tex"
cap erase "${tables}\rdd_migr_all_heduc.txt"


*Tables
foreach var of global migr{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_migr_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*Tables
foreach var of global migrheduc{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_migr_all_heduc.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}








*END
