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

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b, replace force 

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

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b, replace force 

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

keep r105a r106 r201a r202a r203 r204 r204g r205 r213 r215a r215b codigomunic segmento

*Destring of vars 
destring r105a r106 r201a r202 r203 r204 r204g r205 r213 r215a r215b, replace force 

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
append using `EHPM12' `EHPM13' `EHPM14' `EHPM16' `EHPM17'  
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

keep if schl_age_today==1
collapse (mean) educ_years_tsage_ehpm=educ_yrs, by(segm_id)

merge 1:1 segm_id using `WSAGE', nogen
merge 1:1 segm_id using `WNSAGE', nogen 

*Saving the file 
tempfile EDUC_EHPM
save `EDUC_EHPM'

*-------------------------------------------------------------------------------
* RDD results
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Merging data
drop _merge
merge 1:1 segm_id using `EDUC_EHPM', keep(1 3) nogen

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=3.7
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Global of outcomes 
gl educ "educ_years_wsage_ehpm educ_years_wnsage_ehpm educ_years_tsage_ehpm"

la var educ_years_wsage_ehpm "School age at war"
la var educ_years_wnsage_ehpm "Non-school age at war"
la var educ_years_tsage_ehpm "School age after war"

*Erasing table before exporting
cap erase "${tables}\rdd_educ_ephm.tex"
cap erase "${tables}\rdd_educ_ephm.txt"

*Tables
foreach var of global educ{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_educ_ephm.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}




*END