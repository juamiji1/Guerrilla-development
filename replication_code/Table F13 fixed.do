/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Summary statistics inside vs outside bandwidth (Table F13 fixed)
DATE:
AUTHORS:
RA: JMJR

NOTES: Uses same variables and panel structure as Table 1 (local continuity).
       Reports mean, p25, p50, p75, and N separately for observations inside
       and outside the optimal bandwidth.
------------------------------------------------------------------------------*/

clear all

* Importing additional variables:

* State Administration
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\submissions\QJE\New Results/CabecerasCount.csv", clear
gen newstring = string(seg_id,"%08.0f")
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
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\submissions\QJE\New Results//BasesMilitares.csv", clear
gen newstring = string(seg_id,"%08.0f")
drop seg_id
rename newstring segm_id
rename numpoints basesmilitares
save "${data}/localcontinuity/Output Data/MilitaryBases.dta", replace

* Distance to Military Bases
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\submissions\QJE\New Results/DisttoMilBase.csv", clear
gen newstring = string(seg_id,"%08.0f")
drop seg_id
rename newstring segm_id
keep segm_id hubdist
rename hubdist d_basesmilitares
save "${data}/localcontinuity/Output Data/DistancetoMilitaryBases.dta", replace


********************************************************************************
use "$data/night_light_13_segm_lvl_onu_91_nowater", clear

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
replace m_name="mercedes umana"   if m_name=="mercedes uma\~na"
replace m_name="santo domingo"    if m_name=="santo domingo de guzman"
replace m_name="delgado"          if m_name=="ciudad delgado"
replace m_name="san rafael"       if m_name=="san rafael oriente"
replace m_name="opico"            if m_name=="san juan opico"
replace m_name="san jose las flores" if m_name=="las flores"
replace m_name="nueva san salvador"  if m_name=="santa tecla"
replace d_name="cabanas"          if d_name=="caba\~nas"

merge m:1 d_name m_name using "${data}/localcontinuity/Output Data/BECs1974.dta", gen(base_merge)

* Additional cleaning:
replace entries=0   if entries==.
replace baseec74=0  if baseec74==.

* Additional variable: Differences in churches affiliated to becs
gen d_parr802=d_parr80
replace d_parr802=0 if baseec74==0

*Standardizing Suitability Index
foreach var in sibean sicoffee simaize sisugar {
	egen z_`var'=std(`var')
	gen m_`var'=(`var'>4000) if `var'!=.
	gen g_`var'=(`var'>5500) if `var'!=.
	gen h_`var'=(`var'>7000) if `var'!=.
	gen vh_`var'=(`var'>8500) if `var'!=.
}

*-------------------------------------------------------------------------------
* Bandwidth
*-------------------------------------------------------------------------------
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

* Inside/outside BW indicator
gen samplec=(abs(z_run_cntrl)<=${h})

*-------------------------------------------------------------------------------
* Variable globals (same as Table 1)
*-------------------------------------------------------------------------------
* Panel A: State Capacity — had military base, dist to military base, state admin,
*   dist school, had parish, dist parish, dist comms, comms density, had city, dist city
gl lc1 "basesmilitares d_basesmilitares cabecera dist_schl80 d_parr80 dist_parr80 dist_comms45 comms45_dens d_city45 dist_city45"

* Panel B: Socioeconomic — roads/railway, population, education, migration shares
gl lc2 "rail_road pop_bornbef80_always mean_educ_years_wnsage sh_before_war_inmigrant sh_before_war_outmigrant"

* Panel C: Norms and Land Concentration — land reform, ecclesial base community
gl lc3 "reform d_parr802"

* Panel D: Violence
gl lc4 "events victims entries"

* Panel E: Geographic characteristics — altitude, slope, ruggedness, hydro, crop suitability
gl lc5 "elevation2 slope rugged hydrography h_sibean h_sicoffee h_simaize h_sisugar"

*-------------------------------------------------------------------------------
* Labels
*-------------------------------------------------------------------------------
* lc1
la var basesmilitares   "Had a Military Base (1980)"
la var d_basesmilitares "Distance to Military Base (1980)"
la var cabecera         "State Administration (1980)"
la var dist_schl80      "Distance to School (1980)"
la var d_parr80         "Had a Parish (1979)"
la var dist_parr80      "Distance to Parish (1979)"
la var dist_comms45     "Distance to Communications (1945)"
la var comms45_dens     "Communications Density (1945)"
la var d_city45         "Had a City or Village (1945)"
la var dist_city45      "Distance to City or Village (1945)"

