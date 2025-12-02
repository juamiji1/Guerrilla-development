clear all 

use "${data}/temp\census9207_canton_lvl.dta", clear 

merge 1:1 id07 using "${data}/temp\lapop_canton_lvl.dta", keep(1 3) nogen 

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl92 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels
la var sum_pp "Political Participation (sum)"
la var sum_ep "Engagement with Politicians (sum)"
la var sum_ap "Non-Democratic Engagement (sum)"
la var sum_trst "Trust in Institutions (sum)"


*-------------------------------------------------------------------------------
* 						Attitudes outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl trst "sum_pp sum_ep sum_ap sum_trst conf_com_low"
*conf_com_low

*Erasing table before exporting
local i=1
foreach var of global trst{
	
	*Table
	eststo r`i': reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) keepsing 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 r4 r5 using "${tables}/Table_lapop_canton_bw.tex", keep(within_control) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(3) replace ///
	prehead(`"\begin{tabular}{l*{5}{c}}"' ///
			`"\hline \hline \toprule"' ///
			`" & \multicolumn{4}{c}{\textit{Total Sum of Questions per Item/Scope}} & \\"' ///
			`"\cmidrule(lr){2-5}"' ///
			`" & Political & Engagement & Non-Democratic & Trust in & Distrust of Members \\"' ///
			`" & Participation & with Politicians & Engagement & Institutions & of the Community (Share) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) \\"' ///
			`"\midrule"') ///
	postfoot(`"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
			 `"Dependent mean & ${mean_ry1} & ${mean_ry2} & ${mean_ry3} & ${mean_ry4} & ${mean_ry5} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

*Global of outcomes
gl trst "sum_pp sum_ep sum_ap sum_trst conf_com_low"
*conf_com_low

*Erasing table before exporting
local i=1
foreach var of global trst{
	
	*Table
	eststo r`i': reghdfe `var' ${controls}, vce(r) a(i.${breakfe}) keepsing 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 r4 r5 using "${tables}/Table_lapop_canton_all.tex", keep(within_control) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(3) replace ///
	prehead(`"\begin{tabular}{l*{5}{c}}"' ///
			`"\hline \hline \toprule"' ///
			`" & \multicolumn{4}{c}{\textit{Total Sum of Questions per Item/Scope}} & \\"' ///
			`"\cmidrule(lr){2-5}"' ///
			`" & Political & Engagement & Non-Democratic & Trust in & Distrust of Members \\"' ///
			`" & Participation & with Politicians & Engagement & Institutions & of the Community (Share) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) \\"' ///
			`"\midrule"') ///
	postfoot(`"Bandwidth (Km) &  &  &  &  &  \\"' ///
			 `"Dependent mean & ${mean_ry1} & ${mean_ry2} & ${mean_ry3} & ${mean_ry4} & ${mean_ry5} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')
