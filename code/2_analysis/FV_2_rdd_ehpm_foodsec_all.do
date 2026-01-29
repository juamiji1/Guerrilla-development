/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Education years by cohorts (EHPM data)
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Preparing the data 
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*EHPM 2011
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm11.csv", clear stringcols(_all)

keep r105a r106 r201a r201b r202a r203 r204 r205 r215 r217a r217b munic depto segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r205 r215 r217a r217b, replace force 

*Fixing code of segmento 
replace depto="0"+depto if length(depto)==1
replace munic="0"+munic if length(munic)==1
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=depto+munic+segmento

*Creating the years of education var
gen educ_yrs=r205 if r204==1
replace educ_yrs=r205+3 if r204==2 | r204==3
replace educ_yrs=r205+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r217a if r217b==1 & educ_yrs==.
replace educ_yrs=r217a+3 if (r217b==2 | r217b==3) & educ_yrs==.
replace educ_yrs=r217a+14 if r217b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r215==2 | educ_yrs==.

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2011 

tempfile EHPM11
save `EHPM11', replace 

*-------------------------------------------------------------------------------
*EHPM 2012
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm12.csv", clear stringcols(_all)

keep r105a r106 r201a r201b r202a r203 r204 r205 r215 r217a r217b codigomunic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r205 r215 r217a r217b, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r205 if r204==1
replace educ_yrs=r205+3 if r204==2 | r204==3
replace educ_yrs=r205+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r217a if r217b==1 & educ_yrs==.
replace educ_yrs=r217a+3 if (r217b==2 | r217b==3) & educ_yrs==.
replace educ_yrs=r217a+14 if r217b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r215==2 | educ_yrs==.

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2012

tempfile EHPM12
save `EHPM12', replace 

*-------------------------------------------------------------------------------
*EHPM 2013
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm13.csv", clear stringcols(_all)

keep r105a r106 r201a r201b r202a r203 r204 r205 r215 r217a r217b codigomunic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r205 r215 r217a r217b, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r205 if r204==1
replace educ_yrs=r205+3 if r204==2 | r204==3
replace educ_yrs=r205+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r217a if r217b==1 & educ_yrs==.
replace educ_yrs=r217a+3 if (r217b==2 | r217b==3) & educ_yrs==.
replace educ_yrs=r217a+14 if r217b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r215==2 | educ_yrs==.

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2013

tempfile EHPM13
save `EHPM13', replace 

*-------------------------------------------------------------------------------
*EHPM 2014
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm14.csv", clear stringcols(_all)

keep r105a r106 r201a r201b r202a r203 r204 r205 r215 r217a r217b munic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r205 r215 r217a r217b, replace force 

*Fixing code of segmento 
replace munic="0"+munic if length(munic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=munic+segmento

*Creating the years of education var
gen educ_yrs=r205 if r204==1
replace educ_yrs=r205+3 if r204==2 | r204==3
replace educ_yrs=r205+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r217a if r217b==1 & educ_yrs==.
replace educ_yrs=r217a+3 if (r217b==2 | r217b==3) & educ_yrs==.
replace educ_yrs=r217a+14 if r217b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r215==2 | educ_yrs==.

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2014

tempfile EHPM14
save `EHPM14', replace


/*
*-------------------------------------------------------------------------------
*EHPM 2015
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm15.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r205 r215 r217a r217b codigomunic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r205 r215 r217a r217b, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r205 if r204==1
replace educ_yrs=r205+3 if r204==2 | r204==3
replace educ_yrs=r205+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r217a if r217b==1 & educ_yrs==.
replace educ_yrs=r217a+3 if (r217b==2 | r217b==3) & educ_yrs==.
replace educ_yrs=r217a+14 if r217b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r215==2 | educ_yrs==.

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2015

tempfile EHPM15
save `EHPM15', replace 
*/

*-------------------------------------------------------------------------------
*EHPM 2016
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm16.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento r1101-r1115

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b r1101-r1115, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r204g if r204==1
replace educ_yrs=r204g+3 if r204==2 | r204==3
replace educ_yrs=r204g+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r215a if r215b==1 & educ_yrs==.
replace educ_yrs=r215a+3 if (r215b==2 | r215b==3) & educ_yrs==.
replace educ_yrs=r215a+14 if r215b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r213==2 | educ_yrs==.

