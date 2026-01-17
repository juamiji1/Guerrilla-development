/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: 
------------------------------------------------------------------------------*/

clear all 
clear all 

*-------------------------------------------------------------------------------
*Sample of Segments
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

*Conditional for all specifications
keep if abs(z_run_cntrl)<=${h}

gen rdsample=1


keep segm_id z_run_cntrl rdsample within_control

tempfile RDDSAMPLE
save `RDDSAMPLE', replace 

*-------------------------------------------------------------------------------
*LAPOP
*-------------------------------------------------------------------------------
capture program drop make_index_gr
capture mata: mata drop icwxmata()
program make_index_gr
version 16
    syntax anything [if]
    gettoken newname anything: anything
    gettoken wgt anything: anything
	gettoken sgroup anything: anything
    local Xvars `anything'
	marksample touse
  	mata: icwxmata(("`Xvars'"),"`wgt'","`sgroup'", "index")
	rename index index_`newname'
end

mata:
	mata set matastrict off
	function icwxmata(xvars, wgts, sgroups, indexname)
	{
		st_view(X=0,.,tokens(xvars))
		st_view(wgt=.,.,wgts)
		st_view(sgroup=.,.,sgroups)
		nr = rows(X)
		nc = cols(X)	
		sg_wgt = wgt:*sgroup
		sg_wgtst = sg_wgt/sum(sg_wgt)
		all_wgtst = wgt/sum(wgt)
		sg_wgtstdM = J(1,nc,1) # sg_wgtst
		all_wgtstdM = J(1,nc,1) # all_wgtst
		sg_wgtdmeans = colsum(X:*sg_wgtstdM)
		sgroup2 = sgroup
		sgroupdM = J(1,nc,1) # sgroup2
		sg_meandevs = ((X:*sgroupdM) - (J(nr,1,1) # sg_wgtdmeans):*sgroupdM)
		all_wgtdmeandevs = X - (J(nr,1,1) # sg_wgtdmeans)
		sg_wgtdstds = sqrt(colsum(sg_wgt:*(sg_meandevs:*sg_meandevs)):/(sum(sg_wgt)-1))
		Xs = all_wgtdmeandevs:/(J(nr,1,1) # sg_wgtdstds)
		S = variance(Xs, wgt)
		invS = invsym(S)
		ivec = J(nc,1,1)
		indexout_sc = (invsym(ivec'*invS*ivec)*ivec'*invS*Xs')'
		indexout = indexout_sc/sqrt(variance(indexout_sc, sg_wgt))
		st_addvar("float",indexname)
		st_store(.,indexname,indexout)
	}
end

import excel "/Users/bj6385/Desktop/GD_SLV/Survey Data/In/censo2007/gis_segmentos/ID_census_v2.xls", sheet("ID_census_v2") firstrow clear 
ren _all, low

*Creating the segment id  
gen segid_part=substr(name, 4, 4)
gen segm_id=cod_dpto+cod_mun+segid_part

*Dropping duplicates 
*duplicates drop segm_id, force

keep segm_id id 

tempfile ID
save `ID', replace

import excel "/Users/bj6385/Desktop/GD_SLV/Survey Data/In/censo2007/gis_segmentos/ID_census_v1.xls", sheet("ID_census_v1") firstrow clear 
ren _all, low

ren seg_id segm_id
keep segm_id

merge 1:m segm_id using `ID', keep(3) nogen

ren id ID 
isid ID 

tempfile ID2
save `ID2', replace

*New vars 
use "${data}/lapop/base_nueva/20220401_LAPOP 2004-2016 a nivel de individuo con ID.dta", clear

