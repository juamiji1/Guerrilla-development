/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes but with conley SE
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var mean_educ_years "Years of Education (2007)"
la var z_wi "Wealth Index (2007)"

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"

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
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl main "arcsine_nl13 z_wi mean_educ_years"

*Creating needed vars bc the command does not accept factor vars
gen wcxz=within_control*z_run_cntrl 
tab control_break_fe_400, g(fe_)

*New globals to use 
gl controls "within_control wcxz z_run_cntrl"

local r replace
*Estimation with Conley SE
foreach var of global main{

	*Actual estimations using acreg package 
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(.5) pfe1(${breakfe}) dropsingletons 
	outreg2 using "${tables}/rdd_main_all_conley500kms.tex", tex(frag) keep(within_control)  addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 0.5) label nonote nocons append 
	
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(2) pfe1(${breakfe})  dropsingletons 
	outreg2 using "${tables}/rdd_main_all_conley2kms.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 2) label nonote nocons append 	
	
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(4) pfe1(${breakfe}) dropsingletons 
	outreg2 using "${tables}/rdd_main_all_conley4kms.tex", tex(frag) keep(within_control)  addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 4) label nonote nocons `r'
	
	local r append 
}

foreach conley in 2 4 {
preserve 
 insheet using "${tables}/rdd_main_all_conley`conley'kms.txt", nonames clear
save "${tables}/rdd_main_all_conley`conley'kms" , replace 
restore 
}

preserve 
 insheet using "${tables}/rdd_main_all_conley500kms.txt", nonames clear
append using "${tables}/rdd_main_all_conley2kms"
append using "${tables}/rdd_main_all_conley4kms"


insobs 3, before(1)
replace v3 = "Night Light Luminosity" in 2
replace v3 = "(2013)" in 3
replace v4 = "Wealth Index" in 2
replace v4 = "(2007)" in 3
replace v5 = "Years of Education" in 2
replace v5 = "(2007)" in 3
drop in 5
replace v1 = "Panel A: Conley Standard Errors (0.5 Km)" in 1
drop v2 
drop in 14
replace v3 = "" in 13
replace v4 = "" in 13
replace v5 = "" in 13
replace v1 = "Panel B: Conley Standard Errors (2 Km)" in 13
drop in 23
replace v1 = "Panel C: Conley Standard Errors (4 Km)" in 22
replace v3 = "" in 22
replace v4 = "" in 22
replace v5 = "" in 22
drop in 12
drop in 20
drop in 28
drop in 26
drop in 10/11
drop in 16/17
replace v1 = "Guerrilla control" in 6
replace v1 = "Guerrilla control" in 12
replace v1 = "Guerrilla control " in 18

dataout, tex save("${tables}/rdd_main_all_conley_draft") replace nohead  midborder(3)

restore 


foreach conley in 2 4 {
 
cap erase "${tables}/rdd_main_all_conley`conley'kms.dta" 

}


*END
