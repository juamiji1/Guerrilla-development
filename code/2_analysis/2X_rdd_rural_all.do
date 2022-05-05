
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





*END