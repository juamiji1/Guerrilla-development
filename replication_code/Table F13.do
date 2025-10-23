/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: 
------------------------------------------------------------------------------*/

use "${data}/incarcerations/entries_1980_1990_with_segment.dta", clear

 gen counter=1 
 replace counter=. if sipe==""
  
 keep if yearsp>=1980 & yearsp<1985
 collapse (rawsum) counter, by (seg_id)
 rename (seg_id counter) (segm_id entries)
 
 merge 1:1 segm_id using "$data/night_light_13_segm_lvl_onu_91_nowater", nogen

 replace entries=0 if entries==.

*Creating needed vars 
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

*Standardizing Suitability Index
foreach var in sibean sicoffee simaize sisugar {
	egen z_`var'=std(`var')
	gen m_`var'=(`var'>4000) if `var'!=.	
	gen g_`var'=(`var'>5500) if `var'!=.	
	gen h_`var'=(`var'>7000) if `var'!=.	
	gen vh_`var'=(`var'>8500) if `var'!=.	
}

*-------------------------------------------------------------------------------
* Local continuity (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc1 "elevation2 slope rugged hydrography rail_road d_city45 dist_city45" 
gl lc2 "dist_comms45 comms45_dens reform grown80_swithin d_parr80 dist_parr80 dist_schl80"
gl lc3 "pop_bornbef80_always dens_pop_bornbef80 mean_educ_years_wnsage sh_before_war_child sh_before_war_inmigrant sh_before_war_outmigrant high_pop80_swithin"
gl lc4 "z_crops bean79 coffee79 cotton79 maize79 rice79 sugarcane79"
gl lc5 "h_sibean h_sicoffee h_simaize h_sisugar"
gl lc6 "events victims entries"

*Labeling for tables 
la var elevation2 "Altitude"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway"
la var coffee79 "Coffe Yield"
la var cotton79 "Cotton Yield"
la var maize79 "Maize Yield"
la var rice79 "Wet Rice Yield"
la var bean79 "Bean Yield"
la var sugarcane79 "Sugarcane Yield"
la var dist_coast "Distance to Coast"
la var dist_capital "Distance to Capital"
la var rain_z "Rainfall"
la var max_temp_z "Max Temperature"
la var min_temp_z "Min Temperature"
la var d_city45 "Had a City/Village"
la var dist_city45 "Distance to City/Village"
la var dist_comms45 "Distance to Comms"
la var comms45_dens "Comms Density"
la var high_pop80_swithin "Within high populated"
la var reform "Had Land Reform"
la var d_parr80 "Had a Parish"
la var dist_parr80 "Distance to Parish"
la var grown80_swithin "Within cultivated area"
la var z_crops "Z-Yield of All Crops"
la var dist_schl80 "Distance to School"
la var pop_bornbef80_always "Population"
la var dens_pop_bornbef80 "Population density"
la var mean_educ_years_wnsage "Years of education"
la var sh_before_war_child "Natality Rate"
la var sh_before_war_inmigrant "In-migration (share)"
la var sh_before_war_outmigrant "Out-migration (share)"
la var sibean "Suitability Index Bean"
la var sicoffee "Suitability Index Coffee"
la var simaize "Suitability Index Maize"
la var sisugar "Suitability Index Sugarcane"

*-------------------------------------------------------------------------------
* Stats sample vs rest of the country
*-------------------------------------------------------------------------------
*Labeling for this table
la var elevation2 "Altitude"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway"
la var coffee79 "Coffe Potential Yield"
la var cotton79 "Cotton Potential Yield"
la var maize79 "Maize Potential Yield"
la var rice79 "Wet Rice Potential Yield"
la var bean79 "Bean Potential Yield"
la var sugarcane79 "Sugarcane Potential Yield"
la var dist_coast "Distance to Coast"
la var dist_capital "Distance to Capital"
la var rain_z "Rainfall"
la var max_temp_z "Max Temperature"
la var min_temp_z "Min Temperature"
la var d_city45 "Had a City/Village"
la var dist_city45 "Distance to City/Village"
la var dist_comms45 "Distance to Comms"
la var comms45_dens "Comms Density"
la var high_pop80_swithin "High Populated area"
la var reform "Had Land Reform"
la var d_parr80 "Had a Parish"
la var dist_parr80 "Distance to Parish"
la var grown80_swithin "Cultivated area"
la var z_crops "Z-Potential Yield"
la var dist_schl80 "Distance to School"
la var pop_bornbef80_always "Total Population"
la var dens_pop_bornbef80 "Population density"
la var mean_educ_years_wnsage "Years of Education"
la var sh_before_war_child "Natality Rate"
la var sh_before_war_inmigrant "In-migration (Share)"
la var sh_before_war_outmigrant "Out-migration (Share)"
la var sibean "Bean Suitability Index"
la var sicoffee "Coffee Suitability Index" 
la var simaize "Maize Suitability Index" 
la var sisugar "Sugarcane Suitability Index"
la var h_sibean "Bean High Suitability"
la var h_sicoffee "Coffee High Suitability" 
la var h_simaize "Maize High Suitability" 
la var h_sisugar "Sugarcane High Suitability"
la var events "Number of War Events"
la var victims "Number of War Victims"
la var entries "Number of Incarcerations"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gen samplec =( abs(z_run_cntrl)<=${h})

*Descriptives for the sample chosen 
tabstat $lc1 $lc2 $lc3 $lc4 $lc5 $lc6 if samplec==1, s(mean N) save
tabstatmat A
mat A=A'

tabstat $lc1 $lc2 $lc3 $lc4 $lc5 $lc6 if samplec==0, s(mean N) save
tabstatmat B
mat B=B'

mat S=A,B

tempfile X
frmttable using `X', statmat(S) ctitle("", "Mean", "Obs", "Mean", "Obs") sdec(3,0,3,0) varlabels fragment tex nocenter replace  	
filefilter `X' "${tables}/summary_stats_lc_all.tex", from("{tabular}\BS\BS") to("{tabular}") replace







*END
