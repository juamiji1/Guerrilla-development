/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Preparing night light dat at the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

/*gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development\code"
gl path "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}
*/

*-------------------------------------------------------------------------------
* 			      Converting shape of yields in 2005 to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/gis\maps_interim\slvShp_segm_pnc", data("${data}/temp\slvShp_segm_pnc.dta") coord("${data}/temp\slvShp_segm_pnc_coord.dta") genid(pixel_id) genc(coord) replace 
*shp2dta using "${data}/gis\maps_interim\slvShp_segm_yield05", data("${data}/temp\slvShp_segm_yield05.dta") coord("${data}/temp\slvShp_segm_yield05_coord.dta") genid(pixel_id) genc(coord) replace 

use "${data}/temp\slvShp_segm_pnc.dta", clear
ren (SEG_ID dst_cms dst_r80 dstc_80 dst_r14 dstc_14) (segm_id dist_comisaria dist_road80 distc_road80 dist_road14 distc_road14)

keep segm_id dist_comisaria dist_road80 distc_road80 dist_road14 distc_road14

*Preparing vars
replace dist_comisaria=dist_comisaria/1000
replace dist_road80=dist_road80/1000
replace distc_road80=distc_road80/1000
replace distc_road14=distc_road14/1000
replace dist_road14=dist_road14/1000

*Saving
tempfile PNC
save `PNC', replace 

use "${data}/temp\slvShp_segm_yield05.dta", clear

ren (SEG_ID gp_bn05 gp_ct05 gp_mz05 gp_rc05 gp_sg05 dist_cp n_coop hbean05 hcoff05 hmaiz05 hsugr05 pr_bn05 pr_cf05 pr_mz05 pr_sg05 n_evnts n_vctms dst_hsp dst_sch dst_s80) (segm_id gap_bean05 gap_cotton05 gap_maize05 gap_rice05 gap_sugar05 dist_coop total_coop h_bean05 h_coffee05 h_maize05 h_sugar05 prod_bean05 prod_coffee05 prod_maize05 prod_sugar05 events victims dist_hosp dist_schl dist_schl80)

keep segm_id bean05-h_sugar05 *_coop nl* events victims dist_hosp dist_schl* teachers high_skl* sibean sicoffee simaize sisugar lbean lcoffee lmaize lsugar

*Preparing vars
replace dist_coop=dist_coop/1000
replace dist_hosp=dist_hosp/1000
replace dist_schl=dist_schl/1000
replace dist_schl80=dist_schl80/1000
replace total_coop=0 if total_coop==.

replace events=0 if events==.
replace victims=0 if victims==.
*replace teachers=0 if teachers==.
*replace high_skl1=0 if high_skl1==.
*replace high_skl2=0 if high_skl2==.
*replace high_skl3=0 if high_skl3==.

*Saving
tempfile Y05
save `Y05', replace 


*-------------------------------------------------------------------------------
* 				 Converting shape with all info to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/gis\maps_interim\slvShp_segm_nowater_info_sp_onu_91", data("${data}/temp\slvShp_segm_nowater_info_sp_onu_91.dta") coord("${data}/temp\slvShp_segm_nowater_info_sp_onu_91_coord.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_segm_nowater_info_sp_onu_91.dta", clear

