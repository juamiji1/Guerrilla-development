
/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Preparing night light dat at the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 					Preparing Conflict data
*
*-------------------------------------------------------------------------------
use "${data}\conflict\conflict.dta", clear

ren _all, low
ren codigo canton_id

tempfile C
save `C', replace


*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/gis\maps_interim\slvShp_cantons_info_sp", data("${data}/temp\slvShp_cantons_info.dta") coord("${data}/temp\slvShp_cantons_info_coord.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_cantons_info.dta", clear

ren (nl elev2 wmen_nl dst_cnt dst_dsp wthn_cn wthn_ds cn_1000 cnt1000 cnt_400 cntr400) (nl13_density elevation wmean_nl1 dist_control dist_disputed within_control within_disputed dist_control_breaks_1000 control_break_fe_1000 dist_control_breaks_400 control_break_fe_400)

*Canton ID
gen canton_id=COD_DEP+COD_MUN+COD_CAN
destring canton_id, replace 

*To kms
replace dist_control=dist_control/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))


*-------------------------------------------------------------------------------
* 					Merging the conflict data 
*
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 canton_id using `C', keep(1 3)


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
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

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_main_canton.tex"
cap erase "${tables}\rdd_main_canton.txt"
cap erase "${tables}\rdd_main_conflict_canton_p1.tex"
cap erase "${tables}\rdd_main_conflict_canton_p1.txt"
cap erase "${tables}\rdd_main_conflict_canton_p2.tex"
cap erase "${tables}\rdd_main_conflict_canton_p2.txt"
cap erase "${tables}\rdd_main_conflict_canton.tex"
cap erase "${tables}\rdd_main_conflict_canton.txt"

*Global of outcomes
gl outcomes1 "arcsine_nl13 ln_nl13 nl13_density wmean_nl1"
gl outcomes2 "homicidio desaparic lesiones tortura violacion" 
* Out: conflict secuestro
gl outcomes3 "escuad ffaa fnlm reform landshare_expropriated"
gl outcomes "homicidio desaparic lesiones secuestro tortura violacion"

foreach var of global outcomes1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_canton.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global outcomes2{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_conflict_canton_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global outcomes3{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_conflict_canton_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_conflict_canton.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}





*END
