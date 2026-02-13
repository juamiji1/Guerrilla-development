/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Food insecurity by year (EHPM data) - Precipitation effects
DATE:

NOTES: Year-level analysis for food_insec_all with precipitation 2016-2018
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Preparing the data 
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*EHPM 2016
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm16.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento r1101-r1115

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b r1101-r1115, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r204g if r204==1
replace educ_yrs=r204g+3 if r204==2 | r204==3
replace educ_yrs=r204g+14 if r204>=4
replace educ_yrs=r215a if r215b==1 & educ_yrs==.
replace educ_yrs=r215a+3 if (r215b==2 | r215b==3) & educ_yrs==.
replace educ_yrs=r215a+14 if r215b>=4 & educ_yrs==.

replace educ_yrs=0 if r201a==1 | r213==2 | educ_yrs==.

*Food insecurity vars
recode r1101-r1115 (2=0)
egen x=rowtotal(r1101-r1115), m
gen food_insec_all=(x>0) if x!=.

drop x

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2016

*Collapse by segment
collapse (mean) food_insec_all, by(segm_id year)

tempfile EHPM16
save `EHPM16', replace 

*-------------------------------------------------------------------------------
*EHPM 2017
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm17.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento r1101-r1115

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b r1101-r1115, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r204g if r204==1
replace educ_yrs=r204g+3 if r204==2 | r204==3
replace educ_yrs=r204g+14 if r204>=4
replace educ_yrs=r215a if r215b==1 & educ_yrs==.
replace educ_yrs=r215a+3 if (r215b==2 | r215b==3) & educ_yrs==.
replace educ_yrs=r215a+14 if r215b>=4 & educ_yrs==.

replace educ_yrs=0 if r201a==1 | r213==2 | educ_yrs==.

*Food insecurity vars
recode r1101-r1115 (2=0)
egen x=rowtotal(r1101-r1115), m
gen food_insec_all=(x>0) if x!=.

drop x

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2017

*Collapse by segment
collapse (mean) food_insec_all, by(segm_id year)

tempfile EHPM17
save `EHPM17', replace 

*-------------------------------------------------------------------------------
*EHPM 2018
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm18.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento r1101-r1115

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b r1101-r1115, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r204g if r204==1
replace educ_yrs=r204g+3 if r204==2 | r204==3
replace educ_yrs=r204g+14 if r204>=4
replace educ_yrs=r215a if r215b==1 & educ_yrs==.
replace educ_yrs=r215a+3 if (r215b==2 | r215b==3) & educ_yrs==.
replace educ_yrs=r215a+14 if r215b>=4 & educ_yrs==.

replace educ_yrs=0 if r201a==1 | r213==2 | educ_yrs==.

*Food insecurity vars
recode r1101-r1115 (2=0)
egen x=rowtotal(r1101-r1115), m
gen food_insec_all=(x>0) if x!=.

drop x

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2018

*Collapse by segment
collapse (mean) food_insec_all, by(segm_id year)

tempfile EHPM18
save `EHPM18', replace

*-------------------------------------------------------------------------------
*Appending all data sets
*-------------------------------------------------------------------------------
use `EHPM16', clear 
append using `EHPM17' `EHPM18'

tempfile FOODSEC_PANEL
save `FOODSEC_PANEL', replace

*-------------------------------------------------------------------------------
* Fixing shocks - Year level
*-------------------------------------------------------------------------------
use "${data}/shocks\monthly_Panel_SLV_Segments_1980_2025.dta", clear
keep if year>=2016 & year<=2018

gen d_zprecip_1sd=(abs(precip_std)>=1) if precip_std!=.
gen d_zprecip_2sd=(abs(precip_std)>=2) if precip_std!=.

replace precip_std=abs(precip_std)

collapse (sum) d_z* (mean) hist_precip_mean_all hist_precip_sd_all predict_chirps_precip precip_std, by(seg_id year)

gen zprecip=(predict_chirps_precip-hist_precip_mean_all)/hist_precip_sd_all

tostring seg_id, g(segm_id)
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile SHOCKS_PANEL
save `SHOCKS_PANEL', replace


*-------------------------------------------------------------------------------
* RDD results by year
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Merging data - creating panel structure
expand 3
bysort segm_id: gen year=2015+_n

*Merging food security and shocks by year
merge 1:1 segm_id year using `FOODSEC_PANEL', keep(1 3) nogen
merge 1:1 segm_id year using `SHOCKS_PANEL', keep(1 3) nogen

*Creating interactions
gen d_mean_zprecip_1sd=(abs(precip_std)>=1) if precip_std!=.
gen d_mean_zprecip_2sd=(abs(precip_std)>=1.5) if precip_std!=.

gen wc_zprecip =within_control*precip_std
gen wc_dzprecip1sd =within_control*d_zprecip_1sd
gen wc_dzprecip2sd =within_control*d_zprecip_2sd
gen wc_dmzprecip1sd =within_control*d_mean_zprecip_1sd
gen wc_dmzprecip2sd =within_control*d_mean_zprecip_2sd

