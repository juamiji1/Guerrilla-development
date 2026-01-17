/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring migration mechanism
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


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
gl migrheduc "sh_war_migrant_heduc sh_migrant_heduc years_left_heduc remittance_rate_heduc war_remittance_heduc always_heduc mother_heduc arrived_war_heduc year_arrive_heduc"

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

*Tables
local r replace
foreach var of global migrheduc{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_migr_all_heduc.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nocons `r'
	local r append

}


preserve 
 insheet using "${tables}/rdd_migr_all_heduc.txt", nonames clear

insobs 3, before(1)
replace v1 = "" in 5
replace v1 = "Guerrilla control" in 7
drop in 5
replace v2 = "International Migrants" in 1
replace v2 = "During Control" in 2
replace v2 = "(Share)" in 3
replace v3 = "At any Time" in 2
replace v3 = "(Share)" in 3
replace v4 = "Years since " in 2
replace v4 = "Departure" in 3
replace v5 = "Households that Received " in 2
replace v5 = "Remittances (Share)" in 3
replace v6 = "Received Remittance from" in 2
replace v6 = "War Migrant (Share)" in 3
replace v7 = "Always Lived in" in 1
replace v7 = "Same Location" in 2
replace v7 = "(Share)" in 3
replace v8 = "Same Location " in 1
replace v8 = "as the Mother" in 2
replace v8 = "(Share)" in 3
replace v9 = "People who Arrived" in 1
replace v9 = "During Control" in 2
replace v9 = "(Share)" in 3
replace v10 = "Years since" in 1
replace v10 = "Arrival" in 2

dataout, tex save("${tables}/rdd_migr_all_heduc") replace nohead midborder(4)

restore 
*END
