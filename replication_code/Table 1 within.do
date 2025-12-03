/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing/placebo
DATE: 
AUTHORS: 
RA: JMJR

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*-------------------------------------------------------------------------------
* Preparing data
*-------------------------------------------------------------------------------
import delimited "${data}\gis\maps_interim\segm_info_dists.csv", clear
ren seg_id segm_id

keep segm_id dist_school dist_cities dist_road dist_comms

destring dist_school, replace force 

foreach var in dist_school dist_cities dist_road dist_comms{
	replace `var'=`var'/1000
}

ren (dist_school dist_cities dist_road dist_comms) (dist_school_cond dist_cities_cond dist_road_cond dist_comms_cond)

tostring segm_id, replace
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile DISTS
save `DISTS', replace 

use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear 

merge 1:1 segm_id using `DISTS', nogen 

la var dist_school_cond "Distance to School (1980)"
la var dist_cities_cond "Distance to City or Village (1945)"
la var dist_road_cond "Distance to Roads and Railway (1980)"
la var dist_comms_cond "Distance to Telecommunications (1945)"

*-------------------------------------------------------------------------------
* Seeting BW and weights
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=2.266
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Results
*-------------------------------------------------------------------------------
gl lc1 "dist_cities_cond dist_road_cond dist_comms_cond"

mat drop _all

mat HA=J(1,4,.)
mat rown HA="Panel A"
local num1 : list sizeof global(lc1)
mat A1=J(`num1',4,1)

local r=1
mat rown A`r' = ${lc`r'}

local i=1
foreach var of global lc`r'{
	
	*Table 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 

	mat R=r(table)

	mat A`r'[`i',1]=round(R[1,1], .001)
	mat A`r'[`i',2]=round(R[2,1], .001) 
	mat A`r'[`i',4]=e(N)
	summ `var' if e(sample)==1 & within_control==0, d
	mat A`r'[`i',3]=round(r(mean), .001)

	local++i
}

mat S=HA\A1
mat list S

local bc = rowsof(S)
matrix stars = J(`bc',2,0)

forvalues k = 1/`bc' {
	if S[`k',1]!=. {
		matrix stars[`k',1] = (abs(S[`k',1]/S[`k',2]) > invttail(`e(df_r)',0.1/2)) + (abs(S[`k',1]/S[`k',2]) > invttail(`e(df_r)',0.05/2)) + (abs(S[`k',1]/S[`k',2]) > invttail(`e(df_r)',0.01/2))
	}
}

matrix list stars

tempfile X X1 X2
frmttable using `X', statmat(S) ctitle("Variable (Year)", "Coefficient","SE", "Dependent Mean", "Obs") sdec(3,3,3,0) varlabels fragment tex nocenter annotate(stars) asymbol(*,**,***) hlines(1 1 1 0 0 1 1) replace  	
filefilter `X' `X1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `X1' `X2', from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace
filefilter `X2' "${tables}/rdd_lc_all_r3comment.tex", from("Panel A") to("\BStextit{Panel A:Baseline State Capacity (Before 1980)}") replace






