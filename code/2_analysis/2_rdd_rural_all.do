
/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring possible mechanisms
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*Creating vars
encode AREA_I, gen(rural)
recode rural (2=0)

gen dens_pop=total_pop/AREA_K
gen dens_pop_bornbef85=pop_bornbef85_always/AREA_K
gen dens_pop_bornbef80=pop_bornbef80_always/AREA_K

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
* 				Mechanisms related to household conditions
*-------------------------------------------------------------------------------
gl outcomes "rural total_pop dens_pop pop_bornbef85_always dens_pop_bornbef85 pop_bornbef80_always dens_pop_bornbef80"

la var rural "Rural"
la var total_pop "Population"
la var dens_pop "Population Density"
la var pop_bornbef85_always "Population before 1985"
la var dens_pop_bornbef85 "Population before 1985 density"
la var pop_bornbef80_always "Population before 1980"
la var dens_pop_bornbef80 "Population before 1980 density"

*Erasing files 
cap erase "${tables}\rdd_rural_all.tex"
cap erase "${tables}\rdd_rural_all.txt"

*Tables
foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_rural_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* Plots
*-------------------------------------------------------------------------------
gl resid "rural_r total_pop_r dens_pop_r pop_bornbef85_always_r dens_pop_bornbef85_r pop_bornbef80_always_r dens_pop_bornbef80_r"

*Against the distance
foreach var of global outcomes{
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
}

preserve

	gen x=round(z_run_cntrl, 0.08)
	gen n=1
	
	collapse (mean) ${resid} (sum) n, by(x)

	foreach var of global resid{
		two (scatter `var' x if abs(x)<1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var' x [aweight = n] if x<0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var' x [aweight = n] if x>=0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), xlabel(-1(0.2)1) legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") name(`var', replace)
		gr export "${plots}\rdplot_all_`var'.pdf", as(pdf) replace 

				
	}
	
restore








*END
