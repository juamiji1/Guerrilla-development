
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

*-------------------------------------------------------------------------------
* EHPM income spreads: 90/10 ratios and winsorized (p1/p99) 90-10 differences
* (household-level construction mirrors FV_1_prepare_ephm_segm_lvl.do)
*-------------------------------------------------------------------------------
use segment_id id year pondera itf_m inlpc_m itranext_m iasalp_m ip_m wage_m using "${data}/ehpm\ehpm_2000_2017_mjsp.dta", clear

*Collapsing at the household level
collapse (max) pondera itf_m inlpc_m itranext_m iasalp_m ip_m wage_m, by(segment_id id year)

*Keeping the latest year
bys segment_id: egen max_year=max(year)
keep if year==max_year

gl incnew "itf_m inlpc_m itranext_m iasalp_m ip_m wage_m"

foreach var of global incnew{

	*90/10 ratio (defined only for tracts whose p10 is positive)
	cap drop x y
	bys segment_id: egen y = pctile(`var'), p(90)
	bys segment_id: egen x = pctile(`var'), p(10)
	gen `var'_rat9010 = y/x if x>0 & x!=.

	*Winsorizing households at the pooled p1/p99 before computing spreads
	_pctile `var', p(1 99)
	gen `var'_w = `var'
	replace `var'_w = r(r1) if `var'_w<r(r1) & `var'_w!=.
	replace `var'_w = r(r2) if `var'_w>r(r2) & `var'_w!=.

	cap drop x y
	bys segment_id: egen y = pctile(`var'_w), p(90)
	bys segment_id: egen x = pctile(`var'_w), p(10)
	gen `var'_iprw = y - x
}

*Collapsing at the segment lvl
collapse (mean) *_rat9010 *_iprw [aw=pondera], by(segment_id)

ren segment_id segm_id
keep if length(segm_id)==8

tempfile INEQW
save `INEQW', replace

use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear

merge 1:1 segm_id using `NLQ', nogen
merge 1:1 segm_id using `INEQW', nogen keep(1 3)

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

gl ht=2.266

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

*Version 1: current 90-10 dollar differences, now with dependent means
gl ineqoutcomes "itf_m_ipr inlpc_m_ipr itranext_m_ipr iasalp_m_ipr ip_m_ipr wage_m_ipr"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_a`i'=string(r(mean), "%9.2f")

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_main_all_ineq_nl_v2.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & HH Total & Non-Labor & Remittances & Main Job & Main Occ. & Hourly \\"' ///
			`" & Income & PC Income & Income & Labor & Income & Income \\"' ///
			`" & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Dependent mean & ${mean_a1} & ${mean_a2} & ${mean_a3} & ${mean_a4} & ${mean_a5} & ${mean_a6} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')

*Version 2: 90/10 ratios with dependent means
gl ineqoutcomes "itf_m_rat9010 inlpc_m_rat9010 itranext_m_rat9010 iasalp_m_rat9010 ip_m_rat9010 wage_m_rat9010"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_b`i'=string(r(mean), "%9.2f")

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_main_all_ineq_nl_rat9010.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & HH Total & Non-Labor & Remittances & Main Job & Main Occ. & Hourly \\"' ///
			`" & Income & PC Income & Income & Labor & Income & Income \\"' ///
			`" & (90/10) & (90/10) & (90/10) & (90/10) & (90/10) & (90/10) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Dependent mean & ${mean_b1} & ${mean_b2} & ${mean_b3} & ${mean_b4} & ${mean_b5} & ${mean_b6} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')

*Version 3: 90-10 differences after winsorizing incomes at p1/p99, with dependent means
gl ineqoutcomes "itf_m_iprw inlpc_m_iprw itranext_m_iprw iasalp_m_iprw ip_m_iprw wage_m_iprw"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_c`i'=string(r(mean), "%9.2f")

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_main_all_ineq_nl_wins.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & HH Total & Non-Labor & Remittances & Main Job & Main Occ. & Hourly \\"' ///
			`" & Income & PC Income & Income & Labor & Income & Income \\"' ///
			`" & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) & (90-10) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Dependent mean & ${mean_c1} & ${mean_c2} & ${mean_c3} & ${mean_c4} & ${mean_c5} & ${mean_c6} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 
		
gl ineqoutcomes "itf_m_ipr5 ilpc_m_ipr5 inlpc_m_ipr5 itranext_m_ipr5 iasalp_m_ipr5 ip_m_ipr5 wage_m_ipr5"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 r7 using "${tables}/rdd_main_all_ineq_nl_v3.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{7}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & HH Total & Labor PC & Non-Labor & Remittances & Main Job & Main Occ. & Hourly \\"' ///
			`" & Income & Income & PC Income & Income & Labor & Income & Income \\"' ///
			`" & (95-5) & (95-5) & (95-5) & (95-5) & (95-5) & (95-5) & (95-5) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')
		
gl ineqoutcomes "itf_m_rat ilpc_m_rat inlpc_m_rat itranext_m_rat agr_income_rat iasalp_m_rat ictapp_m_rat ip_m_rat wage_m_rat"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {
	
	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
	local ++i
}

*Exporting results 
esttab r1 r2 r3 r4 r5 r6 r7 r8 r9 using "${tables}/rdd_main_all_ineq_nl_v4.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & HH Total & Labor PC & Non-Labor & Remittances & Agr. & Main Job & Self- & Main Occ. & Hourly \\"' ///
			`" & Income & Income & PC Income & Income & Income & Labor & Employed & Income & Income \\"' ///
			`" & (75/25) & (75/25) & (75/25) & (75/25) & (75/25) & (75/25) & (75/25) & (75/25) & (75/25) \\"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 
		
		
		

*END