* lc2
la var rail_road                "Roads and Railway (1980)"
la var pop_bornbef80_always     "Total Population (1980)"
la var mean_educ_years_wnsage   "Years of Education (1980)"
la var sh_before_war_inmigrant  "In-migration Share (1980)"
la var sh_before_war_outmigrant "Out-migration Share (1980)"

* lc3
la var reform    "Part of Land Reform (1980)"
la var d_parr802 "Had a Ecclesial Base Community (1974)"

* lc4
la var events  "Number of War Events (1981)"
la var victims "Number of War Victims (1981)"
la var entries "Number of Incarcerations (1980-1985)"

* lc5
la var elevation2  "Altitude (1980)"
la var slope       "Slope (1980)"
la var rugged      "Ruggedness (1980)"
la var hydrography "Hydrography (1980)"
la var h_sibean    "Bean High Suitability (1961-1990)"
la var h_sicoffee  "Coffee High Suitability (1961-1990)"
la var h_simaize   "Maize High Suitability (1961-1990)"
la var h_sisugar   "Sugarcane High Suitability (1961-1990)"

*-------------------------------------------------------------------------------
* Summary statistics: inside BW (samplec==1) vs outside BW (samplec==0)
* Write LaTeX table directly using file write for full formatting control
*-------------------------------------------------------------------------------

* Panel titles
local title1 "Panel A: Baseline State Capacity (Before 1980)"
local title2 "Panel B: Baseline Socioeconomic Characteristics (Before 1980)"
local title3 "Panel C: Baseline Norms and Land Concentration (Before 1980)"
local title4 "Panel D: Violence (1980--1985)"
local title5 "Panel E: Geographic Characteristics and Crops' Suitability (Before 1980)"

* Open file
cap file close myfile
file open myfile using "${tables}/Table_F13_fixed.tex", write replace

* Table header
file write myfile "\begin{tabular}{lcccccccccccc}" _n
file write myfile "\hline \hline" _n
file write myfile "& \multicolumn{6}{@{}c}{In RD-Sample} & \multicolumn{6}{@{}c}{Out of RD-Sample} \\ \cline{2-7} \cline{8-13}" _n
file write myfile "\textit{Baseline Characteristics} & Mean & SD & p25 & p50 & p75 & Obs & Mean & SD & p25 & p50 & p75 & Obs\\ \hline" _n

* Loop over panels
foreach r in 1 2 3 4 5 {

	* Panel header
	file write myfile "\multicolumn{13}{l}{\textit{`title`r''}} \\ \hline" _n

	* Loop over variables in this panel
	foreach var of global lc`r' {

		local vlab: variable label `var'

		* Inside BW stats
		qui summ `var' if samplec==1, d
		local mean_in  = string(r(mean), "%12.3f")
		local sd_in    = string(r(sd),   "%12.3f")
		local p25_in   = string(r(p25),  "%12.3f")
		local p50_in   = string(r(p50),  "%12.3f")
		local p75_in   = string(r(p75),  "%12.3f")
		local n_in     = string(r(N),    "%12.0fc")

		* Outside BW stats
		qui summ `var' if samplec==0, d
		local mean_out = string(r(mean), "%12.3f")
		local sd_out   = string(r(sd),   "%12.3f")
		local p25_out  = string(r(p25),  "%12.3f")
		local p50_out  = string(r(p50),  "%12.3f")
		local p75_out  = string(r(p75),  "%12.3f")
		local n_out    = string(r(N),    "%12.0fc")

		* Write row
		file write myfile "`vlab' & `mean_in' & `sd_in' & `p25_in' & `p50_in' & `p75_in' & `n_in' & `mean_out' & `sd_out' & `p25_out' & `p50_out' & `p75_out' & `n_out'\\" _n
	}

	* Add hline after each panel except the last
	if `r' < 5 {
		file write myfile "\hline " _n
	}
}

* Table footer
file write myfile "\noalign{\smallskip}\hline\end{tabular}" _n
file close myfile


*END
