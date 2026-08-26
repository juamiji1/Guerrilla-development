/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Income inequality RD - pooled EHPM rounds (segment-year panel)
DATE:

NOTES: Alternative version of the income inequality tables in
       FV_2_rdd_ineq_nl_all.do using every EHPM round (2000-2017) instead of
       each segment's latest round only. Requires
       FV_1_prepare_ephm_segm_lvl_pooled.do to have been run first.
       Estimation: segment-year panel, survey-year FE added, SEs clustered at
       the census tract (segment) level. Bandwidth kept at 2.266 km for
       comparability with the cross-sectional tables.
------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* 						Preparing the data
*-------------------------------------------------------------------------------
use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear
keep segm_id within_control z_run_cntrl control_break_fe_400

merge 1:m segm_id using "${data}/temp\ephm_segm_year_lvl.dta", keep(3) nogen

*-------------------------------------------------------------------------------
* Setting vars
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"

*Same bandwidth as the cross-sectional inequality tables for comparability
gl h=2.266
gl ht=2.266

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Version 1: 90-10 dollar differences, pooled
*-------------------------------------------------------------------------------
gl ineqoutcomes "itf_m_ipr inlpc_m_ipr itranext_m_ipr iasalp_m_ipr ip_m_ipr wage_m_ipr"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(cluster segm_id) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_a`i'=string(r(mean), "%9.2f")
	gl tr_a`i'=string(e(N_clust), "%9.0f")

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_main_all_ineq_nl_v2_pooled.tex", keep(within_control) ///
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
		`" Census tracts & ${tr_a1} & ${tr_a2} & ${tr_a3} & ${tr_a4} & ${tr_a5} & ${tr_a6} \\"' ///
		`" Dependent mean & ${mean_a1} & ${mean_a2} & ${mean_a3} & ${mean_a4} & ${mean_a5} & ${mean_a6} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* Version 2: 90/10 ratios, pooled
*-------------------------------------------------------------------------------
gl ineqoutcomes "itf_m_rat9010 inlpc_m_rat9010 itranext_m_rat9010 iasalp_m_rat9010 ip_m_rat9010 wage_m_rat9010"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(cluster segm_id) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_b`i'=string(r(mean), "%9.2f")
	gl tr_b`i'=string(e(N_clust), "%9.0f")

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_main_all_ineq_nl_rat9010_pooled.tex", keep(within_control) ///
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
		`" Census tracts & ${tr_b1} & ${tr_b2} & ${tr_b3} & ${tr_b4} & ${tr_b5} & ${tr_b6} \\"' ///
		`" Dependent mean & ${mean_b1} & ${mean_b2} & ${mean_b3} & ${mean_b4} & ${mean_b5} & ${mean_b6} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* Version 3: 90-10 differences after winsorizing at within-year p1/p99, pooled
*-------------------------------------------------------------------------------
gl ineqoutcomes "itf_m_iprw inlpc_m_iprw itranext_m_iprw iasalp_m_iprw ip_m_iprw wage_m_iprw"
eststo clear

local i=1
foreach yvar of global ineqoutcomes {

	*Base Estimation
	eststo r`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(cluster segm_id) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_c`i'=string(r(mean), "%9.2f")
	gl tr_c`i'=string(e(N_clust), "%9.0f")

	local ++i
}

*Exporting results
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_main_all_ineq_nl_wins_pooled.tex", keep(within_control) ///
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
		`" Census tracts & ${tr_c1} & ${tr_c2} & ${tr_c3} & ${tr_c4} & ${tr_c5} & ${tr_c6} \\"' ///
		`" Dependent mean & ${mean_c1} & ${mean_c2} & ${mean_c3} & ${mean_c4} & ${mean_c5} & ${mean_c6} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')

*END
