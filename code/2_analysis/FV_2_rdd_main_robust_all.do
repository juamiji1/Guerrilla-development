/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Creating vars
gen z_sqr=z_run_cntrl^2

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

*Global of border FE for all specifications
gl breakfe="control_break_fe_400"
gl controlsp0 "within_control"
gl controlsp1 "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controlsp2 "within_control i.within_control#c.z_run_cntrl z_run_cntrl i.within_control#c.z_sqr z_sqr"

gl bwmethod "mserd msetwo cerrd certwo"
gl weights "triangular uniform epanechnikov"

*Global of outcomes
gl mainoutcomes "arcsine_nl13 z_wi mean_educ_years"

*Erasing table before exporting
foreach var of global mainoutcomes{
	
	*Erasing table before exporting
	cap erase "${tables}\rdd_`var'_mainrobust_all_p0.tex"
	cap erase "${tables}\rdd_`var'_mainrobust_all_p0.txt"
	cap erase "${tables}\rdd_`var'_mainrobust_all_p1.tex"
	cap erase "${tables}\rdd_`var'_mainrobust_all_p1.txt"
	cap erase "${tables}\rdd_`var'_mainrobust_all_p2.tex"
	cap erase "${tables}\rdd_`var'_mainrobust_all_p2.txt"

	*Looping over bw method and kernel weights
	forval p=0/2 {
		foreach m of global bwmethod {
			foreach w of global weights {
				
				*RDD with break fe and triangular weights 
				rdrobust `var' z_run_cntrl, all kernel(`w') bwselect(`m') p(`p')
				gl h=e(h_l)
				
				*Conditional for all specifications
				gl if "if abs(z_run_cntrl)<=${h}"
				
				if "`w'"=="triangular"{
					*Replicating triangular weights
					cap drop tweights
					gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
				}
				else if "`w'"=="uniform"{
					*Replicating uniform weights
					cap drop tweights
					gen tweights=0.5 ${if}
				}
				else {
					*Replicating epanechnikov weights
					cap drop tweights
					gen tweights=3/4*(1-(z_run_cntrl/${h})^2) ${if}
				}
				
				*Estimation 
				reghdfe `var' ${controlsp`p'} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
				summ `var' if e(sample)==1 & within_control==0, d
				gl mean_y=round(r(mean), .01)
				
				outreg2 using "${tables}\rdd_`var'_mainrobust_all_p`p'.tex", tex(frag) keep(within_control) addtext("Bw type","`m'", "Kernel", "`w'") addstat("Bandwidth (Km)", ${h},"Polynomial", `p', "Dependent mean", ${mean_y}) label nonote nocons append
				
			}
		}
	}
}



*END