drop _merge
merge m:1 ID using `ID2', keep(3) nogen

d sitecon reu_relig reu_esc reu_prof reu_com conf_com contrib_c paz_cal paz_sitecon paz_sitpol paz_camb

foreach var in reu_relig reu_esc reu_prof reu_com conf_com{
	gen `var'_high=(`var'==1) if `var'!=.
	gen `var'_low=(`var'==4) if `var'!=.
} 

gen asist_reu_high= (reu_relig==1 | reu_esc==1 | reu_com==1 | reu_prof==1) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.
gen asist_reu_low= (reu_relig==4 | reu_esc==4 | reu_com==4 | reu_prof==4) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.

recode sitecon (2 3 = 1) (4 5 = 0)
recode reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon (2 = 1) (3 4 = 0) 

gen asist_reu= (reu_relig==1 | reu_esc==1 | reu_com==1 | reu_prof==1) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.

*Collapsing at the segment level
collapse sitecon reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon paz_sitpol asist_reu *_high *_low, by(segm_id)

tempfile LAPOP0
save `LAPOP0', replace 

*Index vars
use "${data}/lapop/lapop_panel_segmento/LAPOP 2004-2016 a nivel de individuo con ID.dta", clear

drop _merge
merge m:1 ID using `ID2', keep(3) nogen
merge m:1 segm_id using `RDDSAMPLE', keep (1 3) nogen 

d aprobacion2 aprobacion3 aprobacion4 aprobacion7 aprobacion8 bienservicio1 bienservicio4 confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 confianza47a culturapolitica2 culturapolitica3 culturapolitica4 satisfaccion2 satisfaccion3 satisfaccion6

*Recoding 
recode aprobacion3 aprobacion4 aprobacion7 aprobacion8 (1/5 = 0) (6/10 =1)
recode bienservicio1 (1 = 0) (2/4 =1)
recode confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 confianza47a (1/4 = 0) (5/7 =1)
recode culturapolitica4 (4 = 0) (2/3 = 1)
recode satisfaccion2 satisfaccion3 satisfaccion6 (3/4 = 0) (2 = 1)

*Indices (sum)
drop confianza47a confianza50 confianza68 confianza69

gl pp "aprobacion1 aprobacion2 aprobacion3 aprobacion4"
gl ep "culturapolitica2 culturapolitica3 culturapolitica4"
gl ap "aprobacion5 aprobacion6 aprobacion7 aprobacion8 "
gl trst "confianza1 confianza2 confianza4 confianza6 confianza12 confianza13 confianza18 confianza21 confianza31 confianza43 confianza47"

*Political affiliations
egen miss1=rowmiss(${pp})
gen pp_sample=(miss1==0)

egen miss2=rowmiss(${ep})
gen ep_sample=(miss2==0)

egen miss3=rowmiss(${ap})
gen ap_sample=(miss3==0)

egen miss4=rowmiss(${trst})
gen trst_sample=(miss4==0)

*Total summatory 
egen sum_pp=rowtotal(${pp}) if pp_sample==1 & rdsample==1, missing
egen sum_ep=rowtotal(${ep}) if ep_sample==1 & rdsample==1, missing
egen sum_ap=rowtotal(${ap}) if ap_sample==1 & rdsample==1, missing
egen sum_trst=rowtotal(${trst})  if trst_sample==1 & rdsample==1, missing

*Indices (ICW)
gen wgt=1
gen stdgroup=1

make_index_gr pp wgt stdgroup ${pp} if rdsample==1
make_index_gr ep wgt stdgroup ${ep} if rdsample==1
make_index_gr ap wgt stdgroup ${ap} if rdsample==1
make_index_gr trst wgt stdgroup ${trst} if rdsample==1

 
*Crime perceptions
recode pandillaje (4 3 2 = 0) 
gen delinc_all=1 if delinc==1 | delinc_hog==1
replace delinc_all=0 if delinc==0 & delinc_hog==0

*Collapsing 
collapse (mean) rdsample index* (first) within_control, by(segm_id)

  foreach y in index_pp index_ep index_ap index_trst {
  	sum `y' if rdsample==1 & within_control==0
  	gen z_`y'=((`y'-r(mean))/r(sd)) if rdsample==1
 }


*Merging the new vars
merge 1:1 segm_id using `LAPOP0', nogen

*Checking the unique identifier
isid segm_id

*Saving the data 
tempfile LAPOP
save `LAPOP', replace 


