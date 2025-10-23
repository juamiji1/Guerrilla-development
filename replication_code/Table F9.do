/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Collapsing 2007 census to the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 					   Acommodation and Household conditions 
*	
*-------------------------------------------------------------------------------
import excel "${data}/censo2007/Clasificacion_actividad_economica.xlsx", sheet("Sheet1") firstrow clear
destring code, replace
tostring code, replace
replace code= "0"+code if length(code)==3
ren code econactivity_code

encode isic_1, gen(isic1_num)
encode isic_2, gen(isic2_num)

gen isic1_agr=(isic1_num==1)
gen isic1_ind=(isic1_num==2)
gen isic1_serv=(isic1_num==3)

gen isic2_agr=(isic2_num==1)
gen isic2_cons=(isic2_num==2)
gen isic2_man=(isic2_num==3)
gen isic2_mserv=(isic2_num==4)
gen isic2_min=(isic2_num==5)
gen isic2_nmserv=(isic2_num==6)

gen agr_azcf=(econactivity_code=="0111" | econactivity_code=="0113")
gen agr_azcf_v2=(econactivity_code=="0111" | econactivity_code=="0113") if isic1_agr==1

gen man_azcf=(econactivity_code=="1542" | econactivity_code=="1543")
gen man_azcf_v2=(econactivity_code=="1542" | econactivity_code=="1543") if isic1_ind==1

gen serv_azcf=(econactivity_code=="5121")
gen serv_azcf_v2=(econactivity_code=="5121") if isic1_serv==1

tempfile ISIC 
save `ISIC', replace 

use "${data}/censo2007/data/poblacion.dta", clear 

*Keeping head of household only 
keep if S06P01==1

*Has always lived in the same place 
tab S06P08A1 
recode S06P08A1 (2 3=0), gen(always)  

keep DEPID MUNID SEGID VIVID HOGID always S06P03A

tempfile pop
save `pop', replace 

use "${data}/censo2007/data/vivienda.dta", clear 

