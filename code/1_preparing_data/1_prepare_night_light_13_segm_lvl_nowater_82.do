/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Preparing night light dat at the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/gis\maps_interim\slvShp_segm_nowater_info_sp_82", data("${data}/temp\slvShp_segm_nowater_info_sp_82.dta") coord("${data}/temp\slvShp_segm_nowater_info_sp_82_coord.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_segm_nowater_info_sp_82.dta", clear

*Keeping only important vars 
rename (SEG_I wthn_cn dst_cnt nl elev elev2 rugged wmen_nl cocoa coffee cotton drice maize bean sugarcn wrice sm_dhyd sm_kmhy rain maxtemp mintemp rainz maxtmpz mintmpz dst_cn2 wthn_c2 lake_nt riv1_nt riv2_nt rail_nt road_nt dst_cst dst_cpt dst_dpt dist_mn n_hosp n_sch matricl n_parr n_pa80 n_fran n_hmcds n_hmcd_ rd14_nt len_rod rod_dns cmms45_ dst_p80 dst_cmm ln_cmms cmms_dn dst_c45 n_cts45 bean79 coffe79 cottn79 maize79 rice79 sgrcn79 hghppdn cultvtd pop_w grown_w mxppdns maxpp_w cn_1000 cnt1000 cnt_400 cntr400) (segm_id within_control dist_control nl13_density elevation elevation2 rugged wmean_nl1 mean_cocoa mean_coffee mean_cotton mean_dryrice mean_maize mean_bean mean_sugarcane mean_wetrice sum_dhydro sum_kmhydro mean_rain max_temp min_temp rain_z max_temp_z min_temp_z dist_control_v2 within_control_v2 lake river1 river2 rail road dist_coast dist_capital dist_depto dist_muni total_hospitals total_schools total_matricula parroquias parr80 franciscanas homicidios homicidios_gang road14 length_road14 road14_dens comms45 dist_parr80 dist_comms45 length_comms45 comms45_dens dist_city45 city45 bean79 coffee79 cotton79 maize79 rice79 sugarcane79 high_pop80 v high_pop80_swithin grown80_swithin max_pop80 max_pop80_swithin dist_control_breaks_1000 control_break_fe_1000 dist_control_breaks_400 control_break_fe_400)

*Canton ID
gen canton_id=COD_D+COD_M+COD_C
destring canton_id, replace 

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
replace total_matricula=0 if total_matricula==.

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_control_v2=dist_control_v2/1000

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

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)

*Fixing the running variables (version 2)
gen z_run_cntrl_v2= dist_control_v2 
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 				//The rdrobust command is coded to indicate treated=(z>=0).

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

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

*Merging the lapop 
merge 1:1 segm_id using "${data}/temp\lapop_segm_lvl.dta", keep(1 3) nogen 

*Merging land reform and canton 
merge 1:1 segm_id using "${data}/gis\land_reform\census_segm_land_reform.dta", keep(1 3) nogen 

replace reform=0 if reform==.


*-------------------------------------------------------------------------------
* 							Labelling vars
*
*-------------------------------------------------------------------------------
la var nl13_density "Night light density (2013)"
la var z_run_cntrl "Distance to nearest controlled area"
*la var z_run_dsptd "Distance to nearest disputed zone (border to border)"
la var z_run_cntrl_v2 "Distance to nearest control zone (centroid to border)"
*la var z_run_dsptd_v2 "Distance to nearest disputed zone (centroid to border)"
*la var within_control "Pixel within control zone (intersection)"
la var within_control_v2 "Pixel within control zone (intersection)"
*la var within_disputed_v2 "Pixel within disputed zone (intersection)"
*la var within_fmln "Within any FMLN zone"
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
save "${data}/night_light_13_segm_lvl_82_nowater.dta", replace 




*END



