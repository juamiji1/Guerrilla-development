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
gl h=2.266
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


*-------------------------------------------------------------------------------
* 						Quantile regression 
*
* NOTE: Point estimates and SEs in the tables come from the weighted qreg fits
* below. To test whether the effect differs across quantiles we need a joint 
* VCE across quantiles, which sqreg provides via bootstrap but only without 
* weights. So the p-value rows at the bottom of the tables come from an 
* unweighted sqreg (same RD sample, same controls and border FE) and lincom.
*-------------------------------------------------------------------------------
*Bootstrap replications for the cross-quantile tests (set ${qreps} before running to override)
if "${qreps}"=="" gl qreps=500
set maxiter 5000

*Program: runs unweighted sqreg and stores cross-quantile test p-values in globals
*   ${p_`tag'_50}, ${p_`tag'_75}, ${p_`tag'_90}: lincom [qXX] - [q25] = 0
*   ${p_`tag'_all}: joint test q25 = q50 = q75 = q90
cap program drop qreg_quants_test
program define qreg_quants_test
	syntax varname, tag(string) sample(varname)
	set seed 12345
	sqreg `varlist' ${controls} i.${breakfe} ${if} & `sample'==1, q(.25 .5 .75 .9) reps(${qreps})
	foreach q in 50 75 90 {
		lincom [q`q']within_control - [q25]within_control
		gl p_`tag'_`q': di %5.3f r(p)
	}
	test [q25]within_control=[q50]within_control=[q75]within_control=[q90]within_control
	gl p_`tag'_all: di %5.3f r(p)
end

*-------------------------------------------------------------------------------
* 						Quantile regression - Wealth index
*
*-------------------------------------------------------------------------------
eststo clear

reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(r) abs(i.${breakfe})
gen rdsample=1 if e(sample)==1

eststo q1: qreg z_wi ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample==1, q(.1) vce(r) iterate(1000)
eststo q2: qreg z_wi ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample==1, q(.25) vce(r) iterate(1000)
eststo q3: qreg z_wi ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample==1, q(.5) vce(r) iterate(1000)
eststo q4: qreg z_wi ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample==1, q(.75) vce(r) iterate(1000)
eststo q5: qreg z_wi ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample==1, q(.9) vce(r) iterate(1000)

*Tests of equality of the effect across quantiles (unweighted sqreg + lincom)
qreg_quants_test z_wi, tag(zwi) sample(rdsample)

*Exporting results dummy
esttab q2 q3 q4 q5 using "${tables}/rdd_main_all_qregzwi.tex", keep(within_control) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) replace ///
    prehead(`"\begin{tabular}{@{}l*{4}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & \multicolumn{4}{c}{Wealth Index (2007)} \\"' ///
            `"\cline{2-5}"' ///
            `" & Quantile 25 & Quantile 50 & Quantile 75 & Quantile 90 \\"' ///
            `" & (1) & (2) & (3) & (4) \\"' ///
            `"\midrule"') ///
    postfoot(`"Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
			`"\addlinespace"' ///
			`"p-value: effect equal to Quantile 25 & -- & ${p_zwi_50} & ${p_zwi_75} & ${p_zwi_90} \\"' ///
			`"p-value: effect equal across all quantiles & \multicolumn{4}{c}{${p_zwi_all}} \\"' ///
			`"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* 						Quantile regression - Years of education
*
*-------------------------------------------------------------------------------
eststo clear

reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(r) abs(i.${breakfe})
gen rdsample_educ=1 if e(sample)==1

eststo e1: qreg mean_educ_years ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample_educ==1, q(.1) vce(r) iterate(1000)
eststo e2: qreg mean_educ_years ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample_educ==1, q(.25) vce(r) iterate(1000)
eststo e3: qreg mean_educ_years ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample_educ==1, q(.5) vce(r) iterate(1000)
eststo e4: qreg mean_educ_years ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample_educ==1, q(.75) vce(r) iterate(1000)
eststo e5: qreg mean_educ_years ${controls} i.${breakfe} [pw=tweights] ${if} & rdsample_educ==1, q(.9) vce(r) iterate(1000)

*Tests of equality of the effect across quantiles (unweighted sqreg + lincom)
qreg_quants_test mean_educ_years, tag(educ) sample(rdsample_educ)

*Exporting results dummy
esttab e2 e3 e4 e5 using "${tables}/rdd_main_all_qregeduc.tex", keep(within_control) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) replace ///
    prehead(`"\begin{tabular}{@{}l*{4}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & \multicolumn{4}{c}{Years of Education (2007)} \\"' ///
            `"\cline{2-5}"' ///
            `" & Quantile 25 & Quantile 50 & Quantile 75 & Quantile 90 \\"' ///
            `" & (1) & (2) & (3) & (4) \\"' ///
            `"\midrule"') ///
    postfoot(`"Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
			`"\addlinespace"' ///
			`"p-value: effect equal to Quantile 25 & -- & ${p_educ_50} & ${p_educ_75} & ${p_educ_90} \\"' ///
			`"p-value: effect equal across all quantiles & \multicolumn{4}{c}{${p_educ_all}} \\"' ///
			`"\bottomrule \end{tabular}"')


*END
