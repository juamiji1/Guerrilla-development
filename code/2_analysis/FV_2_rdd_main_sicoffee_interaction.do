clear all 

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

*Standardizing Suitability Index
foreach var in sibean sicoffee simaize sisugar {
	egen z_`var'=std(`var')
	gen m_`var'=(`var'>4000) if `var'!=.	
	gen g_`var'=(`var'>5500) if `var'!=.	
	gen h_`var'=(`var'>7000) if `var'!=.	
	gen vh_`var'=(`var'>8500) if `var'!=.	
}

gen x=(h_sicoffee==0)
drop h_sicoffee
gen h_sicoffee=x

gen wc_hsicoffee=within_control*h_sicoffee

summ z_sicoffee, d
gen d_sicoffee=(z_sicoffee<=`r(p50)') if z_sicoffee!=.

gen wc_dsicoffee=within_control*d_sicoffee

la var h_sicoffee "Low Coffee Suitability (FAO)"
la var d_sicoffee "Low Coffee Suitability (Median)"
la var wc_hsicoffee "Control $\times$ High Coffee Suitability (FAO)"
la var wc_dsicoffee "Control $\times$ High Coffee Suitability (Median)"

gl mainoutcomes "arcsine_nl13 z_wi mean_educ_years"

local i=1
foreach yvar of global mainoutcomes{
	*Base Estimation
	eststo a`i': reghdfe `yvar' ${controls} wc_dsicoffee d_sicoffee [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	eststo b`i': reghdfe `yvar' ${controls} wc_hsicoffee h_sicoffee [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
	local ++i
}

*Exporting results 
esttab a1 a2 a3 using "${tables}/rdd_main_all_wc_dsicoffee.tex", keep(within_control wc_dsicoffee ) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 

*Exporting results 
esttab b1 b2 b3 using "${tables}/rdd_main_all_wc_hsicoffee.tex", keep(within_control wc_hsicoffee) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 
		
		
*END