*Keeping only important vars 
rename (SEG_I DEPTO MPIO CANTO wthn_c wthn_d dst_cn dst_ds nl elev elev2 ruggd wmn_n cocoa coffe cottn drice maize bean sgrcn wrice sm_dh sm_km rain maxtmp mintmp rainz mxtmpz mntmpz dst_c2 dst_d2 wthn_c2 wthn_d2 lk_nt rv1_n rv2_n rl_nt rd_nt dst_cs dst_cp dst_dp dst_m n_hsp n_sch mtrcl n_prr n_p80 n_frn n_hmc n_hm_ d_100 b1000 d_400 br400 cn_1000 cn1000 cn_400 cn400 cntrldst_b cntrlbrkf1 cntrldst_1 cntrlbrkf4 rd14_ ln_rd rd_dn cm45_ ds_80 dst_cm ln_cm cmms_ ds_45 n_c45 ben79 cff79 ctt79 maz79 ric79 sgr79 hghpp cltvt dst_cntrl_ wthn_cntrl dst_cntr_1 wthn_cnt_1 cntrldst_2 cntrlbrk_1 cntrldst_3 cntrlbrk_2 pop_w grwn_ mxppd mxpp_ dst_cntr_2 wthn_cnt_2 cntrldst_4 cntrlbrk_3 cntrldst_5 cntrlbrk_4 dst_cntr_3 wthn_cnt_3 cntrldst_6 cntrlbrk_5 cntrldst_7 cntrlbrk_6 wt_82) (segm_id depto_name muni_name canton_name within_control within_disputed dist_control dist_disputed nl13_density elevation elevation2 rugged wmean_nl1 mean_cocoa mean_coffee mean_cotton mean_dryrice mean_maize mean_bean mean_sugarcane mean_wetrice sum_dhydro sum_kmhydro mean_rain max_temp min_temp rain_z max_temp_z min_temp_z dist_control_v2 dist_disputed_v2 within_control_v2 within_disputed_v2 lake river1 river2 rail road dist_coast dist_capital dist_depto dist_muni total_hospitals total_schools total_matricula parroquias parr80 franciscanas homicidios homicidios_gang dist_disputa_breaks_1000 disputa_break_fe_1000 dist_disputa_breaks_400 disputa_break_fe_400 dist_control_breaks_1000 control_break_fe_1000 dist_control_breaks_400 control_break_fe_400 dist_control_breaks_1000_select control_break_fe_1000_select dist_control_breaks_400_select control_break_fe_400_select road14 length_road14 road14_dens comms45 dist_parr80 dist_comms45 length_comms45 comms45_dens dist_city45 city45 bean79 coffee79 cotton79 maize79 rice79 sugarcane79 high_pop80 grown80 dist_control_select within_control_select dist_control_noslv within_control_noslv dist_control_breaks_1000_noslv control_break_fe_1000_noslv dist_control_breaks_400_noslv control_break_fe_400_noslv high_pop80_swithin grown80_swithin max_pop80 max_pop80_swithin dist_control_fake within_control_fake dist_control_breaks_1000_fake control_break_fe_1000_fake dist_control_breaks_400_fake control_break_fe_400_fake dist_control_high within_control_high dist_control_breaks_1000_high control_break_fe_1000_high dist_control_breaks_400_high control_break_fe_400_high  within_control82) 

*Canton ID
gen canton_id=COD_D+COD_M+COD_C
destring canton_id, replace 

*Region 
tab depto_name
gen region=1 if depto_name=="SONSONATE" | depto_name=="AHUACHAPAN" | depto_name=="SANTA ANA" 
replace region=2 if depto_name=="LA LIBERTAD" | depto_name=="SAN SALVADOR" | depto_name=="LA PAZ" | depto_name=="SAN VICENTE" | depto_name=="CUSCATLAN" | depto_name=="LA PAZ" | depto_name=="CABA�AS" | depto_name=="CHALATENANGO"  
replace region=3 if depto_name=="MORAZAN" | depto_name=="LA UNION" | depto_name=="SAN MIGUEL" | depto_name=="USULUTAN"

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.
replace length_road14=0 if length_road14==.
replace length_comms45=0 if length_comms45==.
replace comms45_dens=0 if comms45_dens==.
replace road14_dens=0 if road14_dens==.

*Fixing missings 
replace total_hospitals=0 if total_hospitals==.
replace total_schools=0 if total_schools==.
*replace total_matricula=0 if total_matricula==.

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_control_select=dist_control_select/1000
replace dist_control_noslv=dist_control_noslv/1000
replace dist_control_fake=dist_control_fake/1000
replace dist_control_high=dist_control_high/1000
replace dist_disputed=dist_disputed/1000

replace dist_control_v2=dist_control_v2/1000
replace dist_disputed_v2=dist_disputed_v2/1000

replace dist_coast=dist_coast/1000
replace dist_capital=dist_capital/1000

