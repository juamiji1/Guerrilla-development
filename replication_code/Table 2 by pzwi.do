/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 
eststo clear 

*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

summ z_wi, d

gen pcat_zwi=0 if z_wi<`r(p25)' 
replace pcat_zwi=1 if z_wi>=`r(p25)' & z_wi<`r(p75)' 
replace pcat_zwi=2 if z_wi>=`r(p75)' 

tab pcat_zwi, g(pcat_zwi_)

gen within_pzwi1=within_control*pcat_zwi_1
gen within_pzwi2=within_control*pcat_zwi_2
gen within_pzwi3=within_control*pcat_zwi_3

*Labels for outcomes
la var arcsine_nl13 "Night Light Luminosity"
la var z_wi "Wealth Index"
la var mean_educ_years "Years of Education"

la var within_pzwi1 "Control $\times$ $\mathbb{I}[\text{Wealth Index} < \text{p25}]$ "
la var within_pzwi3 "Control $\times$ $\mathbb{I}[\text{Wealth Index} > \text{p75}]$ "

*-------------------------------------------------------------------------------
* 						Capturing BW and Weights
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)
gl ht= round(${h}, .001)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl main "arcsine_nl13 mean_educ_years"

*Results
local i=1
foreach var of global main{
	
	*Table
	eststo r`i': reghdfe `var' within_pzwi1 within_pzwi3 ${controls} pcat_zwi_1 pcat_zwi_3 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y`i'=round(r(mean), .001)
	
	local ++i

}

*-------------------------------------------------------------------------------
* Table 
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 using "${tables}/rdd_main_all_byzwi.tex", keep(within_control within_pzwi1 within_pzwi3) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{2}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light Luminosity & Years of Education \\"' ///
            `" & (2013) & (2007) \\"' ///
            `" & (1) & (2) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Bandwidth (Km) & ${ht} & ${ht} \\"' ///
	`" Dependent mean & ${mean_y1} & ${mean_y2} \\"' ///	
	`"\bottomrule \end{tabular}"') 


