/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Investement projects in el salvador at the canton lvl 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* Preparing the data 
* 
*-------------------------------------------------------------------------------
*Preparing the canton ID
import excel "${data}/fisdl/match_cantones.xlsx", sheet("Sheet1") firstrow clear

tostring dep mun can, replace
replace dep="0"+dep if length(dep)==1
replace mun="0"+mun if length(mun)==1
replace can="0"+can if length(can)==1

gen canton_id=dep+mun+can

duplicates drop canton_id code, force

keep code name departamento municipio canton_id

tempfile CantonId
save `CantonId', replace

*Importing the FISDL info
import excel "${data}/fisdl/proyectos_fisdl.xlsx", sheet("Hoja1") firstrow clear

ren _all, low
ren (codigodeporyecto nombredelproyecto) (code name)
destring code, replace 

merge m:1 departamento code using `CantonId', nogen

*Fixing vars
gen n=1 
gen educ=1 if strpos(tipologia, "EDUCACION")>0
gen water=1 if strpos(tipologia, "AGUA")>0 | strpos(tipologia, "SANITARIO")>0 | strpos(tipologia, "LETRINIZACION")>0  
gen electricity=1 if strpos(tipologia, "ELECTRIFICACION")>0
gen roads=1 if strpos(tipologia, "CAMINOS")>0 | strpos(tipologia, "CALLE")>0 | strpos(tipologia, "PUENTE")>0

collapse (mean) montoaprobado aportefisdl (sum) n educ water electricity roads , by(canton_id)

destring canton_id, replace

tempfile FISDL
save `FISDL', replace

*Loading the shapefile's info  
use "${data}/temp/slvShp_cantons_info.dta", clear

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
* 					Merging the FISDL data 
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 canton_id using `FISDL', keep(1 3)

*Fixing vars
replace n=0 if n==.
replace educ=0 if educ==.
replace water=0 if water==.
replace electricity=0 if electricity==.
replace roads=0 if roads==.

gen fisdl_all=(n>0)
gen fisdl_educ=(educ>0)
gen fisdl_water=(water>0)
gen fisdl_electricity=(electricity>0)
gen fisdl_roads=(roads>0)


*-------------------------------------------------------------------------------
* 				   Preparing the set-up
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



*-------------------------------------------------------------------------------
* 				       FISDL results (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting


gl outcomes "fisdl_all"


foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_public_all_draft_panel.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons replace 
}


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
use "${data}/comercios_google/slv_places_clean.dta", clear

ren SEG_ID segm_id

*Keeping most probable public buildings 
gen yes=1 if strpos(type, "local_government_office") | strpos(type, "city_hall") | strpos(type, "school") | strpos(type, "courthouse") | strpos(type, "embassy") | strpos(type, "fire_station") | strpos(type, "hospital") | strpos(type, "museum") | strpos(type, "police") | strpos(type, "post_office") | strpos(type, "secondary_school") | strpos(type, "transit_station") | strpos(type, "bus_station") 

gen n_pbuilding=1

*Collpase by segment ID 
collapse (sum) n_pbuilding, by(segm_id)

gen pbuilding=(n_pbuilding>0) if n_pbuilding!=.

*Fixing the segment id 
tostring segm_id, replace 
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile Public 
save `Public', replace 

*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 
cap drop _merge 
merge 1:1 segm_id using `Public', keep(1 3)


*Other version the daily water
gen daily_water_sh_v2=daily_water_sh if pipes_sh==1



*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Creating vars per habitant
gen hosp_pop=total_hospitals*100000/total_pop
gen schl_pop=total_schools*100000/total_pop
*Creating vars per habitant
gen n_pbuilding_pop=n_pbuilding*100000/total_pop


*Labelling for tables 
la var total_household "Total Households"
la var owner_sh "Ownership Rate"
la var sanitary_sh "Sanitary Service Rate"
la var sewerage_sh  "Sewerage Service Rate"
la var pipes_sh "Water Access Rate"
la var daily_water_sh "Daily Water Rate"
la var electricity_sh "Electricity Rate"
la var garbage_sh "Garbage Rate"
la var total_hospitals "Total Hospitals"
la var total_schools "Total Schools"
la var road14 "Roads (2014)"
la var length_road14 "Roads (Kms)"
la var road14_dens "Road density (2014)"
la var public_pet "Public Workers"
la var dist_hosp "Distance to Hospital"
la var dist_schl "Distance to School"
la var hosp_pop "Hospitals per 100k Population"
la var schl_pop "Schools per 100k Population"
la var n_pbuilding_pop "Public Buildings per 100k Population" 

gl outcomes "schl_pop road14_dens hosp_pop n_pbuilding_pop"



foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_public_all_draft_panel.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons append 
}


preserve 
  insheet using "${tables}/rdd_public_all_draft_panel.txt", nonames clear
 drop v2
  
insobs 2, before(1)
replace v3 = "Public Investment" in 1
replace v3 = "(1995 - 2015)" in 2
replace v4 = "Schools per 100k " in 1
replace v4 = "Population (2007)" in 2
replace v5 = "Road Density" in 1
replace v5 = "(2014)" in 2
replace v6 = "Hospitals per 100k " in 1
replace v6 = "Population (2015)" in 2
replace v7 = "Public Buildings" in 1
replace v7 = "per 100k Population (2020)" in 2
drop in 4

dataout, tex save("${tables}/rdd_public_all_draft_panel") replace nohead midborder(3)
restore 





