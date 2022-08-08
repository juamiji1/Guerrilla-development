/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Presence of commercial establishments 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* Preparing the google data 
*
*-------------------------------------------------------------------------------
use "${data}\comercios_google\slv_places_clean.dta", clear

ren SEG_ID segm_id

*Keeping most probable public buildings 
gen yes=1 if strpos(type, "local_government_office") | strpos(type, "city_hall") | strpos(type, "school") | strpos(type, "courthouse") | strpos(type, "embassy") | strpos(type, "fire_station") | strpos(type, "museum") | strpos(type, "police") | strpos(type, "post_office") | strpos(type, "secondary_school") | strpos(type, "transit_station") | strpos(type, "bus_station") 
*NOt hopsitals nor schools  (Does not change at all)

gen n_pbuilding=1

*Collpase by segment ID 
collapse (sum) n_pbuilding, by(segm_id)

gen pbuilding=(n_pbuilding>0) if n_pbuilding!=.

*Fixing the segment id 
tostring segm_id, replace 
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile Public 
save `Public', replace 

*-------------------------------------------------------------------------------
* Preparing the RDD set up 
*
*-------------------------------------------------------------------------------
*Merging the data together
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

drop _merge 
merge 1:1 segm_id using `Public', keep(1 3)

*Creating vars per habitant
gen n_pbuilding_pop=n_pbuilding*100000/total_pop

*Results 
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
* Results for public buildings 
*
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl comerce "n_pbuilding_pop"

*Erasing table before exporting
cap erase "${tables}\rdd_pbuildings_all.tex"
cap erase "${tables}\rdd_pbuildings_all.txt"

foreach var of global comerce{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_pbuildings_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}







*END