replace dist_depto=dist_depto/1000
replace dist_muni=dist_muni/1000

replace dist_comms45=dist_comms45/1000
replace dist_parr80=dist_parr80/1000
replace dist_city45=dist_city45/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_cntrl_select= dist_control_select 
replace z_run_cntrl_select= -1*dist_control_select if within_control_select==0 

gen z_run_cntrl_noslv= dist_control_noslv 
replace z_run_cntrl_noslv= -1*z_run_cntrl_noslv if within_control_noslv==0 

gen z_run_cntrl_fake= dist_control_fake
replace z_run_cntrl_fake= -1*z_run_cntrl_fake if within_control_fake==0 

gen z_run_cntrl_high= dist_control_high
replace z_run_cntrl_high= -1*z_run_cntrl_high if within_control_high==0 

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)

*Fixing the running variables (version 2)
gen z_run_cntrl_v2= dist_control_v2 
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_dsptd_v2= dist_disputed_v2 
replace z_run_dsptd_v2= -1*dist_disputed_v2 if within_disputed_v2==0

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

*Fixing the new data
replace within_disputed=1 if within_control==1 & within_disputed==0
rename (within_disputed z_run_dsptd) (within_fmln z_run_fmln)
rename disputa_* fmln_*

*Fixing parroquias 
replace parroquias=0 if parroquias==.
replace parr80=0 if parr80==.
replace franciscanas=0 if franciscanas==.
replace city45=0 if city45==.

gen d_parr=(parroquias>0)  
gen d_parr80=(parr80>0)
gen d_francis=(franciscanas>0)
gen d_city45=(city45>0)

*Fixing homicides 
replace homicidios=0 if homicidios==.
replace homicidios_gang=0 if homicidios_gang==.

*FE of lat-lon  
gen xfe=round(x_coord, .01)
gen yfe=round(y_coord, .01)

*Reducing dimension of crops' yield 
gl crops "bean79 coffee79 cotton79 maize79 rice79 sugarcane79"

foreach var of global crops{
	egen z_crop_`var'=std(`var')
}

egen total_crops=rowtotal(z_crop_bean79 z_crop_coffee79 z_crop_cotton79 z_crop_maize79 z_crop_rice79 z_crop_sugarcane79)
egen z_crops=std(total_crops)

drop total_crops z_crop_*


*-------------------------------------------------------------------------------
* 					Merging the census 2007 data 
*
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 segm_id using "${data}/temp\census07_segm_lvl.dta", nogen 

*Merging the ephm 
merge 1:1 segm_id using "${data}/temp\ephm_segm_lvl.dta", keep(1 3) nogen 
merge 1:1 segm_id using "${data}/ehpm\ehpm_social_cap.dta", keep(1 3) nogen 

*Merging the lapop 
merge 1:1 segm_id using "${data}/temp\lapop_segm_lvl.dta", keep(1 3) nogen 

*Merging land reform and canton 
merge 1:1 segm_id using "${data}/gis\land_reform\census_segm_land_reform.dta", keep(1 3) nogen 
replace reform=0 if reform==.

*Merging yield data in 2005 
merge 1:1 segm_id using `Y05', nogen 
merge 1:1 segm_id using `PNC', nogen 