*Food insecurity vars
recode r1101-r1115 (2=0)
egen x=rowtotal(r1101-r1115), m
gen food_insec_all=(x>0) if x!=.

egen y=rowtotal(r1109-r1115), m
gen food_insec_kids=(y>0) if x!=.

drop x y

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2016

tempfile EHPM16
save `EHPM16', replace 

*-------------------------------------------------------------------------------
*EHPM 2017
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm17.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento r1101-r1115

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b r1101-r1115, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r204g if r204==1
replace educ_yrs=r204g+3 if r204==2 | r204==3
replace educ_yrs=r204g+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r215a if r215b==1 & educ_yrs==.
replace educ_yrs=r215a+3 if (r215b==2 | r215b==3) & educ_yrs==.
replace educ_yrs=r215a+14 if r215b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r213==2 | educ_yrs==.

*Food insecurity vars
recode r1101-r1115 (2=0)
egen x=rowtotal(r1101-r1115), m
gen food_insec_all=(x>0) if x!=.

egen y=rowtotal(r1109-r1115), m
gen food_insec_kids=(y>0) if x!=.

drop x y

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2017

tempfile EHPM17
save `EHPM17', replace 

*-------------------------------------------------------------------------------
*EHPM 2018
*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\ehpm\ehpm18.csv", clear stringcols(_all)

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento r1101-r1115

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b r1101-r1115, replace force 

*Fixing code of segmento 
replace codigomunic="0"+codigomunic if length(codigomunic)==3
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id=codigomunic+segmento

*Creating the years of education var
gen educ_yrs=r204g if r204==1
replace educ_yrs=r204g+3 if r204==2 | r204==3
replace educ_yrs=r204g+14 if r204>=4    					// <- CHECK THIS PART!!!! specially niveles annos? o especiales?
replace educ_yrs=r215a if r215b==1 & educ_yrs==.
replace educ_yrs=r215a+3 if (r215b==2 | r215b==3) & educ_yrs==.
replace educ_yrs=r215a+14 if r215b>=4 & educ_yrs==.			   // <- CHECK THIS PART!!!! specially niveles annos? o especiales?

replace educ_yrs=0 if r201a==1 | r213==2 | educ_yrs==.

*Food insecurity vars
recode r1101-r1115 (2=0)
egen x=rowtotal(r1101-r1115), m
gen food_insec_all=(x>0) if x!=.

egen y=rowtotal(r1109-r1115), m
gen food_insec_kids=(y>0) if x!=.

drop x y

*Renaming vars
ren (r105a r106) (birth_yr age_yr)

*Year 
gen year=2018 

tempfile EHPM18
save `EHPM18', replace 

*-------------------------------------------------------------------------------
*Appending all data sets
*-------------------------------------------------------------------------------
use `EHPM11', clear 
append using `EHPM12' `EHPM13' `EHPM14' `EHPM16' `EHPM17' `EHPM18'
*`EHPM15'

*School age at war time
gen schl_age_war=1 if birth_yr<=1986 & birth_yr>1966 	   	// 21 to 41 years old ie born between 1966-1986
gen notschl_age_war=1 if birth_yr<=1966 				  		// +42 born before 1966
gen schl_age_today=1 if birth_yr>1986 & birth_yr<=1995 & year==2011 	              		// Born after 1992 but finished educ 
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=1996 & year==2012
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=1997 & year==2013
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=1998 & year==2014
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=1999 & year==2015
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=2000 & year==2016
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=2001 & year==2017
replace schl_age_today=1 if birth_yr>1986 & birth_yr<=2002 & year==2018

*Calculating educ years for each group 
preserve
	keep if schl_age_war==1
	collapse (mean) educ_years_wsage_ehpm=educ_yrs, by(segm_id)
	
	tempfile WSAGE
	save `WSAGE'
restore

preserve
	keep if notschl_age_war==1
	collapse (mean) educ_years_wnsage_ehpm=educ_yrs, by(segm_id)
	
	tempfile WNSAGE
	save `WNSAGE'
restore

*Food security
preserve
	collapse (mean) food_insec_all food_insec_kids, by(segm_id)
	
	tempfile FOODSEC
	save `FOODSEC'
restore


keep if schl_age_today==1
collapse (mean) educ_years_tsage_ehpm=educ_yrs , by(segm_id)

