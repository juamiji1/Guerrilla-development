
*-------------------------------------------------------------------------------
* 						Preparing the data 
*
*-------------------------------------------------------------------------------
import delimited "${data}\gis\maps_interim\segm_info_dists.csv", clear

ren seg_id segm_id
tostring segm_id, replace
replace segm_id="0"+segm_id if length(segm_id)==7

keep segm_id nl_*
destring nl_q25 nl_q75 nl_q10 nl_q90 nl_gini nl_gini_w, replace force

gen arcsine_nlq25=ln(nl_q25 +sqrt(nl_q25^2+1))
gen arcsine_nlq75=ln(nl_q75 +sqrt(nl_q75^2+1))

gen arcsine_nlq10=ln(nl_q10 +sqrt(nl_q10^2+1))
gen arcsine_nlq90=ln(nl_q90 +sqrt(nl_q90^2+1))

gen arcsine_nliqr=arcsine_nlq75-arcsine_nlq25
gen arcsine_nliqr1090=arcsine_nlq90-arcsine_nlq10

la var arcsine_nliqr "Night Light (IQR)"

tempfile NLQ
save `NLQ', replace 

use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear 

merge 1:1 segm_id using `NLQ', nogen 

*-------------------------------------------------------------------------------
* Setting vars
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust ipcf_ppp11_iqr z_run_cntrl, all kernel(triangular)
gl h=2.266
*gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Inequality results
*-------------------------------------------------------------------------------
gl ineqoutcomes "arcsine_nliqr arcsine_nliqr1090 nl_gini nl_gini_w z_wi_iqr iqr_zwi ipcf_ppp11_iqr ln_ipcf_ppp11_iqr itf_m_iqr ilpc_m_iqr inlpc_m_iqr itranext_m_iqr agr_income_iqr iasalp_m_iqr ictapp_m_iqr ip_m_iqr wage_m_iqr"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {
	
	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
	local ++i
}

*Exporting results 
esttab r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16 r17 using "${tables}/rdd_main_all_ineq_nl.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{17}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & NL IQR & NL IQR & NL Gini & NL Gini & Wealth & Wealth & Income & Log Income & HH Total & Labor PC & Non-Labor & Remittances & Agr. & Main Job & Self- & Main Occ. & Hourly \\"' ///
			`" & (75-25)  & (90-10) & & (weighted) & Index & Index & EHPM & EHPM & Income & Income & PC Income & Income & Income & Labor & Employed & Income & Income \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) & (11) & (12) & (13) & (14) & (15) & (16) & (17)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 

gl ineqoutcomes "itf_m_ipr ilpc_m_ipr inlpc_m_ipr itranext_m_ipr agr_income_ipr iasalp_m_ipr ictapp_m_ipr ip_m_ipr wage_m_ipr"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {
	
	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
	local ++i
}

*Exporting results 
esttab r1 r2 r3 r4 r5 r6 r7 r8 r9 using "${tables}/rdd_main_all_ineq_nl_v2.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & HH Total & Labor PC & Non-Labor & Remittances & Agr. & Main Job & Self- & Main Occ. & Hourly \\"' ///
			`" & Income & Income & PC Income & Income & Income & Labor & Employed & Income & Income \\"' ///
			`" & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 
		
		
		
		

*END