*-------------------------------------------------------------------------------
* 						Spatial RDD Results
*
*-------------------------------------------------------------------------------
*Census segment level data 

*Census segment level data 
cls

use "${data}/incarcerations/entries_1980_1990_with_segment.dta", clear

 gen counter=1 
 replace counter=. if sipe==""
  
 keep if yearsp>=1980 & yearsp<1985
 collapse (rawsum) counter, by (seg_id)
 rename (seg_id counter) (segm_id entries)
 
 merge 1:1 segm_id using "$data/night_light_13_segm_lvl_onu_91_nowater", nogen
 cap drop z_index_pp z_index_ep z_index_ap z_index_trst 

merge 1:1 segm_id using `LAPOP', keep(1 3) nogen 

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

*Creating vars per habitant
gen hosp_pop=total_hospitals*100000/total_pop
gen schl_pop=total_schools*100000/total_pop

gl is "h_bean05 h_maize05 h_coffee05 h_sugar05"
gen segm_area=AREA_K*100 

foreach var of global is{
	gen s`var'=`var'/segm_area
}

*-------------------------------------------------------------------------------
* Local continuity (Table)
*-------------------------------------------------------------------------------
*Global of local continuity vars to check 
gl lc0 "within_control z_run_cntrl"
gl lc1 "arcsine_nl13 elevation2 slope rugged hydrography rail_road"
gl lc2 "z_wi hosp_pop schl_pop sewerage_sh garbage_sh pipes_sh electricity_sh daily_water_sh total_pop mean_educ_years literacy_rate total_migrant"
gl lc3 "isic1_agr isic1_ind isic1_serv agr_azcf"
gl lc4 "z_index_pp z_index_ep z_index_ap z_index_trst conf_com_low"
gl lc5 "prod_bean05 prod_maize05 prod_coffee05 prod_sugar05 sh_bean05 sh_maize05 sh_coffee05 sh_sugar05 bean05 maize05 coffe05 sugar05"




la var isic1_agr "Agriculture (2007)"
la var isic1_ind "Industry (2007)"
la var isic1_serv "Services (2007)"
la var agr_azcf "Grows cereals and fruits (2007)"
la var hosp_pop "Hospitals per 100k"
la var schl_pop "Schools per 100k"


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
la var sh_before_war_child "Birth Rate"
la var sh_before_war_inmigrant "In-migration (share)"
la var sh_before_war_outmigrant "Out-migration (share)"
la var sibean "Suitability Index Bean"
la var sicoffee "Suitability Index Coffee"
la var simaize "Suitability Index Maize"
la var sisugar "Suitability Index Sugarcane"



*-------------------------------------------------------------------------------
* Stats sample vs rest of the country
*-------------------------------------------------------------------------------
*Labeling for tables 
*lc0
la var within_control "Segment under guerrilla control"
la var z_run_cntrl "Distance to nearest controlled area"
*lc1
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var elevation2 "Altitude (1980)"
la var slope "Slope (1980)"
la var rugged "Ruggedness (1980)"
la var hydrography "Hydrography (1980)"
la var z_crops "Aggregate Yield Index (1961-1979)"
la var bean79 "Bean Potential Yield (1961-1979)"
la var coffee79 "Coffe Potential Yield (1961-1979)"
la var cotton79 "Cotton Potential Yield (1961-1979)"
la var maize79 "Maize Potential Yield (1961-1979)"
la var rice79 "Wet Rice Potential Yield (1961-1979)"
la var sugarcane79 "Sugarcane Potential Yield (1961-1979)"
la var rail_road  "Roads and Railway (1980)"

*lc2

la var z_wi "Wealth Index (2007)"
la var hosp_pop "Hospitals per 100k Population (2007)"
la var schl_pop "Schools per 100k Population (2007)"
la var sewerage_sh  "Sewerage Service Rate (2007)"
la var garbage_sh "Garbage Rate (2007)"
la var pipes_sh "Water Access Rate (2007)"
la var electricity_sh "Electricity Rate (2007)"
la var daily_water_sh "Daily Water Rate (2007)"
la var total_pop "Total Population (2007)"
la var sh_before_war_child "Birth Rate (2007)"
la var mean_educ_years "Years of Education (2007)"
la var literacy_rate "Literacy Rate (2007)"
la var total_migrant "International Migrants (2007)"

