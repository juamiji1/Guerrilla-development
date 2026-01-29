
*-------------------------------------------------------------------------------
* Fixing shocks
*-------------------------------------------------------------------------------
use "${data}/shocks\monthly_Panel_SLV_Cantons_1980_2025.dta", clear
keep if year>1997 &  year<2003

gen d_ztemp_1sd=(abs(temp_std)>=1) if temp_std!=.
gen d_ztemp_2sd=(abs(temp_std)>=2) if temp_std!=.
gen d_zprecip_1sd=(abs(precip_std)>=1) if precip_std!=.
gen d_zprecip_2sd=(abs(precip_std)>=2) if precip_std!=.

replace temp_std=abs(temp_std)
replace precip_std=abs(precip_std)

collapse (sum) d_z* (mean) hist_temp_mean_all hist_temp_sd_all hist_precip_mean_all hist_precip_sd_all predict_modis_temp predict_chirps_precip temp_std precip_std, by(canton_id)

gen ztemp=(predict_modis_temp-hist_temp_mean_all)/hist_temp_sd_all
gen zprecip=(predict_chirps_precip-hist_precip_mean_all)/hist_precip_sd_all

tempfile SHOCKS
save `SHOCKS', replace

*-------------------------------------------------------------------------------
* Anthropometrics
*-------------------------------------------------------------------------------
use "${data}/shocks\slv_ensf_1998_stunting_wasting_children_0_5_canton.dta", clear
tostring dept muni cant, replace 

replace dept="0"+dept if length(dept)==1
replace muni="0"+muni if length(muni)==1
replace cant="0"+cant if length(cant)==1

gen canton_id=dept+muni+cant
destring canton_id, replace

tempfile ANTHRO98
save `ANTHRO98', replace 

use "${data}/shocks\slv_ensf_2002_stunting_wasting_children_0_5_canton.dta", clear
tostring dept muni cant, replace force

replace dept="0"+dept if length(dept)==1
replace muni="0"+muni if length(muni)==1
replace cant="0"+cant if length(cant)==1

gen canton_id=dept+muni+cant
destring canton_id, replace

append using `ANTHRO98'

collapse (mean) pct_stunt_cln pct_sev_stunt_cln pct_wasting_cln pct_sev_wasting_cln, by(canton_id)
 
tempfile ANTHRO
save `ANTHRO', replace 

*-------------------------------------------------------------------------------
* Results
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\census9207_canton_lvl.dta", clear 

*Canton ID
gen canton_id=COD_DEP+COD_MUN+COD_CAN
destring canton_id, replace 

*Merging with data 
merge 1:1 canton_id using `ANTHRO', keep(1 3) nogen
merge 1:1 canton_id using `SHOCKS', keep(1 3) nogen


*Creating interactions
gen d_mean_ztemp_1sd=(abs(temp_std)>=1) if temp_std!=.
gen d_mean_ztemp_2sd=(abs(temp_std)>=1.5) if temp_std!=.

gen d_mean_zprecip_1sd=(abs(precip_std)>=.5) if precip_std!=.
gen d_mean_zprecip_2sd=(abs(precip_std)>=1) if precip_std!=.

gen wc_ztemp =within_control*temp_std
gen wc_zprecip =within_control*precip_std
gen wc_dztemp1sd =within_control*d_ztemp_1sd
gen wc_dzprecip1sd =within_control*d_zprecip_1sd
gen wc_dztemp2sd =within_control*d_ztemp_2sd
gen wc_dzprecip2sd =within_control*d_zprecip_2sd

gen wc_dmztemp1sd =within_control*d_mean_ztemp_1sd
gen wc_dmzprecip1sd =within_control*d_mean_zprecip_1sd
gen wc_dmztemp2sd =within_control*d_mean_ztemp_2sd
gen wc_dmzprecip2sd =within_control*d_mean_zprecip_2sd

