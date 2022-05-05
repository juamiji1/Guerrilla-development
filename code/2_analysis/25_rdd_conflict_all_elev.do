/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 							Spatial RDD 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"

*Creating the sample for robustness
gen sampler=1 if within_fmln==0
replace sampler=1 if within_control==1 & sampler==.

gen sampled=1 if (z_run_cntrl<-.08 | z_run_cntrl>.08)

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted Level"
la var z_wi "Wealth Score (2007)"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"


*-------------------------------------------------------------------------------
* Robustness ex - Without disputed segments 
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"

*Erasing table before exporting new one
cap erase "${tables}\rdd_conflict_all_elev_p1.tex"
cap erase "${tables}\rdd_conflict_all_elev_p1.txt"

*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl if sampler==1, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)
gl h=2.266

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & sampler==1"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_conflict_all_elev_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}


*-------------------------------------------------------------------------------
* Robustness ex - Donut hole technique 
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* 						outcomes (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting new one
cap erase "${tables}\rdd_conflict_all_elev_p2.tex"
cap erase "${tables}\rdd_conflict_all_elev_p2.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if sampled==1, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)
gl h=1.016

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & sampled==1"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}


foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_conflict_all_elev_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}


*-------------------------------------------------------------------------------
* Homicides rates
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* 						outcomes (Table)
*-------------------------------------------------------------------------------
gl klls "homicidios homicidios_gang"

*Erasing table before exporting new one
cap erase "${tables}\rdd_homicide_all_elev.tex"
cap erase "${tables}\rdd_homicide_all_elev.txt"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

foreach var of global klls{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_homicide_all_elev.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}


*-------------------------------------------------------------------------------
* WITHOUT CONTROLLED ZONES IN 1982 			
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"

gen sample=1 if within_control==1
replace sample=0 if within_control==0 & within_control82==0

*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl if sample!=., all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & sample!=."

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
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
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"
*Out: z_wi_iqr z_wi_iqr2 z_wi_iqr3 z_wi_p50 

*Erasing table before exporting
cap erase "${tables}\rdd_conflict_all_elev_noc82.tex"
cap erase "${tables}\rdd_conflict_all_elev_noc82.txt"

foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_conflict_all_elev_noc82.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}


*-------------------------------------------------------------------------------
* DONUT HOLE WITH CENTROID
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"

*Creating the sample for robustness
gen sampled=1 if (z_run_cntrl_v2<-.4 | z_run_cntrl_v2>.4)

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted Level"
la var z_wi "Wealth Score (2007)"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"

*-------------------------------------------------------------------------------
* Robustness ex - Donut hole technique 
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* 						outcomes (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting new one
cap erase "${tables}\rdd_conflict_all_elev_centroid_p2.tex"
cap erase "${tables}\rdd_conflict_all_elev_centroid_p2.txt"

*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl if sampled==1, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & sampled==1"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}


foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_conflict_all_elev_centroid_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}


*-------------------------------------------------------------------------------
* USING 1982 BOUNDARIES 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_82_nowater.dta", clear

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

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
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
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"
*Out: z_wi_iqr z_wi_iqr2 z_wi_iqr3 z_wi_p50 

*Erasing table before exporting
cap erase "${tables}\rdd_main_all_82.tex"
cap erase "${tables}\rdd_main_all_82.txt"

foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_all_82.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}



*-------------------------------------------------------------------------------
* DIFFERENTIATTNG BY TYPE OF ZONES		
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control within_disputa i.within_disputa#c.z_run_cntrl i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"

gen within_disputa=(within_fmln==1 & within_control==0)

*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
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
la var within_disputa "Disputed area"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"
*Out: z_wi_iqr z_wi_iqr2 z_wi_iqr3 z_wi_p50 

*Erasing table before exporting
cap erase "${tables}\rdd_conflict_all_elev_disp.tex"
cap erase "${tables}\rdd_conflict_all_elev_disp.txt"

foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_conflict_all_elev_disp.tex", tex(frag) keep(within_control within_disputa) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}






*END