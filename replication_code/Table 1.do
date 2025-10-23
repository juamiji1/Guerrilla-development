/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: 
------------------------------------------------------------------------------*/

clear all 

* Importing additional variables:

* State Administration
 import delimited "/Users/bj6385/Dropbox (Princeton)/Guerillas_Development/submissions/QJE/New Results/CabecerasCount.csv", clear 
 gen newstring  = string(seg_id,"%08.0f")
 drop seg_id
 rename newstring segm_id 
 rename numpoints cabecera
 save "${data}/localcontinuity/Output Data/Cabeceras.dta", replace

* BECs in 1974:
import delimited "${data}/localcontinuity/Output Data/BECs1974.csv", clear
replace baseec=0 if baseec==. 
 gen d_name = ustrlower( ustrregexra( ustrnormalize(adm1_es, "nfd" ) , "\p{Mark}", "" )  )
 gen m_name= ustrlower( ustrregexra( ustrnormalize(adm2_es, "nfd" ) , "\p{Mark}", "" )  )
 rename baseec baseec74
keep d_name m_name baseec74
save "${data}/localcontinuity/Output Data/BECs1974.dta", replace

* Incarcerations in the Pre-period:
use "${data}/incarcerations/entries_1980_1990_with_segment.dta", clear

 gen counter=1 
 replace counter=. if sipe==""
  
 keep if yearsp>=1980 & yearsp<1985
 collapse (rawsum) counter, by (seg_id)
 rename (seg_id counter) (segm_id entries)
 save "${data}/localcontinuity/Output Data/Incarceration_Entries.dta", replace

* Presence of Military Bases
 import delimited "/Users/bj6385/Dropbox (Princeton)/Guerillas_Development/submissions/QJE/New Results/BasesMilitares.csv", clear 
 gen newstring  = string(seg_id,"%08.0f")
 drop seg_id
 rename newstring segm_id 
 rename numpoints basesmilitares
  save "${data}/localcontinuity/Output Data/MilitaryBases.dta", replace


* Distance to Military Bases

import delimited "/Users/bj6385/Dropbox (Princeton)/Guerillas_Development/submissions/QJE/New Results/DisttoMilBase.csv", clear 
 gen newstring  = string(seg_id,"%08.0f")
 drop seg_id
 rename newstring segm_id 
 keep segm_id hubdist
 rename hubdist d_basesmilitares
   save "${data}/localcontinuity/Output Data/DistancetoMilitaryBases.dta", replace

 
********************************************************************************
use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear 

* Merge the additional data sources 

* State Administration:
 merge 1:1 segm_id using "${data}/localcontinuity/Output Data/Cabeceras", nogen

* Incarcerations:
 merge 1:1 segm_id using "${data}/localcontinuity/Output Data/Incarceration_Entries", nogen
 
 * Military Bases:
 merge 1:1 segm_id using "${data}/localcontinuity/Output Data/MilitaryBases", nogen

 * Distance to Military Bases:
 merge 1:1 segm_id using "${data}/localcontinuity/Output Data/DistancetoMilitaryBases", nogen

 * Hydrometrics and Land use 
 clonevar seg_id=segm_id
 merge 1:1 seg_id using "${data}/localcontinuity/Output Data/shape_dhidro_landuse", nogen keepusing(desthidro landuse2)

 

* BECs:
gen d_name = ustrlower( ustrregexra( ustrnormalize(depto_name, "nfd" ) , "\p{Mark}", "" )  )
gen m_name= ustrlower( ustrregexra( ustrnormalize(muni_name, "nfd" ) , "\p{Mark}", "" )  )
replace m_name="san buenaventura" if m_name=="san buena ventura"
replace m_name="mercedes umana" if m_name=="mercedes uma�a"
replace m_name="santo domingo" if m_name=="santo domingo de guzman"
replace m_name="delgado" if m_name=="ciudad delgado"
replace m_name="san rafael" if m_name=="san rafael oriente"
replace m_name="opico" if m_name=="san juan opico" 
replace m_name="san jose las flores" if m_name=="las flores" 
replace m_name="nueva san salvador" if m_name=="santa tecla"  
replace d_name="cabanas" if d_name=="caba�as" 

merge m:1 d_name m_name using "${data}/localcontinuity/Output Data/BECs1974.dta", gen(base_merge)

 
 
 
 
* Additional cleaning:
replace entries=0 if entries==.
replace baseec74=0 if baseec74==.


* Additional variable: Differences in chruches affiliated to becs
gen d_parr802=d_parr80
replace d_parr802=0 if baseec74==0
gl nl "d_parr802"


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
gl lc1 "basesmilitares d_basesmilitares cabecera dist_schl80 dist_comms45 comms45_dens d_city45 dist_city45 rail_road " 
gl lc2 "pop_bornbef80_always mean_educ_years_wnsage sh_before_war_inmigrant sh_before_war_outmigrant"
gl lc3 "reform d_parr802 d_parr80 dist_parr80"
gl lc4 "events victims entries"
gl lc5 "elevation2 slope rugged hydrography h_sibean h_sicoffee h_simaize h_sisugar desthidro landuse2"

*Labeling for tables
******************************************************************************** 
* lc1
la var basesmilitares "Had a Military Base (1980)"
la var d_basesmilitares "Distance to Military Base (1980)"
la var cabecera "State Administration (1980)"
la var dist_schl80 "Distance to School (1980)"
la var dist_comms45 "Distance to Telecommunications (1945)"
la var comms45_dens "Telecommunications Density (1945)"
la var d_city45 "Had a City or Village (1945)"
la var dist_city45 "Distance to City or Village (1945)"
la var rail_road  "Roads and Railway (1980)"

