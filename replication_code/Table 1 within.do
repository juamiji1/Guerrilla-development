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

*Excluding roads and railway from the "any institution" measure
egen dist_any_inst_cond=rowmin(dist_school_cond dist_cities_cond dist_comms_cond)

tempfile DISTS
save `DISTS', replace

*Centroid-based distances (built by FV_1_preparing_GIS_centroid_dists.py)
import delimited "${data}\gis\maps_interim\segm_centroid_dists.csv", clear
ren seg_id segm_id
drop within_control

foreach var of varlist dist_*{
	ren `var' c_`var'
}

tostring segm_id, replace
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile CDISTS
save `CDISTS', replace

*Walking-time distances over the DEM (built by FV_1_preparing_GIS_walktime_dists.py)
import delimited "${data}\gis\maps_interim\segm_walktime_dists.csv", clear
ren seg_id segm_id
drop within_control

foreach var of varlist time_*{
	ren `var' t_`var'
}

tostring segm_id, replace
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile TDISTS
save `TDISTS', replace

use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear

merge 1:1 segm_id using `DISTS', nogen
merge 1:1 segm_id using `CDISTS', nogen
merge 1:1 segm_id using `TDISTS', nogen

*Rebuilding the centroid and walking-time "any institution" measures
*excluding roads and railway (the CSV versions include them)
cap drop c_dist_any_cond
egen c_dist_any_cond=rowmin(c_dist_school_cond c_dist_cities_cond c_dist_comms_cond)

cap drop t_time_any_cond
egen t_time_any_cond=rowmin(t_time_school_cond t_time_cities_cond t_time_comms_cond)

*State administration and military bases (for the dichotomous LC test)
if "${lcdata}"=="" gl lcdata "${localpath}\Replication Package/Data (noGIS)/"

merge 1:1 segm_id using "${lcdata}/localcontinuity/Output Data/Cabeceras", nogen
merge 1:1 segm_id using "${lcdata}/localcontinuity/Output Data/MilitaryBases", nogen

la var dist_school_cond "Distance to School (1980)"
la var dist_cities_cond "Distance to City or Village (1945)"
la var dist_road_cond "Distance to Roads and Railway (1980)"
la var dist_comms_cond "Distance to Telecommunications (1945)"
la var dist_any_inst_cond "Distance to Any Institution (Km)"

*Centroid-based versions
la var c_dist_cities_cond "Distance to City or Village (1945)"
la var c_dist_road_cond "Distance to Roads and Railway (1980)"
la var c_dist_comms_cond "Distance to Telecommunications (1945)"
la var c_dist_any_cond "Distance to Any Institution, from Centroid (Km)"
la var c_dist_cities_unc "Distance to City or Village (1945)"
la var c_dist_road_unc "Distance to Roads and Railway (1980)"
la var c_dist_comms_unc "Distance to Telecommunications (1945)"
la var c_dist_any_unc "Distance to Any Institution, from Centroid (Km)"

*Walking-time versions (terrain-adjusted, minutes)
la var t_time_cities_cond "Walking Time to City or Village (Min.)"
la var t_time_road_cond "Walking Time to Roads and Railway (Min.)"
la var t_time_comms_cond "Walking Time to Telecommunications (Min.)"
la var t_time_any_cond "Walking Time to Any Institution (Min.)"
la var t_time_cities_unc "Walking Time to City or Village (Min.)"
la var t_time_road_unc "Walking Time to Roads and Railway (Min.)"
la var t_time_comms_unc "Walking Time to Telecommunications (Min.)"
la var t_time_any_unc "Walking Time to Any Institution (Min.)"

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
gl ht= round(${h}, .001)
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

*-------------------------------------------------------------------------------
* Balance of same-side distances measured from the tract centroid
*-------------------------------------------------------------------------------
gl lcall "dist_any_inst_cond c_dist_any_cond t_time_any_cond"

mat drop _all

