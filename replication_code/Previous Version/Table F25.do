/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes but interacting by baseline characteristics 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Preparing the data 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear


*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) 
*covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*creating important vars 
summ dist_coast ${if}, d
gen p50_dist_coast=(dist_coast>=`r(p50)') ${if}
gen wxdcst=within_control*p50_dist_coast ${if}

summ dist_city45 ${if}, d
gen p50_dist_city45=(dist_city45>=`r(p50)') ${if}
gen wxdcty=within_control*p50_dist_city45 ${if}

summ dist_road80 ${if}, d
gen p50_dist_road80=(dist_road80>=`r(p50)') ${if}
gen wxrd80=within_control*p50_dist_road80 ${if}

summ dist_road14 ${if}, d
gen p50_dist_road14=(dist_road14>=`r(p50)') ${if}
gen wxrd14=within_control*p50_dist_road14 ${if}

summ dist_capital ${if}, d
gen p50_dist_capital=(dist_capital>=`r(p50)') ${if}
gen wxdcptl=within_control*p50_dist_capital ${if}

gen dens_pop_bornbef80=pop_bornbef80_always/AREA_K
summ dens_pop_bornbef80 ${if}, d
gen p50_pop_dens_80=(dens_pop_bornbef80>=`r(p50)') ${if}
gen wxpopd=within_control*p50_pop_dens_80 ${if}

*Labels for outcomes
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var mean_educ_years "Years of Education (2007)"
la var z_wi "Wealth Index (2007)"



*-------------------------------------------------------------------------------
* 						Main outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13 z_wi mean_educ_years"


*Erasing table before exporting

local r replace
*Heterogeneous analysis results  
foreach var of global nl{
	
	*Table

	reghdfe `var' ${controls} i.within_control#c.dist_city45 dist_city45 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/rdd_het_all_elev_p3.tex", tex(frag) keep(within_control 1.within_control#c.dist_city45) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons nor2 `r'
		

	
	reghdfe `var' ${controls} i.within_control#c.dist_road80 dist_road80 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/rdd_het_all_elev_p7.tex", tex(frag) keep(within_control 1.within_control#c.dist_road80) noobs label nonote nocons nor2 `r'
	
		
		local r append 
}	


preserve 
 insheet using  "${tables}/rdd_het_all_elev_p3.txt", nonames clear
save "${tables}/rdd_het_all_elev_p3" , replace 
restore 


preserve 
 insheet using  "${tables}/rdd_het_all_elev_p7.txt", nonames clear
 append using "${tables}/rdd_het_all_elev_p3"
 
 
 
insobs 3, before(1)
drop v2 
drop in 5
replace v1 = "Panel A: Heterogeneity by Distance to Road Network in 1980" in 1
drop in 11/12
replace v1 = "Panel B: Heterogeneity by Distance to Nearest City in 1945" in 10
replace v1 = "Guerrilla control" in 6
replace v1 = "Control \$\times\$ Distance to Road" in 8
replace v1 = "Guerrilla control" in 12
replace v1 = "Control \$\times\$ Distance to City" in 14
replace v3 = "Night Light Luminosity" in 2
replace v3 = "(2013)" in 3
replace v4 = "Wealth Index" in 2
replace v4 = "(2007)" in 3
replace v5 = "Years of Education" in 2
replace v5 = "(2007)" in 3

local Pen=_N-1
gen n=_n 
replace n=90000 in `Pen'
sort n 
drop n

dataout, tex save("${tables}/rdd_het_all_draft") replace nohead midborder(4)
restore 

erase "${tables}/rdd_het_all_elev_p3.dta"
*END
