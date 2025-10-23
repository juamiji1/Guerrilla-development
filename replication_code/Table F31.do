/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

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
la var arcsine_nl13 "Night Light Luminosity"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"
la var z_wi_iqr "Wealth Index Range (p75-p25)"
la var z_wi_iqr2 "Wealth Index Range (p95-p5)"
la var z_wi_iqr3 "Wealth Index Range (p90-p10)"
la var z_wi_p50 "Median Wealth Index"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl1 "arcsine_nl13 z_wi mean_educ_years"

 gen dens_pop_bornbef80=pop_bornbef80_always/AREA_K

 sum dens_pop_bornbef80, d
 gen highly_dense_80=dens_pop_bornbef80>r(p50)

 local r replace
foreach var of global nl1{
	
	foreach filter in d_city==0 highly_dense_80==0 {
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if} & `filter' , vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_main_all_p1_`filter'.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nor2 nocons `r'
	
	}
	local r append 
}



preserve 
 insheet using "${tables}/rdd_main_all_p1_highly_dense_80==0.txt", nonames clear
 save "${tables}/rdd_main_all_p1_highly_dense_80==0", replace
restore 

preserve 
 insheet using "${tables}/rdd_main_all_p1_d_city==0.txt", nonames clear
 append using "${tables}/rdd_main_all_p1_highly_dense_80==0"

insobs 3, before(1)
drop in 11
drop in 13
replace v1 = "Panel A: Had a City or Village in 1945" in 1
replace v2 = "Night Light Luminosity" in 2
replace v2 = "(2013)" in 3
replace v3 = "Wealth Index" in 2
replace v3 = "(2007)" in 3
replace v4 = "Years of Education" in 2
replace v4 = "(2007)" in 3
drop in 5
replace v1 = "Guerrilla control" in 6
replace v2 = "" in 11
replace v3 = "" in 11
replace v4 = "" in 11
replace v1 = "Panel B: Population Density in 1980 Above the Median" in 11
replace v1 = "Guerrilla control" in 13
local Pen=_N-1
gen n=_n 
replace n=90000 in `Pen'
sort n 
drop n
dataout, tex save("${tables}/rdd_urban_centers") replace nohead midborder(4)

restore 


