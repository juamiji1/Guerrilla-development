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

*Exlcuding places that are not comercial establishment 
gen not=1 if strpos(type, "church") | strpos(type, "school") | strpos(type, "neighborhood") | strpos(type, "airport") | strpos(type, "local_government_office") | strpos(type, "art_gallery") | strpos(type, "park") | strpos(type, "cemetery") | strpos(type, "city_hall") | strpos(type, "courthouse") | strpos(type, "embassy") | strpos(type, "fire_station") | strpos(type, "funeral_home") | strpos(type, "hospital") | strpos(type, "museum") | strpos(type, "place_of_worship") | strpos(type, "police") | strpos(type, "post_office") | strpos(type, "secondary_school") | strpos(type, "transit_station") | strpos(type, "university") | strpos(type, "zoo") 

drop if not==1

gen n_establishment=1

*Collpase by segment ID 
collapse (sum) n_establishment, by(segm_id)

gen establishment=(n_establishment>0) if n_establishment!=.

*Fixing the segment id 
tostring segm_id, replace 
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile Comercial 
save `Comercial', replace 

*Merging the data together
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

drop _merge 
merge 1:1 segm_id using `Comercial', keep(1 3)

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
* Results for comercial establishments
*
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl comerce "n_establishment"

*Erasing table before exporting
cap erase "${tables}\rdd_cestablishments_all.tex"
cap erase "${tables}\rdd_cestablishments_all.txt"

foreach var of global comerce{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cestablishments_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}






*END