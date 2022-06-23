/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
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

*Labels for outcomes
la var isic1_agr "Agriculture"
la var isic1_ind "Industry"
la var isic1_serv "Services"
la var isic2_agr "Agriculture"
la var isic2_cons "Construction" 
la var isic2_man "Manufacture"
la var isic2_mserv "Market services"
la var isic2_min "Mining and energy"
la var isic2_nmserv "Non-market services"
la var agr_azcf "Grow cereals and fruits"  // cereals and fruits
la var agr_azcf_v2 "Grow food (v2)"
la var man_azcf "Manufacture food"
la var man_azcf_v2 "Manufacture food (v2)"
la var serv_azcf "Selling agro product"
la var serv_azcf_v2 "Selling agro (v2)"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl isic1 "isic1_agr isic1_ind isic1_serv"
gl isic2 "isic2_agr isic2_cons isic2_man isic2_mserv isic2_min isic2_nmserv"
gl isic3 "agr_azcf agr_azcf_v2 man_azcf man_azcf_v2 serv_azcf serv_azcf_v2"

*Erasing table before exporting
cap erase "${tables}\rdd_isic_all_p1.tex"
cap erase "${tables}\rdd_isic_all_p1.txt"
cap erase "${tables}\rdd_isic_all_p2.tex"
cap erase "${tables}\rdd_isic_all_p2.txt"
cap erase "${tables}\rdd_isic_all_p3.tex"
cap erase "${tables}\rdd_isic_all_p3.txt"

foreach var of global isic1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_isic_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global isic2{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_isic_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global isic3{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_isic_all_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}




*END