*lc3 
la var isic1_agr "Agriculture (2007)"
la var isic1_ind "Industry (2007)"
la var isic1_serv "Services(2007)"
la var agr_azcf "Share of Agricultural Workers Growing Subsistence Crops (2007)"

*lc4 
la var z_index_pp "Political Paticipation ICW (2004–2016)"
la var z_index_ep "Engagement with Politicians ICW (2004–2016)"
la var z_index_ap "Non-Democratic Engagement ICW (2004–2016)"
la var z_index_trst "Trust in Institutions ICW (2004–2016)"
la var conf_com_low "Distrust of Members of the Community Share (2004–2016)"


*lc5 
la var prod_bean05 "Bean Production (2005)"
la var prod_maize05 "Maize Production (2005)"
la var prod_coffee05 "Coffee Production (2005)"
la var prod_sugar05 "Sugarcane Production (2005)"
la var sh_bean05 "Share of Bean Harvest (2005)"
la var sh_maize05 "Share of Maize Harvest (2005)"
la var sh_coffee05 "Share of Coffee Harvest (2005)"
la var sh_sugar05 "Share of Sugarcane Harvest (2005)"
la var bean05 "Bean Yield (2005)"
la var maize05 "Maize Yield (2005)"
la var coffe05 "Coffee Yield (2005)"
la var sugar05"Sugarcane Yield (2005)"


*-------------------------------------------------------------------------------
* Summary stats 
*-------------------------------------------------------------------------------
la var within_control "Segment under guerrilla control"

mat HA=J(1,5,.)
mat HB=J(1,5,.)
mat HC=J(1,5,.)
mat HD=J(1,5,.)
mat HE=J(1,5,.)
mat HF=J(1,5,.)
mat rown HA="Panel A"
mat rown HB="Panel B"
mat rown HC="Panel C"
mat rown HD="Panel D"
mat rown HE="Panel E"
mat rown HF="Panel F"

tabstat $lc0, s(mean sd min max N) save
tabstatmat A
mat A=A'

tabstat $lc1, s(mean sd min max N) save
tabstatmat B
mat B=B'

tabstat $lc2, s(mean sd min max N) save
tabstatmat C
mat C=C'

tabstat $lc3, s(mean sd min max N) save
tabstatmat D
mat D=D'

tabstat $lc4, s(mean sd min max N) save
tabstatmat E
mat E=E'

tabstat $lc5, s(mean sd min max N) save
tabstatmat F
mat F=F'


mat S=HA\A\HB\B\HC\C\HD\D\HE\E\HF\F

tempfile X X1 X2 X3 X4 X5 X6 X7 
frmttable using `X', statmat(S) ctitle("", "Mean","SD", "Min", "Max", "Obs") sdec(3,3,3,3,0) multicol(2,1,3;5,1,3;19,1,3;33,1,3;38,1,3;44,1,3) varlabels fragment tex nocenter replace  	
filefilter `X' `X1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `X1' `X2', from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace
filefilter `X2' `X3', from("Panel A") to("\BStextit{Panel A: Ceasefire map of 1991}") replace
filefilter `X3' `X4', from("Panel B") to("\BStextit{Panel B: Geographic characteristics}") replace
filefilter `X4' `X5', from("Panel C") to("\BStextit{Panel C: Socioeconomic characteristics}") replace
filefilter `X5' `X6', from("Panel D") to("\BStextit{Panel D: Economic activity}") replace
filefilter `X6' `X7', from("Panel E") to("\BStextit{Panel E: Attitudes towards the Government}") replace
filefilter `X7' "${tables}\summary_stats.tex", from("Panel F") to("\BStextit{Panel F: Agricultural Productivity}") replace






*END