********************************************************************************
* lc2
la var pop_bornbef80_always "Total Population (1980)"
la var mean_educ_years_wnsage "Years of Education (1980)"
la var sh_before_war_inmigrant "In-migration Share (1980)"
la var sh_before_war_outmigrant "Out-migration Share (1980)"
********************************************************************************
* lc3
la var reform "Part of Land Reform (1980)"
la var d_parr802 "Had a Ecclesial Base Community (1974)"
la var d_parr80 "Had a Parish (1979)"
la var dist_parr80 "Distance to Parish (1979)"
********************************************************************************
*lc4
la var events "Number of War Events (1981)"
la var victims "Number of War Victims (1981)"
la var entries "Number of Incarcerations (1980-1985)"
********************************************************************************
* lc5
la var elevation2 "Altitude (1980)"
la var slope "Slope (1980)"
la var rugged "Ruggedness (1980)"
la var hydrography "Hydrography (1980)"
la var h_sibean "Bean High Suitability (1961-1990)"
la var h_sicoffee "Coffee High Suitability (1961-1990)"
la var h_simaize "Maize High Suitability (1961-1990)"
la var h_sisugar "Sugarcane High Suitability (1961-1990)"
la var desthidro "Land Hydrometrics"
la var landuse2 "Land use: Permanent Crops"

 mat drop _all

mat HA=J(1,4,.)
mat HB=J(1,4,.)
mat HC=J(1,4,.)
mat HD=J(1,4,.)
mat HE=J(1,4,.)
mat rown HA="Panel A"
mat rown HB="Panel B"
mat rown HC="Panel C"
mat rown HD="Panel D"
mat rown HE="Panel E"
local num1 : list sizeof global(lc1)
local num2 : list sizeof global(lc2)
local num3 : list sizeof global(lc3)
local num4 : list sizeof global(lc4)
local num5 : list sizeof global(lc5)


mat A1=J(`num1',4,1)
mat A2=J(`num2',4,1)
mat A3=J(`num3',4,1)
mat A4=J(`num4',4,1)
mat A5=J(`num5',4,1)



foreach r in 1 2 3 4 5 {
local i=1
mat rown A`r' = ${lc`r'}
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
}

mat S=HA\A1\HB\A2\HC\A3\HD\A4\HE\A5
mat list S
local bc = rowsof(S)
        matrix stars = J(`bc',2,0)
        forvalues k = 1/`bc' {
			if S[`k',1]!=. {
            matrix stars[`k',1] = (abs(S[`k',1]/S[`k',2]) > invttail(`e(df_r)',0.1/2)) + (abs(S[`k',1]/S[`k',2]) > invttail(`e(df_r)',0.05/2)) + (abs(S[`k',1]/S[`k',2]) > invttail(`e(df_r)',0.01/2))
          }
		  }
         matrix list stars
 

tempfile X X1 X2 X3 X4 X5 X6
frmttable using `X', statmat(S) ctitle("Variable (Year)", "Coefficient","SE", "Dependent Mean", "Obs") sdec(3,3,3,0) multicol(2,1,3;12,1,3;17,1,3;22,1,3;26,1,3) varlabels fragment tex nocenter annotate(stars) asymbol(*,**,***) hlines(1 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0 011 0 0 11 0 0 0 0 0 0 0 0 0 0 1) replace  	
filefilter `X' `X1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `X1' `X2', from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace
filefilter `X2' `X3', from("Panel A") to("\BStextit{Panel A:Baseline State Capacity (Before 1980)}") replace
filefilter `X3' `X4', from("Panel B") to("\BStextit{Panel B:Baseline Socio-Demographic Characteristics (Before 1980)}") replace
filefilter `X4' `X5', from("Panel C") to("\BStextit{Panel C:Baseline Norms and Land Concentration (Before 1980)}") replace
filefilter `X5' `X6', from("Panel D") to("\BStextit{Panel D:Violence (1980--1985)}") replace
filefilter `X6' "${tables}/rdd_lc_all_panel2.tex", from("Panel E") to("\BStextit{Panel E:Geographic Characteristics and Crops' Suitability (Before 1980)}") replace


*-------------------------------------------------------------------------------
* Plots
*
*-------------------------------------------------------------------------------
gl lc "basesmilitares d_basesmilitares cabecera dist_schl80 dist_comms45 comms45_dens d_city45 dist_city45 rail_road pop_bornbef80_always mean_educ_years_wnsage sh_before_war_inmigrant sh_before_war_outmigrant reform d_parr802 d_parr80 dist_parr80 events victims entries elevation2 slope rugged hydrography h_sibean h_sicoffee h_simaize h_sisugar desthidro landuse2"
gl resid "basesmilitares_r d_basesmilitares_r cabecera_r dist_schl80_r dist_comms45_r comms45_dens_r d_city45_r dist_city45_r rail_road_r pop_bornbef80_always_r mean_educ_years_wnsage_r sh_before_war_inmigrant_r sh_before_war_outmigrant_r reform d_parr802_r d_parr80_r dist_parr80_r events_r victims_r entries_r elevation2_r slope_r rugged_r hydrography_r h_sibean_r h_sicoffee_r h_simaize_r h_sisugar_r desthidro_r landuse2_r"

*Against the distance
foreach var of global lc{
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
}

preserve

	gen x=round(z_run_cntrl, 0.08)
	gen n=1
	
	collapse (mean) ${resid} (sum) n, by(x)

	foreach var of global resid{
		two (scatter `var' x if abs(x)<1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var' x [aweight = n] if x<0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var' x [aweight = n] if x>=0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), xlabel(-1(0.2)1) legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3) pos(6)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") name(`var', replace)
		gr export "${plots}\rdplot_all_`var'.pdf", as(pdf) replace 

				
	}
	
restore



*END