*-------------------------------------------------------------------------------
* 							Labelling vars
*
*-------------------------------------------------------------------------------
la var nl13_density "Night light density (2013)"
la var z_run_cntrl "Distance to nearest controlled area"
la var z_run_dsptd "Distance to nearest disputed zone (border to border)"
la var z_run_cntrl_v2 "Distance to nearest control zone (centroid to border)"
la var z_run_dsptd_v2 "Distance to nearest disputed zone (centroid to border)"
*la var within_control "Pixel within control zone (intersection)"
la var within_control_v2 "Pixel within control zone (intersection)"
la var within_disputed_v2 "Pixel within disputed zone (intersection)"
la var within_fmln "Within any FMLN zone"
la var within_control "Guerrilla control"
la var elevation2 "Altitude (DEM)"
la var slope "Slope"
la var hydrography "Hydrography"
la var rail_road  "Roads and Railway (1980)"
la var mean_coffee "Coffe Yield (1961-1990)"
la var mean_cotton "Cotton Yield (1961-1990)"
la var mean_dryrice "Dry Rice Yield (1961-1990)"
la var mean_wetrice "Wet Rice Yield (1961-1990)"
la var mean_bean "Bean Yield (1961-1990)"
la var mean_sugarcane "Sugarcane Yield (1961-1990)"
la var arcsine_nl13 "Arcsine(Night light)"
la var ln_nl13 "Log(Night light)"
la var wmean_nl1 "Night light (Weighted by surfice area)"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"
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
la var total_pop "Total Population"
la var female_head "Female Head Rate"
la var sex_sh "Gender Rate"
la var mean_age "Average Age"
la var had_child_rate  "Fertility Rate"
la var teen_pregnancy_rate "Teen Pregnancy Rate"
la var total_pop_always "Total Population"
la var female_head_always "Female Head Rate"
la var sex_sh_always "Gender Rate"
la var mean_age_always "Average Age"
la var had_child_rate_always "Fertility Rate"
la var teen_pregnancy_rate_always "Teen Pregnancy Rate"
la var total_pop_waralways "Total Population"
la var female_head_waralways "Female Head Rate"
la var sex_sh_waralways "Gender Rate"
la var mean_age_waralways "Average Age"
la var had_child_rate_waralways "Fertility Rate"
la var teen_pregnancy_rate_waralways "Teen Pregnancy Rate"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var literacy_rate_always "Literacy Rate"
la var asiste_rate_always "Attended School Rate"
la var mean_educ_years_always "Years of Education"
la var literacy_rate_waralways "Literacy Rate"
la var asiste_rate_waralways "Attended School Rate"
la var mean_educ_years_waralways "Years of Education"
la var pea_pet "Economically Active Population"
la var po_pet "Working Population"
la var wage_pet "Salaried Population"
la var work_hours "Weekly Worked Hours"
la var public_pet "Public Worker"
la var private_pet "Private Worker"
la var boss_pet "Employer"
la var independent_pet "Independent Worker"
la var pea_pet_always "Economically Active Population"
la var po_pet_always "Working Population"
la var wage_pet_always "Salaried Population"
la var work_hours_always "Weekly Worked Hours"
la var public_pet_always "Public Worker"
la var private_pet_always "Private Worker"
la var boss_pet_always "Employer"
la var independent_pet_always "Independent Worker"
la var pea_pet_waralways "Economically Active Population"
la var po_pet_waralways "Working Population"
la var wage_pet_waralways "Salaried Population"
la var work_hours_waralways "Weekly Worked Hours"
la var public_pet_waralways "Public Worker"
la var private_pet_waralways "Private Worker"
la var boss_pet_waralways "Employer"
la var independent_pet_waralways "Independent Worker"
la var total_pop "Total Population"
la var total_migrant "International Migrants"
la var war_migrant "Total War Migrants"
la var sex_migrant_sh "Migrants' Gender Rate"
la var remittance_rate "Remittances Rate"
la var moving_pop "Moving Population"
la var moving_sh "Moving Population Share"
la var moving_incntry_pop "Moving Population (Internal)"
la var moving_outcntry_pop "Moving Population (International)"
la var arrived_war "In-migration at War Period"
la var dist_coast "Distance to Coast"
la var dist_capital "Distance to Capital"
la var mean_rain "Monthly Mean Rainfall (1961-1979)"
la var max_temp "Monthly Maximum Temperature (1961-1979)"
la var min_temp "Monthly Minimum Temperature (1961-1979)"
la var rugged "Ruggedness"
la var dist_depto "Distance to Department"
la var dist_muni "Distance to Municipality"
la var rain_z "Monthly Mean Rainfall (1975-1979)" 
la var max_temp_z "Monthly Maximum Temperature (1975-1979)" 
la var min_temp_z "Monthly Minimum Temperature (1975-1979)"
la var homicidios "Homicides (2017)"
la var homicidios_gang "Gang homicides (2002-20017)"
la var reform "Land Reform"

 
*Saving the data 
save "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", replace 