local numall : list sizeof global(lcall)
mat B1=J(`numall',4,1)

mat rown B1 = ${lcall}

local i=1
foreach var of global lcall{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})

	mat R=r(table)
	local dfr=e(df_r)

	mat B1[`i',1]=round(R[1,1], .001)
	mat B1[`i',2]=round(R[2,1], .001)
	mat B1[`i',4]=e(N)
	summ `var' if e(sample)==1 & within_control==0, d
	mat B1[`i',3]=round(r(mean), .001)

	local++i
}

mat SB=B1
mat list SB

local bc = rowsof(SB)
matrix starsb = J(`bc',2,0)

forvalues k = 1/`bc' {
	if SB[`k',1]!=. {
		matrix starsb[`k',1] = (abs(SB[`k',1]/SB[`k',2]) > invttail(`dfr',0.1/2)) + (abs(SB[`k',1]/SB[`k',2]) > invttail(`dfr',0.05/2)) + (abs(SB[`k',1]/SB[`k',2]) > invttail(`dfr',0.01/2))
	}
}

matrix list starsb

tempfile Y Y1
frmttable using `Y', statmat(SB) ctitle("Variable (Year)", "Coefficient","SE", "Dependent Mean", "Obs") sdec(3,3,3,0) varlabels fragment tex nocenter annotate(starsb) asymbol(*,**,***) hlines(1 1 0 0 1 1) replace
filefilter `Y' `Y1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `Y1' "${tables}/rdd_lc_all_samesided_cond.tex", from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace

*-------------------------------------------------------------------------------
* Balance of ALL same-side distances - 5 Km bandwidth
*-------------------------------------------------------------------------------
gl h5=5
gl ht5=round(${h5}, .001)

*Conditional and triangular weights for the 5 Km bandwidth
gl if5 "if abs(z_run_cntrl)<=${h5}"

cap drop tweights5
gen tweights5=(1-abs(z_run_cntrl/${h5})) ${if5}

mat drop _all

local numall : list sizeof global(lcall)
mat C1=J(`numall',4,1)

mat rown C1 = ${lcall}

local i=1
foreach var of global lcall{

	*Table
	reghdfe `var' ${controls} [aw=tweights5] ${if5}, vce(r) a(i.${breakfe})

	mat R=r(table)
	local dfr=e(df_r)

	mat C1[`i',1]=round(R[1,1], .001)
	mat C1[`i',2]=round(R[2,1], .001)
	mat C1[`i',4]=e(N)
	summ `var' if e(sample)==1 & within_control==0, d
	mat C1[`i',3]=round(r(mean), .001)

	local++i
}

mat SC=C1
mat list SC

local bc = rowsof(SC)
matrix starsc = J(`bc',2,0)

forvalues k = 1/`bc' {
	if SC[`k',1]!=. {
		matrix starsc[`k',1] = (abs(SC[`k',1]/SC[`k',2]) > invttail(`dfr',0.1/2)) + (abs(SC[`k',1]/SC[`k',2]) > invttail(`dfr',0.05/2)) + (abs(SC[`k',1]/SC[`k',2]) > invttail(`dfr',0.01/2))
	}
}

matrix list starsc

tempfile Z Z1
frmttable using `Z', statmat(SC) ctitle("Variable (Year)", "Coefficient","SE", "Dependent Mean", "Obs") sdec(3,3,3,0) varlabels fragment tex nocenter annotate(starsc) asymbol(*,**,***) hlines(1 1 0 0 1 1) replace
filefilter `Z' `Z1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `Z1' "${tables}/rdd_lc_all_samesided_cond_5km.tex", from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace

*-------------------------------------------------------------------------------
* Balance of UNCONDITIONAL distances, polynomial of degree 0 within the bandwidth
* (mean differences in levels: unconditional distances cannot jump at the
* boundary by construction, but they can differ in levels near it)
*-------------------------------------------------------------------------------
*"Any institution" EXCLUDING roads and railway (schools, cities, comms)
egen dist_any_inst_unc=rowmin(dist_schl80 dist_city45 dist_comms45)

la var dist_schl80 "Distance to School (1980)"
la var dist_city45 "Distance to City or Village (1945)"
la var dist_comms45 "Distance to Telecommunications (1945)"
la var dist_any_inst_unc "Distance to Any Institution (Baseline)"

gl lcunc "dist_schl80 dist_city45 dist_comms45 dist_any_inst_unc"

mat drop _all

local numunc : list sizeof global(lcunc)
mat U1=J(`numunc',4,1)

mat rown U1 = ${lcunc}

local i=1
foreach var of global lcunc{

	*Degree-0 polynomial: no running-variable controls, boundary FE and
	*triangular weights within the bandwidth
	reghdfe `var' within_control [aw=tweights] ${if}, vce(r) a(i.${breakfe})

	mat R=r(table)
	local dfr=e(df_r)

	mat U1[`i',1]=round(R[1,1], .001)
	mat U1[`i',2]=round(R[2,1], .001)
	mat U1[`i',4]=e(N)
	summ `var' if e(sample)==1 & within_control==0, d
	mat U1[`i',3]=round(r(mean), .001)

	local++i
}

mat SU=U1
mat list SU

local bc = rowsof(SU)
matrix starsu = J(`bc',2,0)

forvalues k = 1/`bc' {
	if SU[`k',1]!=. {
		matrix starsu[`k',1] = (abs(SU[`k',1]/SU[`k',2]) > invttail(`dfr',0.1/2)) + (abs(SU[`k',1]/SU[`k',2]) > invttail(`dfr',0.05/2)) + (abs(SU[`k',1]/SU[`k',2]) > invttail(`dfr',0.01/2))
	}
}

matrix list starsu

tempfile V V1
frmttable using `V', statmat(SU) ctitle("Variable (Year)", "Coefficient","SE", "Dependent Mean", "Obs") sdec(3,3,3,0) varlabels fragment tex nocenter annotate(starsu) asymbol(*,**,***) hlines(1 1 0 0 0 1 1) replace
filefilter `V' `V1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `V1' "${tables}/rdd_lc_all_uncond_poly0.tex", from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace

*-------------------------------------------------------------------------------
* Results Interacting
*-------------------------------------------------------------------------------
gen wc_cities=within_control*dist_cities_cond 
gen wc_road=within_control*dist_road_cond
gen wc_comms=within_control*dist_comms_cond
gen wc_any=within_control*dist_any_inst_cond

la var wc_cities "Control $\times$ Distance to City"
la var wc_road "Control $\times$ Distance to Roads"
la var wc_comms "Control $\times$ Distance to Comms."
la var wc_any "Control $\times$ Distance to Any"

gl mainoutcomes "arcsine_nl13 z_wi mean_educ_years"

eststo clear

local i=1
foreach yvar of global mainoutcomes {
	
	*Base Estimation
	eststo c`i': reghdfe `yvar' ${controls} wc_cities dist_cities_cond [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	eststo r`i': reghdfe `yvar' ${controls} wc_road dist_road_cond [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	eststo t`i': reghdfe `yvar' ${controls} wc_comms dist_comms_cond [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	eststo a`i': reghdfe `yvar' ${controls} wc_any dist_any_inst_cond [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_any_`i'=string(r(mean), "%9.2f")

	local ++i
}

*Exporting results 
esttab c1 c2 c3 using "${tables}/rdd_main_all_distcities_cond.tex", keep(within_control wc_cities) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 

*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_main_all_distroad_cond.tex", keep(within_control wc_road) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 
		
*Exporting results 
esttab t1 t2 t3 using "${tables}/rdd_main_all_distcomms_cond.tex", keep(within_control wc_comms) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 
		
*Exporting results
esttab a1 a2 a3 using "${tables}/rdd_main_all_distany_cond.tex", keep(within_control wc_any dist_any_inst_cond) ///
order(within_control wc_any dist_any_inst_cond) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Dependent mean & ${mean_any_1} & ${mean_any_2} & ${mean_any_3} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* Results Interacting - Distance to Any Institution with 5 Km bandwidth
*-------------------------------------------------------------------------------
gl h5=5
gl ht5=round(${h5}, .001)

*Conditional and triangular weights for the 5 Km bandwidth
gl if5 "if abs(z_run_cntrl)<=${h5}"

cap drop tweights5
gen tweights5=(1-abs(z_run_cntrl/${h5})) ${if5}

eststo clear

local i=1
foreach yvar of global mainoutcomes {

	*Base Estimation
	eststo a5_`i': reghdfe `yvar' ${controls} wc_any dist_any_inst_cond [aw=tweights5] ${if5}, vce(r) a(i.${breakfe})
	summ `yvar' if e(sample)==1 & within_control==0, d
	gl mean_any5_`i'=string(r(mean), "%9.2f")

	local ++i
}

*Exporting results
esttab a5_1 a5_2 a5_3 using "${tables}/rdd_main_all_distany_cond_5km.tex", keep(within_control wc_any dist_any_inst_cond) ///
order(within_control wc_any dist_any_inst_cond) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`" Dependent mean & ${mean_any5_1} & ${mean_any5_2} & ${mean_any5_3} \\"' ///
		`" Bandwidth (Km) & ${ht5} & ${ht5} & ${ht5} \\"' ///
		`"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* Descriptive statistics: centroid distance to any institution (uncond. and same side)
* (self-contained block: rebuilds the data, can be run on its own)
*-------------------------------------------------------------------------------
import delimited "${data}\gis\maps_interim\segm_centroid_dists.csv", clear
ren seg_id segm_id

*"Any institution" excluding roads and railway (schools, cities, comms)
egen c_dist_any_unc=rowmin(dist_school_unc dist_cities_unc dist_comms_unc)
egen c_dist_any_cond=rowmin(dist_school_cond dist_cities_cond dist_comms_cond)

keep segm_id c_dist_any_unc c_dist_any_cond

tostring segm_id, replace
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile CDISTS2
save `CDISTS2', replace

use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear
merge 1:1 segm_id using `CDISTS2', nogen

gl h=2.266

*RD-sample version of each variable
foreach var in c_dist_any_cond c_dist_any_unc{
	gen `var'_rd=`var' if abs(z_run_cntrl)<=${h}
}

la var c_dist_any_cond "Distance to Any Institution, Same Side (Km) -- Full Sample"
la var c_dist_any_cond_rd "Distance to Any Institution, Same Side (Km) -- RD Sample"
la var c_dist_any_unc "Distance to Any Institution (Km) -- Full Sample"
la var c_dist_any_unc_rd "Distance to Any Institution (Km) -- RD Sample"

gl dlist "c_dist_any_cond c_dist_any_cond_rd c_dist_any_unc c_dist_any_unc_rd"

*Quick check on screen
tabstat ${dlist}, statistics(count mean sd min p5 p25 p50 p75 p95 max) columns(statistics)

*Exporting table
eststo clear
estpost tabstat ${dlist}, statistics(count mean sd min p5 p25 p50 p75 p95 max) columns(statistics)

esttab using "${tables}/sumstats_dist_any_samesided.tex", replace ///
cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) max(fmt(2))") ///
noobs nonumber nomtitle label booktabs ///
collabels("N" "Mean" "SD" "Min" "P5" "P25" "P50" "P75" "P95" "Max")

*-------------------------------------------------------------------------------
* RI balance for the dichotomous state capacity indicators of Table 1
* (exact permutation inference for the low-variation dummies)
* Self-contained block: rebuilds the data, can be run on its own
*-------------------------------------------------------------------------------
use "$data/night_light_13_segm_lvl_onu_91_nowater" , clear

if "${lcdata}"=="" gl lcdata "${localpath}\Replication Package/Data (noGIS)/"

merge 1:1 segm_id using "${lcdata}/localcontinuity/Output Data/Cabeceras", nogen
merge 1:1 segm_id using "${lcdata}/localcontinuity/Output Data/MilitaryBases", nogen

*BECs (same municipality-name merge as FV_2_rdd_lc_all_replication.do)
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

merge m:1 d_name m_name using "${lcdata}/localcontinuity/Output Data/BECs1974.dta", gen(base_merge)
replace baseec74=0 if baseec74==.

*Churches affiliated to BECs
gen d_parr802=d_parr80
replace d_parr802=0 if baseec74==0

*Presence dummies from the polygon distances (zero = feature inside the tract)
gen d_schl80=(dist_schl80==0) if dist_schl80!=.
gen d_comms45=(dist_comms45==0) if dist_comms45!=.

*Aggregate presence dummy: any of the state indicators
egen any_state=rowmax(basesmilitares cabecera d_city45 d_schl80 d_comms45)
replace any_state=1 if any_state>1 & any_state!=.

gl lcdum "basesmilitares cabecera d_city45 d_schl80 d_comms45 any_state d_parr80 d_parr802"

la var basesmilitares "Had a Military Base (1980)"
la var cabecera "State Administration (1980)"
la var d_city45 "Had a City or Village (1945)"
la var d_schl80 "Had a School (1980)"
la var d_comms45 "Had Telecommunications (1945)"
la var any_state "Had Any State Institution"
la var d_parr80 "Had a Parish (1979)"
la var d_parr802 "Had a Ecclesial Base Community (1974)"

*Globals, bandwidth and triangular weights
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"

gl h=2.266
gl ht=round(${h}, .001)
gl if "if abs(z_run_cntrl)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*RI settings (same scheme as rdd_main_all_RI)
set seed 123
gl reps_ri = 10000

mat drop _all

local numdum : list sizeof global(lcdum)
mat D1=J(`numdum',7,1)

mat rown D1 = ${lcdum}

local i=1
foreach var of global lcdum{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})

	mat R=r(table)
	local dfr=e(df_r)

	mat D1[`i',1]=round(R[1,1], .001)
	mat D1[`i',2]=round(R[2,1], .001)
	mat D1[`i',7]=e(N)
	summ `var' if e(sample)==1 & within_control==0, d
	mat D1[`i',4]=round(r(mean), .001)

	*Minimum detectable effect at 80% power / 5% significance (2.8 x SE),
	*in outcome units and as percent of the control-side mean
	local mde = 2.8*R[2,1]
	mat D1[`i',5]=round(`mde', .001)
	mat D1[`i',6]=round(100*`mde'/r(mean), .1)

	*RI permutation p-value (labels permuted within border segment strata)
	ritest within_control _b[within_control], reps(${reps_ri}) ///
	strata(${breakfe}) force: ///
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})

	mat P=r(p)
	mat D1[`i',3]=round(P[1,1], .001)

	local++i
}

mat SD=D1
mat list SD

local bc = rowsof(SD)
matrix starsd = J(`bc',2,0)

forvalues k = 1/`bc' {
	if SD[`k',1]!=. {
		matrix starsd[`k',1] = (abs(SD[`k',1]/SD[`k',2]) > invttail(`dfr',0.1/2)) + (abs(SD[`k',1]/SD[`k',2]) > invttail(`dfr',0.05/2)) + (abs(SD[`k',1]/SD[`k',2]) > invttail(`dfr',0.01/2))
	}
}

matrix list starsd

tempfile W W1
frmttable using `W', statmat(SD) ctitle("Variable (Year)", "Coefficient","SE", "RI p-value", "Dependent Mean", "MDE", "MDE (\% of Mean)", "Obs") sdec(3,3,3,3,3,1,0) varlabels fragment tex nocenter annotate(starsd) asymbol(*,**,***) hlines(1 1 0 0 0 0 0 0 0 1 1) replace
filefilter `W' `W1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `W1' "${tables}/rdd_lc_statecapacity_dummies_RI.tex", from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace

*END


