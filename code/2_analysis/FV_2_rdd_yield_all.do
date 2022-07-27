/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Results for agricultural productivity (FAO data)
DATE: 
AUTHORS: 
RA: JMJR

NOTES: 
------------------------------------------------------------------------------*/

*Census segment level data 
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

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
summ bean05 maize05 coffe05 sugar05
summ h_bean05 h_maize05 h_coffee05 h_sugar05

gl yld "bean05 maize05 coffe05 sugar05"
gl is "h_bean05 h_maize05 h_coffee05 h_sugar05"
gl prod "prod_bean05 prod_maize05 prod_coffee05 prod_sugar05"

foreach var of global yld{
	egen p = pctile(`var'), p(2)
	*summ `var', d
	gen p`var'=(`var'>p)
	*replace `var'=. if `var'<=p
	drop p
}

foreach var of global yld{
	replace `var'=. if `var'==0
}

foreach var of global is{
	summ `var', d
	*gen p`var'=(`var'> 0)
	*gen p`var'=(`var'>  `r(p5)')
	
	egen p = pctile(`var'), p(2)
	gen p`var'=(`var'>p)
	drop p
	
}

foreach var of global prod{
	gen d`var'=(`var'>0)

	egen p = pctile(`var'), p(2)
	gen p2`var'=(`var'>p)
	drop p
}

*Area from Km2 to Has 
gen segm_area=AREA_K*100 

foreach var of global is{
	gen s`var'=`var'/segm_area
}

*-------------------------------------------------------------------------------
* Local continuity using Percentile 25 and up of elevation (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl yld "bean05 maize05 coffe05 sugar05"
gl is "h_bean05 h_maize05 h_coffee05 h_sugar05"
gl prs "ph_bean05 ph_maize05 ph_coffee05 ph_sugar05"
gl pyld "pbean05 pmaize05 pcoffe05 psugar05"
gl sh "sh_bean05 sh_maize05 sh_coffee05 sh_sugar05"
gl coop "dist_coop total_coop"
gl pd "prod_bean05 prod_maize05 prod_coffee05 prod_sugar05"

*Erasing files 
cap erase "${tables}\rdd_yld_all_p1.tex"
cap erase "${tables}\rdd_yld_all_p1.txt"
cap erase "${tables}\rdd_yld_all_p2.tex"
cap erase "${tables}\rdd_yld_all_p2.txt"
cap erase "${tables}\rdd_yld_all_p3.tex"
cap erase "${tables}\rdd_yld_all_p3.txt"
cap erase "${tables}\rdd_yld_all_p4.tex"
cap erase "${tables}\rdd_yld_all_p4.txt"
cap erase "${tables}\rdd_yld_all_p5.tex"
cap erase "${tables}\rdd_yld_all_p5.txt"
cap erase "${tables}\rdd_yld_all_p6.tex"
cap erase "${tables}\rdd_yld_all_p6.txt"
cap erase "${tables}\rdd_yld_all_p7.tex"
cap erase "${tables}\rdd_yld_all_p7.txt"


foreach var of global yld{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global is{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y})  nonote nocons append 
}

summ bean05 coffe05 cottn05 maize05 rice05 sugar05, d

foreach var of global coop{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y})  nonote nocons append 
}

foreach var of global prs{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p4.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y})  nonote nocons append 
}

foreach var of global sh{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p5.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y})  nonote nocons append 
}

foreach var of global pyld{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p6.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y})  nonote nocons append 
}

foreach var of global pd{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p7.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y})  nonote nocons append 
}





foreach var of global yld {
	
	*RDD with break fe and triangular weights 
	rdrobust `var' z_run_cntrl, all kernel(triangular)
	gl h=e(h_l)
	gl b=e(b_l)

	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h}"
	
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_yld_all_p7_diffbw.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

gl resid "bean05_r maize05_r coffe05_r sugar05_r"

*Against the distance
foreach var of global yld {
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
}

preserve

	gen x=round(z_run_cntrl, 0.05)
	gen n=1
	
	collapse (mean) ${resid} (sum) n, by(x)

	foreach var of global resid{
		two (scatter `var' x if abs(x)<1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var' x [aweight = n] if x<0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var' x [aweight = n] if x>=0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") name(`var', replace)
		gr export "${plots}\rdplot_all_`var'.pdf", as(pdf) replace 

				
	}
	
restore







*END