merge 1:1 segm_id using `WSAGE', nogen
merge 1:1 segm_id using `WNSAGE', nogen 
merge 1:1 segm_id using `FOODSEC', nogen 

*Saving the file 
tempfile EDUC_EHPM
save `EDUC_EHPM', replace

*-------------------------------------------------------------------------------
* Fixing shocks
*-------------------------------------------------------------------------------
use "${data}/shocks\monthly_Panel_SLV_Segments_1980_2025.dta", clear
keep if year>2015

gen d_ztemp_1sd=(abs(temp_std)>=1) if temp_std!=.
gen d_ztemp_2sd=(abs(temp_std)>=2) if temp_std!=.
gen d_zprecip_1sd=(abs(precip_std)>=1) if precip_std!=.
gen d_zprecip_2sd=(abs(precip_std)>=2) if precip_std!=.

collapse (sum) d_z* (mean) hist_temp_mean_all hist_temp_sd_all hist_precip_mean_all hist_precip_sd_all predict_modis_temp predict_chirps_precip temp_std precip_std, by(seg_id)

gen ztemp=(predict_modis_temp-hist_temp_mean_all)/hist_temp_sd_all
gen zprecip=(predict_chirps_precip-hist_precip_mean_all)/hist_precip_sd_all

tostring seg_id, g(segm_id)
replace segm_id="0"+segm_id if length(segm_id)==7