summ temp_std, d
gen d_hightemp=(temp_std>=`r(p50)')
summ precip_std, d
gen d_highprecip=(precip_std>=`r(p50)')

summ d_zprecip_1sd, d
gen d_highprecip1sd=(d_zprecip_1sd>=`r(p50)')
summ d_zprecip_2sd, d
gen d_highprecip2sd=(d_zprecip_2sd>=`r(p50)')

summ d_ztemp_1sd, d
gen d_hightemp1sd=(d_ztemp_1sd>=`r(p50)')
summ d_zprecip_2sd, d
gen d_hightemp2sd=(d_ztemp_2sd>=`r(p50)')

gen wc_highprecip=within_control*d_highprecip
gen wc_hightemp=within_control*d_hightemp
gen wc_highprecip1sd=within_control*d_highprecip1sd
gen wc_highprecip2sd=within_control*d_highprecip2sd
gen wc_hightemp1sd=within_control*d_hightemp1sd
gen wc_hightemp2sd=within_control*d_hightemp2sd

*Variable labels 
label var within_control "Control"
label var wc_ztemp "Control $\times$ Temperature (Z-score)"
label var wc_dmztemp1sd "Control $\times$ $\lvert Z\text{-Temp} \rvert \geq 1$ SD"
label var wc_dmztemp2sd "Control $\times$ $\lvert Z\text{-Temp} \rvert \geq 2$ SD"
label var wc_dztemp1sd "Control $\times$ Months with $\lvert Z\text{-Temp} \rvert \geq 1$ SD"
label var wc_dztemp2sd "Control $\times$ Months with $\lvert Z\text{-Temp} \rvert \geq 2$ SD"
label var wc_zprecip "Control $\times$ Precipitation (Z-score)"
label var wc_dmzprecip1sd "Control $\times$ $\lvert Z\text{-Precip} \rvert \geq 1$ SD"
label var wc_dmzprecip2sd "Control $\times$ $\lvert Z\text{-Precip} \rvert \geq 2$ SD"
label var wc_dzprecip1sd "Control $\times$ Months with $\lvert Z\text{-Precip} \rvert \geq 1$ SD"
label var wc_dzprecip2sd "Control $\times$ Months with $\lvert Z\text{-Precip} \rvert \geq 2$ SD"
label var wc_hightemp "Control $\times$ High Temp (Above Median)"
label var wc_highprecip "Control $\times$ High Precip (Above Median)"
label var wc_hightemp1sd "Control $\times$ High Months Temp Shock (1SD)"
label var wc_hightemp2sd "Control $\times$ High Months Temp Shock (2SD)"
label var wc_highprecip1sd "Control $\times$ High Months Precip Shock (1SD)"
label var wc_highprecip2sd "Control $\times$ High Months Precip Shock (2SD)"

END

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl92 z_run_cntrl, all kernel(triangular)
gl h=50
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Anthropometric outcomes 
gl anthro "pct_stunt_cln pct_sev_stunt_cln pct_wasting_cln pct_sev_wasting_cln"


local i=1
foreach yvar of global anthro {
	
	*Base Estimation
	reghdfe `yvar' ${controls} wc_ztemp temp_std [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_ztemp
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo a`i'
	
	reghdfe `yvar' ${controls} wc_dmztemp1sd d_mean_ztemp_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmztemp1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo b`i'
	
	reghdfe `yvar' ${controls} wc_dmztemp2sd d_mean_ztemp_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmztemp2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo c`i'
	
	reghdfe `yvar' ${controls} wc_dztemp1sd d_ztemp_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dztemp1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo d`i'
	
	reghdfe `yvar' ${controls} wc_dztemp2sd d_ztemp_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dztemp2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo e`i'
	
	
	reghdfe `yvar' ${controls} wc_zprecip precip_std [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_zprecip
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo f`i'
	
	reghdfe `yvar' ${controls} wc_dmzprecip1sd d_mean_zprecip_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmzprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo g`i'
	
	reghdfe `yvar' ${controls} wc_dmzprecip2sd d_mean_zprecip_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmzprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo h`i'
	
	reghdfe `yvar' ${controls} wc_dzprecip1sd d_zprecip_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dzprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo i`i'
	
	reghdfe `yvar' ${controls} wc_dzprecip2sd d_zprecip_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dzprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo j`i'
	
	reghdfe `yvar' ${controls} wc_hightemp d_hightemp [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_hightemp
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo k`i'
	
	reghdfe `yvar' ${controls} wc_hightemp1sd d_hightemp1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_hightemp1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo l`i'
	
	reghdfe `yvar' ${controls} wc_hightemp2sd d_hightemp2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_hightemp2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo m`i'
	
	reghdfe `yvar' ${controls} wc_highprecip d_highprecip [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo n`i'
	
	reghdfe `yvar' ${controls} wc_highprecip1sd d_highprecip1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo o`i'
	
	reghdfe `yvar' ${controls} wc_highprecip2sd d_highprecip2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo p`i'
	
	local ++i
}

*Exporting results 
*Table 1: Temperature effects on pct_stunt_cln
esttab a1 b1 c1 d1 e1 k1 l1 m1 using "${tables}/rdd_anthro_stunting_temp.tex", ///
    keep(within_control wc_ztemp wc_dmztemp1sd wc_dmztemp2sd wc_dztemp1sd wc_dztemp2sd wc_hightemp wc_hightemp1sd wc_hightemp2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 2: Temperature effects on pct_sev_stunt_cln
esttab a2 b2 c2 d2 e2 k2 l2 m2 using "${tables}/rdd_anthro_sevstunting_temp.tex", ///
    keep(within_control wc_ztemp wc_dmztemp1sd wc_dmztemp2sd wc_dztemp1sd wc_dztemp2sd wc_hightemp wc_hightemp1sd wc_hightemp2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 3: Temperature effects on pct_wasting_cln
esttab a3 b3 c3 d3 e3 k3 l3 m3 using "${tables}/rdd_anthro_wasting_temp.tex", ///
    keep(within_control wc_ztemp wc_dmztemp1sd wc_dmztemp2sd wc_dztemp1sd wc_dztemp2sd wc_hightemp wc_hightemp1sd wc_hightemp2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 4: Temperature effects on pct_sev_wasting_cln
esttab a4 b4 c4 d4 e4 k4 l4 m4 using "${tables}/rdd_anthro_sevwasting_temp.tex", ///
    keep(within_control wc_ztemp wc_dmztemp1sd wc_dmztemp2sd wc_dztemp1sd wc_dztemp2sd wc_hightemp wc_hightemp1sd wc_hightemp2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 5: Precipitation effects on pct_stunt_cln
esttab f1 g1 h1 i1 j1 n1 o1 p1 using "${tables}/rdd_anthro_stunting_precip.tex", ///
    keep(within_control wc_zprecip wc_dmzprecip1sd wc_dmzprecip2sd wc_dzprecip1sd wc_dzprecip2sd wc_highprecip wc_highprecip1sd wc_highprecip2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln & pct_stunt_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 6: Precipitation effects on pct_sev_stunt_cln
esttab f2 g2 h2 i2 j2 n2 o2 p2 using "${tables}/rdd_anthro_sevstunting_precip.tex", ///
    keep(within_control wc_zprecip wc_dmzprecip1sd wc_dmzprecip2sd wc_dzprecip1sd wc_dzprecip2sd wc_highprecip wc_highprecip1sd wc_highprecip2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln & pct_sev_stunt_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 7: Precipitation effects on pct_wasting_cln
esttab f3 g3 h3 i3 j3 n3 o3 p3 using "${tables}/rdd_anthro_wasting_precip.tex", ///
    keep(within_control wc_zprecip wc_dmzprecip1sd wc_dmzprecip2sd wc_dzprecip1sd wc_dzprecip2sd wc_highprecip wc_highprecip1sd wc_highprecip2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln & pct_wasting_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 8: Precipitation effects on pct_sev_wasting_cln
esttab f4 g4 h4 i4 j4 n4 o4 p4 using "${tables}/rdd_anthro_sevwasting_precip.tex", ///
    keep(within_control wc_zprecip wc_dmzprecip1sd wc_dmzprecip2sd wc_dzprecip1sd wc_dzprecip2sd wc_highprecip wc_highprecip1sd wc_highprecip2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{8}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln & pct_sev_wasting_cln\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} & ${h} \\"' ///
             `"\bottomrule \end{tabular}"')






