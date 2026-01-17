/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Data on comisarias 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*-------------------------------------------------------------------------------
* 			   Presence of police station outcomes 
*
*-------------------------------------------------------------------------------

use "/Users/bj6385/Downloads/entries_1990_2000_with_segment.dta", clear
 gen counter=1 
 replace counter=. if sipe==""

  
keep if yearsp>=1992 & yearsp<=1999 // HASTA 1999

 
 collapse (rawsum) counter, by (seg_id)
 rename (seg_id counter) (segm_id entries)
 
 tempfile Entries
 save `Entries', replace
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear
cap drop _merge
merge 1:1 segm_id using `Entries', keep(1 3)
 replace entries=0 if entries==.
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

local r replace
foreach var in dist_comisaria entries {
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/rdd_policeandenforcement_all_draft.tex", tex(frag) keep(within_control) dec(3) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) nonote nocons `r'
	local r append
	
}

preserve 
 insheet using "${tables}/rdd_policeandenforcement_all_draft.txt", nonames clear
 
drop in 2
insobs 2, before(1)
replace v2 = "Distance to " in 1
replace v2 = "Police Stations" in 2
replace v3 = "Incarcerations" in 1
replace v3 = "(1992-1999)" in 2
replace v1 = "Guerrilla control" in 5

dataout, tex save("${tables}/rdd_policeandenforcement_all_draft") replace nohead midborder(3)

restore 




*END