summ precip_std, d
gen d_highprecip=(precip_std>=`r(p50)')

summ d_zprecip_1sd, d
gen d_highprecip1sd=(d_zprecip_1sd>=`r(p50)')
summ d_zprecip_2sd, d
gen d_highprecip2sd=(d_zprecip_2sd>=`r(p50)')

gen wc_highprecip=within_control*d_highprecip
gen wc_highprecip1sd=within_control*d_highprecip1sd
gen wc_highprecip2sd=within_control*d_highprecip2sd

*Variable labels 
label var within_control "Guerrilla control"
label var wc_zprecip "Control $\times$ Precipitation (Z-score)"
label var wc_dmzprecip1sd "Control $\times$ $\lvert Z\text{-Precip} \rvert \geq 1$ SD"
label var wc_dmzprecip2sd "Control $\times$ $\lvert Z\text{-Precip} \rvert \geq 2$ SD"
label var wc_dzprecip1sd "Control $\times$ Months with $\lvert Z\text{-Precip} \rvert \geq 1$ SD"
label var wc_dzprecip2sd "Control $\times$ Months with $\lvert Z\text{-Precip} \rvert \geq 2$ SD"
label var wc_highprecip "Control $\times$ High Precip (Above Median)"
label var wc_highprecip1sd "Control $\times \mathbb{I}$\{Months with High Precip (1SD) $\geq$ p50\}"
label var wc_highprecip2sd "Control $\times$ High Months Precip Shock (2SD)"

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=2.266
gl ht=${h}

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Year-by-year analysis
*-------------------------------------------------------------------------------

foreach y in 2016 2017 2018 {
	
	di "************* YEAR `y' *************"
	
	local i=1
	
	*Base Estimation
	reghdfe food_insec_all ${controls} wc_zprecip precip_std [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_zprecip
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_dmzprecip1sd d_mean_zprecip_1sd [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmzprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_dmzprecip2sd d_mean_zprecip_2sd [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmzprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_dzprecip1sd d_zprecip_1sd [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dzprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_dzprecip2sd d_zprecip_2sd [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dzprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_highprecip d_highprecip [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_highprecip1sd d_highprecip1sd [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
	
	reghdfe food_insec_all ${controls} wc_highprecip2sd d_highprecip2sd [aw=tweights] ${if} & year==`y', vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo  a`y'_`i'
	local ++i
}

*-------------------------------------------------------------------------------
* Exporting results by year
*-------------------------------------------------------------------------------

*Table 1: Precipitation effects on food_insec_all - 2016
esttab a2016_1 a2016_4 a2016_7 using "${tables}/rdd_foodsec_all_precip_2016.tex", ///
	keep(within_control wc_zprecip wc_dzprecip1sd wc_highprecip1sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & \multicolumn{3}{c}{Food Insecurity (All) - 2016}\\"' ///
            `"\ & (1) & (2) & (3) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 2: Precipitation effects on food_insec_all - 2017
esttab a2017_1 a2017_4 a2017_7 using "${tables}/rdd_foodsec_all_precip_2017.tex", ///
	keep(within_control wc_zprecip wc_dzprecip1sd wc_highprecip1sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & \multicolumn{3}{c}{Food Insecurity (All) - 2017}\\"' ///
            `"\ & (1) & (2) & (3) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
             `"\bottomrule \end{tabular}"')

*Table 3: Precipitation effects on food_insec_all - 2018
esttab a2018_1 a2018_4 a2018_7 using "${tables}/rdd_foodsec_all_precip_2018.tex", ///
	keep(within_control wc_zprecip wc_dzprecip1sd wc_highprecip1sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & \multicolumn{3}{c}{Food Insecurity (All) - 2018}\\"' ///
            `"\ & (1) & (2) & (3) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
             `"\bottomrule \end{tabular}"')

*Base Estimation
est clear 

reghdfe food_insec_all ${controls} wc_zprecip precip_std [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_zprecip
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_1

reghdfe food_insec_all ${controls} wc_dmzprecip1sd d_mean_zprecip_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_dmzprecip1sd
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_2

reghdfe food_insec_all ${controls} wc_dmzprecip2sd d_mean_zprecip_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_dmzprecip2sd
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_3

reghdfe food_insec_all ${controls} wc_dzprecip1sd d_zprecip_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_dzprecip1sd
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_4

reghdfe food_insec_all ${controls} wc_dzprecip2sd d_zprecip_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_dzprecip2sd
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_5

reghdfe food_insec_all ${controls} wc_highprecip d_highprecip [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_highprecip
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_6

reghdfe food_insec_all ${controls} wc_highprecip1sd d_highprecip1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_highprecip1sd
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_7

reghdfe food_insec_all ${controls} wc_highprecip2sd d_highprecip2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe} i.year) 
lincom within_control+ wc_highprecip2sd
estadd scalar L    = r(estimate)
estadd scalar L_p  = r(p)
eststo  a_8

*Table 4: Precipitation effects on food_insec_all - ALL YEARS POOLED
esttab a_1 a_4 a_7 using "${tables}/rdd_foodsec_all_precip_pooled.tex", ///
	keep(within_control wc_zprecip wc_dzprecip1sd wc_highprecip1sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & \multicolumn{3}{c}{Food Insecurity (All) - 2016 to 2018}\\"' ///
            `"\ & (1) & (2) & (3) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
             `"\bottomrule \end{tabular}"')

			 