*Merging household conditions 
merge 1:m DEPID MUNID SEGID VIVID using "${data}/censo2007/data/hogar.dta", keep(2 3) nogen
merge 1:1 DEPID MUNID SEGID VIVID HOGID using `pop', keep(2 3) nogen

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*Wall materials
gen good_wall=(S02P02==1)
gen bad_wall=(S02P02==6 | S02P02==7)

recode S02P02 (4 6 = 2)
tab S02P02, g(wall_)
recode S02P02 (8=.) (2 3 5 6 7 = 0), gen(good_wall2)

*Roof materials
*gen good_roof=(S02P03==1 | S02P03==2)
gen good_roof=(S02P03==1)
gen bad_roof=(S02P02==6 | S02P02==7 )

recode S02P03 (8=.) (2 3 4= 1) (5 6 7 = 0), gen(good_roof2)
tab S02P03, g(roof_)
*recode S02P03 (2 3 4 5 = 1) (6 7 8 = 0), gen(good_roof)

*Floor materials 
recode S02P05 (-2 = .)
*gen good_floor=(S02P03==1 | S02P03==2)
gen good_floor=(S02P03==1)
gen bad_floor=(S02P02==5 | S02P02==6)

recode S02P05 (6 = 5)
tab S02P05, g(floor_)
recode S02P05 (7=.) (2 3 4 = 1) (4 5 = 0), gen(good_floor2)

*Nuumber of households
recode S02P08 (-2 = .)
tab S02P08

*Total of people within the household 
ren POBTOT pobtot

*Sleeping rooms
tab S03P02
recode S03P02 (0=1)

*Members per sleeping room
gen m_p_room =pobtot/S03P02

*Home ownership 
recode S03P04 (2 3 4 = 1) (5 6 7 = 0)

*Sanitary type 
recode S03P05 (2 = 1) (4 = 3)
tab S03P05, g(sanitary_)

*Exclusive sanitary service 
recode S03P06 (-2 = .) (2 = 0) 

*Dirty water disposal 
tab S03P07, g(dirty_water_)

*Type of water access 
recode S03P08 (2 3 = 1) (6 = 5) (9 = 8)
tab S03P08, g(water_type_)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Cook fuel 
gen electric_cook=(S03P10==1)
recode S03P10 (4 5 6 7 = 8)
tab S03P10, g(fuel_cook_)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Garbage disposal 
recode S03P12 (2 = 1) (3 4 5 6 7 8 = 0)

*Assets characteristics 
recode S03P13A - S03P13M  (-1 -2 = .) (2=0)
gen car_bike= (S03P13J==1 | S03P13K==1)

*Farming or livestock  activity 
recode S03P15A S03P15B (-1 -2 = .) (2=0)

*Land of activity 
recode S03P16 (2 3 = 0)

*Urban area 
ren AREAID urban 
recode urban (2 = 0)

*Total households
gen total_household=1
gen total_household_survey=1 if S06P03A>29 & S06P03A<71

*Sanitary service 
recode S03P05 (2 3 4 5 = 0)

*Sewerage service 
recode S03P07 (2 3 4 5 6 =0)

*Water pipes 
recode S03P08 (2 3 = 1) (4 5 6 7 8 9 10 = 0)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Creating the wealth index 
gl wealthindex "wall_* roof_* floor_* pobtot m_p_room S03P04 sanitary_* S03P06 dirty_water_* water_type_* fuel_cook_* S03P11 S03P12 S03P13A - S03P13M S03P15A S03P15B S03P16 urban"
factor ${wealthindex}, pcf factors(1)
predict z_wi

*-------------------------------------------------------------------------------
*REGRESSION AT THE HH LEVEL
*-------------------------------------------------------------------------------
merge m:1 segm_id using "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", keep(1 3) keepus(control_break_fe_400 within_control z_run_cntrl) gen(wmerge)

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl h= 2.271
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

la var z_wi "Wealth Index"

*Erasing table before exporting
cap erase "${tables}/rdd_main_all_ind.tex"
cap erase "${tables}/rdd_main_all_ind.txt"
cap erase "${tables}/rdd_main_all_ind_cl.tex"
cap erase "${tables}/rdd_main_all_ind_cl.txt"

*Table with robusts SE
reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
summ z_wi if e(sample)==1 & within_control==0, d
gl mean_y=round(r(mean), .01)

outreg2 using "${tables}/rdd_main_all_ind.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

*Table with robusts clustered SE
reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(cl segm_id) a(i.${breakfe})
summ z_wi if e(sample)==1 & within_control==0, d
gl mean_y=round(r(mean), .01)

outreg2 using "${tables}/rdd_main_all_ind_cl.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 


*-------------------------------------------------------------------------------
* 					     		Population 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007/data/poblacion.dta", clear 

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*Sex
tab S06P02
recode S06P02 (2=0)
gen female=1 if S06P02==0 
gen male=1 if S06P02==1

*Female head of household
gen female_head=1 if (female==1 & S06P01==1)
replace female_head=0 if (male==1 & S06P01==1)

*Mother in the same segment 
tab S06P07A 
recode S06P07A (2 3=0), gen(mother_same)  

*Has always lived in the same place 
tab S06P08A1 
recode S06P08A1 (2 3=0), gen(always)  

gen moving_pop=(always==1)
gen moving_incntry_pop=(S06P08A1==2)
gen moving_outcntry_pop=(S06P08A1==3)

recode S06P08A2 (-1 -2=.)  
gen arrived_war=(S06P08A2>1978 & S06P08A2<1993)

*Arrival year 
recode S06P08A2 (-2 -1 = .)
gen year_arrive = 2007 - S06P08A2 

*Age
tab S06P03A, m
gen age_range=1 if S06P03A<15
replace age_range=2 if S06P03A>=15 & S06P03A<30 
replace age_range=3 if S06P03A>=30 & S06P03A<45 
replace age_range=4 if S06P03A>=45 & S06P03A<60 
replace age_range=5 if S06P03A>=60

gen ager=1 if S06P03A>=16 & S06P03A<20
replace ager=2 if S06P03A>=20 & S06P03A<25
replace ager=3 if S06P03A>=25 & S06P03A<30
replace ager=4 if S06P03A>=30 & S06P03A<35
replace ager=5 if S06P03A>=35 & S06P03A<40
replace ager=6 if S06P03A>=40 & S06P03A<45
replace ager=7 if S06P03A>=45 & S06P03A<50
replace ager=8 if S06P03A>=50 & S06P03A<55
replace ager=9 if S06P03A>=55 & S06P03A<60
replace ager=10 if S06P03A>=60 & S06P03A<65
replace ager=11 if S06P03A>=65 & S06P03A<70
replace ager=12 if S06P03A>=70  

*Lived the war 
gen age_war=1 if S06P03A>=27

gen age_war_range=1 if S06P03A>=27 & S06P03A<43 
replace age_war_range=2 if S06P03A>=43 & S06P03A<59 
*replace age_war_range=3 if S06P03A>=59 

*School age at war time
gen schl_age_war=1 if S06P03A>=21 & S06P03A<42    // 21 to 41 years old ie born between 1966-1986
gen notschl_age_war=1 if S06P03A>=42			  // +42 born before 1966
gen schl_age_today=1 if S06P03A>=15 & S06P03A<21			  // Born after 1992 but finished educ 

*Literacy 
tab S06P09
recode S06P09 (-2=.) (2=0) 
gen litrate_all=S06P09
replace S06P09=. if S06P03A<18

*Assit to a formal educational center 
tab S06P10
recode S06P10 (-2=.) 

gen asiste=(S06P10<3) if S06P10!=.
replace asiste=. if S06P03A<18

tab asiste S06P10, m

*Years of education
tab S06P11A

gen educ_yrs_v2=S06P11A
replace S06P11A=. if S06P03A<18

*Highest grade approved
tab S06P11A1
recode S06P11A1 (-2=.)

tab S06P11A1 S06P10, m

*High educated
gen high_educ=(S06P11A1 > 2) if S06P11A1!=. 

ren S06P11A mean_educ_years

*-------------------------------------------------------------------------------
*REGRESSION AT THE INDIVIDUAL LEVEL
*-------------------------------------------------------------------------------
merge m:1 segm_id using "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", keep(1 3) keepus(control_break_fe_400 within_control z_run_cntrl) gen(wmerge)

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl h= 2.271
gl if "if abs(z_run_cntrl)<=${h}"

la var mean_educ_years "Years of Education"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Table with robusts SE
reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
summ mean_educ_years if e(sample)==1 & within_control==0, d
gl mean_y=round(r(mean), .01)

outreg2 using "${tables}/rdd_main_all_ind.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

*Table with robusts clustered SE
reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(cl segm_id) a(i.${breakfe})
summ mean_educ_years if e(sample)==1 & within_control==0, d
gl mean_y=round(r(mean), .01)

outreg2 using "${tables}/rdd_main_all_ind_cl.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 


clear all 

*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl h= 2.271 // This is a mistake but it was like this in the code...

gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"
la var z_wi_iqr "Wealth Index Range (p75-p25)"
la var z_wi_iqr2 "Wealth Index Range (p95-p5)"
la var z_wi_iqr3 "Wealth Index Range (p90-p10)"
la var z_wi_p50 "Median Wealth Index"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl1 "z_wi mean_educ_years"

*Erasing table before exporting
cap erase "${tables}/rdd_main_all_nweights.tex"
cap erase "${tables}/rdd_main_all_nweights.txt"

foreach var of global nl1{
	
	cap drop ntweights
	gen ntweights=n_`var' * tweights

	*Table
	reghdfe `var' ${controls} [aw=ntweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/rdd_main_all_nweights.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}











*END
