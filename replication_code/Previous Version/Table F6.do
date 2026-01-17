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
sum z_run_cntrl if within_control==1
gl h=r(max)

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

*Creating donut holes with respect to centroid.

gen sample1=abs(z_run_cntrl)<=${h} // Full Sample

gen sample2=sample1 // 1km donut hole
replace sample2=0 if abs(z_run_cntrl_v2)<=1

gen sample3=sample1 // 2km donut hole
replace sample3=0 if abs(z_run_cntrl_v2)<=2

gen sample4=sample1 // 3 km donut hole
replace sample4=0 if abs(z_run_cntrl_v2)<=3

gen sample5=sample1 // 4 donut hole
replace sample5=0 if abs(z_run_cntrl_v2)<=4


foreach var of global nl1{
	local r replace 
    global dh=0
	forvalues n=1/5 {
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if} & sample`n'==1, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_main_`var'_MAXkmBDW_DH.tex", tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}, "Donut Hole (Km)",${dh}) label nonote nor2 nocons `r'
	local r append
	gl dh=${dh}+1
	}
	
}


foreach var in z_wi mean_educ_years {
preserve 
 insheet using "${tables}/rdd_main_`var'_MAXkmBDW_DH.txt", nonames clear
save "${tables}/rdd_main_`var'_MAXkmBDW_DH" , replace 
restore 
}

preserve 
 insheet using "${tables}/rdd_main_arcsine_nl13_MAXkmBDW_DH.txt", nonames clear
 append using "${tables}/rdd_main_z_wi_MAXkmBDW_DH"
 append using "${tables}/rdd_main_mean_educ_years_MAXkmBDW_DH"
 
 
drop v2 
drop in 8
drop in 9
drop in 18
drop in 16
drop in 17
drop in 10
drop in 1
replace v1 = "Guerrilla control" in 3
replace v1 = "Guerrilla control" in 10
replace v1 = "Guerrilla control" in 17
replace v3 = "" in 1
replace v3 = "" in 15
replace v3 = "" in 8
replace v4 = "" in 8
replace v5 = "" in 8
replace v6 = "" in 8
replace v7 = "" in 8
replace v4 = "" in 1
replace v5 = "" in 1
replace v6 = "" in 1
replace v7 = "" in 1
replace v4 = "" in 15
replace v5 = "" in 15
replace v6 = "" in 15
replace v7 = "" in 15
replace v1 = "Panel A: Night Light Luminosity (2013)" in 1
replace v1 = "Panel B: Wealth Index (2007)" in 9
replace v1 = " Panel C: Years of Education (2007)" in 15

 
local Pen=_N-2
gen n=_n 
replace n=90000 in `Pen'

local Pen=_N
replace n=900000 in `Pen'

sort n 
drop n

drop in 8
insobs 1, before(9)
insobs 1, before(22)


dataout, tex save("${tables}/rdd_main_MAXkmBDW_DH") replace nohead  midborder(1)

restore 



foreach var in z_wi mean_educ_years {

erase "${tables}/rdd_main_`var'_MAXkmBDW_DH.dta" 

}