tempfile SHOCKS
save `SHOCKS', replace


*-------------------------------------------------------------------------------
* RDD results
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Merging data
drop _merge
merge 1:1 segm_id using `EDUC_EHPM', keep(1 3) nogen
merge 1:1 segm_id using `SHOCKS', keep(1 3) nogen

*Creating interactions
gen d_mean_ztemp_1sd=(abs(temp_std)>=1) if temp_std!=.
gen d_mean_ztemp_2sd=(abs(temp_std)>=1.5) if temp_std!=.

gen d_mean_zprecip_1sd=(abs(precip_std)>=.5) if precip_std!=.
gen d_mean_zprecip_2sd=(abs(precip_std)>=1) if precip_std!=.

gen wc_ztemp =within_control*temp_std
gen wc_zprecip =within_control*precip_std
gen wc_dztemp1sd =within_control*d_ztemp_1sd
gen wc_dzprecip1sd =within_control*d_zprecip_1sd
gen wc_dztemp2sd =within_control*d_ztemp_2sd
gen wc_dzprecip2sd =within_control*d_zprecip_2sd

gen wc_dmztemp1sd =within_control*d_mean_ztemp_1sd
gen wc_dmzprecip1sd =within_control*d_mean_zprecip_1sd
gen wc_dmztemp2sd =within_control*d_mean_ztemp_2sd
gen wc_dmzprecip2sd =within_control*d_mean_zprecip_2sd

summ d_zprecip_1sd, d
gen d_highprecip1sd=(d_zprecip_1sd>=`r(p50)')
summ d_zprecip_2sd, d
gen d_highprecip2sd=(d_zprecip_2sd>=`r(p50)')

summ d_ztemp_1sd, d
gen d_hightemp1sd=(d_ztemp_1sd>=`r(p50)')
summ d_zprecip_2sd, d
gen d_hightemp2sd=(d_ztemp_2sd>=`r(p50)')

gen wc_highprecip1sd=within_control*d_highprecip1sd
gen wc_highprecip2sd=within_control*d_highprecip2sd
gen wc_hightemp1sd=within_control*d_hightemp1sd
gen wc_hightemp2sd=within_control*d_hightemp2sd

*Variable labels 
label var within_control "Control"
label var wc_ztemp "Control $\times$ Temperature (Z-score)"
label var wc_dmztemp1sd "Control $\times$ $\lvert Z\text{-Temp} \rvert \geq 1$ SD"
label var wc_dmztemp2sd "Control $\times$ $\lvert Z\text{-Temp} \rvert \geq 2$ SD"
label var wc_dztemp1sd "Control $\times$ Months with $\lvert Z\text{-Temp} \rvert \geq 1$ SD"
label var wc_dztemp2sd "Control $\times$ Months with $\lvert Z\text{-Temp} \rvert \geq 2$ SD"
label var wc_zprecip "Control $\times$ Precipitation (Z-score)"
label var wc_dmzprecip1sd "Control $\times$ $\lvert Z\text{-Precip} \rvert \geq 1$ SD"
label var wc_dmzprecip2sd "Control $\times$ $\lvert Z\text{-Precip} \rvert \geq 2$ SD"
label var wc_dzprecip1sd "Control $\times$ Months with $\lvert Z\text{-Precip} \rvert \geq 1$ SD"
label var wc_dzprecip2sd "Control $\times$ Months with $\lvert Z\text{-Precip} \rvert \geq 2$ SD"
label var wc_hightemp1sd "Control $\times$ High Temp Shock (1SD)"
label var wc_hightemp2sd "Control $\times$ High Temp Shock (2SD)"
label var wc_highprecip1sd "Control $\times$ High Precip Shock (1SD)"
label var wc_highprecip2sd "Control $\times$ High Precip Shock (2SD)"

END

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

*Food security outcomes 
gl foodsecoutcomes "food_insec_all food_insec_kids"

local i=1
foreach yvar of global foodsecoutcomes {
	
	*Base Estimation
	reghdfe `yvar' ${controls} wc_ztemp temp_std [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_ztemp
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo a`i'
	
	reghdfe `yvar' ${controls} wc_dmztemp1sd d_mean_ztemp_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmztemp1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo b`i'
	
	reghdfe `yvar' ${controls} wc_dmztemp2sd d_mean_ztemp_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmztemp2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo c`i'
	
	reghdfe `yvar' ${controls} wc_dztemp1sd d_ztemp_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dztemp1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo d`i'
	
	reghdfe `yvar' ${controls} wc_dztemp2sd d_ztemp_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dztemp2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo e`i'
	
	
	reghdfe `yvar' ${controls} wc_zprecip precip_std [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_zprecip
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo f`i'
	
	reghdfe `yvar' ${controls} wc_dmzprecip1sd d_mean_zprecip_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmzprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo g`i'
	
	reghdfe `yvar' ${controls} wc_dmzprecip2sd d_mean_zprecip_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dmzprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo h`i'
	
	reghdfe `yvar' ${controls} wc_dzprecip1sd d_zprecip_1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dzprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo i`i'
	
	reghdfe `yvar' ${controls} wc_dzprecip2sd d_zprecip_2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_dzprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo j`i'
	
	reghdfe `yvar' ${controls} wc_hightemp1sd d_hightemp1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_hightemp1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo k`i'
	
	reghdfe `yvar' ${controls} wc_hightemp2sd d_hightemp2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_hightemp2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo l`i'
	
	reghdfe `yvar' ${controls} wc_highprecip1sd d_highprecip1sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip1sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo m`i'
	
	reghdfe `yvar' ${controls} wc_highprecip2sd d_highprecip2sd [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	lincom within_control+ wc_highprecip2sd
	estadd scalar L    = r(estimate)
	estadd scalar L_p  = r(p)
	eststo n`i'
	
	local ++i
}

*Exporting results 
esttab a1 b1 c1 d1 e1 k1 l1 a2 b2 c2 d2 e2 k2 l2 using "${tables}/rdd_main_all_foodsec_temp.tex", ///
    keep(within_control wc_ztemp wc_dmztemp1sd wc_dmztemp2sd wc_dztemp1sd wc_dztemp2sd wc_hightemp1sd wc_hightemp2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{14}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & food_insec_all & food_insec_all & food_insec_all  & food_insec_all & food_insec_all & food_insec_all & food_insec_all & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) & (11) & (12) & (13) & (14) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
             `"\bottomrule \end{tabular}"')

esttab f1 g1 h1 i1 j1 m1 n1 f2 g2 h2 i2 j2 m2 n2 using "${tables}/rdd_main_all_foodsec_precip.tex", ///
	keep(within_control wc_zprecip wc_dmzprecip1sd wc_dmzprecip2sd wc_dzprecip1sd wc_dzprecip2sd wc_highprecip1sd wc_highprecip2sd) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    stats(L L_p N, ///
          labels("Combined estimate" "p-value (lincom)" "Observations") ///
          fmt(3 3 0)) ///
    prehead(`"\begin{tabular}{@{}l*{14}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `" & food_insec_all & food_insec_all & food_insec_all  & food_insec_all & food_insec_all & food_insec_all & food_insec_all & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids & food_insec_kids\\"' ///
            `"\ & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) & (11) & (12) & (13) & (14) \\"' ///
            `" \toprule"') ///
    postfoot(`" \toprule"' ///
             `" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
             `"\bottomrule \end{tabular}"')
		











