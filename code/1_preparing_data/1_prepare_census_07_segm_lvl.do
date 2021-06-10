/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Collapsing 2007 census to the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

/*gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development"
gl path "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

*Setting the working directory 
cd ${data}

*Setting a pre-scheme for plots
set scheme s2color, perm 
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray
*/


*-------------------------------------------------------------------------------
* 					     	Acommodation and Household conditions 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007\data\vivienda.dta", clear 

*Merging household conditions 
merge 1:m DEPID MUNID SEGID VIVID using "${data}/censo2007\data\hogar.dta", keep(2 3)

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*Wall materials
recode S02P02 (4 6 = 2)
tab S02P02, g(wall_)

*Roof materials
tab S02P03, g(roof_)

*Floor materials 
recode S02P05 (6 = 5)
tab S02P05, g(floor_)

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
recode S03P06 (1 = 0) 

*Dirty water disposal 
tab S03P07, g(dirty_water_)

*Type of water access 
recode S03P08 (2 3 = 1) (6 = 5) (9 = 8)
tab S03P08, g(water_type_)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Cook fuel 
recode S03P10 (4 5 6 7 = 8)
tab S03P10, g(fuel_cook_)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Garbage disposal 
recode S03P12 (2 = 1) (3 4 5 6 7 8 = 0)

*Assets characteristics 
recode S03P13A - S03P13M  (-1 -2 = .) (2=0)

*Farming or livestock  activity 
recode S03P15A S03P15B (-1 -2 = .) (2=0)

*Land of activity 
recode S03P16 (2 3 = 0)

*Urban area 
ren AREAID urban 
recode urban (2 = 0)

*Total households
gen total_household=1

*Sanitary service 
recode S03P05 (2 3 4 = 1) (5 = 0)

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

*Collapsing at the segment level 
collapse (mean) owner_sh=S03P04 sanitary_sh=S03P05 sewerage_sh=S03P07 pipes_sh=S03P08 daily_water_sh=S03P09 electricity_sh=S03P11 garbage_sh=S03P12 z_wi (sum) total_household, by(segm_id)

tempfile Household
save `Household', replace 


*-------------------------------------------------------------------------------
* 					     		Mortality 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007\data\mortalidad.dta", clear 

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*Age of deceased
tab S05AC02
recode S05AC02 (-1=.)

*Sex of deceased 
tab S05AC03
recode S05AC03 (-1=.) (2=0)
gen female_dead=1 if S05AC03==0 
gen male_dead=1 if S05AC03==1

*Cause of decease
tab S05AC04
recode S05AC04 (-2 -1=.)
tab S05AC04, g(causa)

*Total of deceased
gen total_dead=1

*Collapsing at the segment level 
collapse (mean) age_dead=S05AC02 sex_dead_sh=S05AC03 (sum) female_dead male_dead total_dead pregnant_dead=causa1 birth_dead=causa2 after_birth_dead=causa3 other_dead=causa4, by(segm_id)

tempfile Mortality
save `Mortality', replace 


*-------------------------------------------------------------------------------
* 					     		Migration 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007\data\migracion.dta", clear 

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*Sex of migrant 
tab S05BC02
recode S05BC02 (-1=.) (2=0)
gen female_migrant=1 if S05BC02==0 
gen male_migrant=1 if S05BC02==1

*Age of migrant 
tab S05BC03
recode S05BC03 (-1=.)

*Country of destination (we need the country codes)
tab S05BC04

*Year of migration 
tab S05BC05
recode S05BC05 (-1=.)

*War migrant 
gen war_migrant=1 if S05BC05>1978 & S05BC05<1993

*Total of migrants 
gen total_migrant=1

*Collapsing at the segment-year level 
preserve 
	collapse (sum) female_migrant male_migrant total_migrant, by(S05BC05)
	
	*Plot showing temporal migration patterns 
	two (line total_migrant S05BC05, legend(label(1 "Total"))) (line female_migrant S05BC05, legend(label(2 "Female"))) (line male_migrant S05BC05, legend(label(3 "Male"))), ytitle(Total) xtitle(Year) xlabel(1920(5)2007, angle(45) labsize(small)) legend(c(3))
restore 

*Collapsing at the segment level 
collapse (mean) sex_migrant_sh=S05BC02 age_migrant=S05BC03 (sum) female_migrant male_migrant war_migrant total_migrant, by(segm_id)

tempfile Migration
save `Migration', replace 


*-------------------------------------------------------------------------------
* 					     		Population 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007\data\poblacion.dta", clear 

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

*Has always lived in the same place 
tab S06P08A1 
recode S06P08A1 (2 3=0), gen(always)  

gen moving_pop=(always==1)
gen moving_incntry_pop=(S06P08A1==2)
gen moving_outcntry_pop=(S06P08A1==3)

recode S06P08A2 (-1 -2=.)  
gen arrived_war=1 if S06P08A2>=1979 & S06P08A2<1991 

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

*Literacy 
tab S06P09
recode S06P09 (-2=.) (2=0) 
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

*Marital status 
tab S06P13
recode S06P13 (-2 -1=.)

gen married_mu=(S06P13<3) if S06P13!=.

tab married_mu S06P13, m

*Received remittances 
tab S06P15A
recode S06P15A (-2=.) (2=0)

*Poblacion en edad de trabajar (PET) 
gen pet=(S06P03A>15) 

*Poblacion ocupada
tab S06P16A
recode S06P16A S06P16B (-2=.) (2=0)
recode S06P16C (-2=.)

gen po=1 if (S06P16A==1 | S06P16B==1 | S06P16C<7) & pet==1

*Poblacion desocupada 
recode S06P17 S06P18 (-2=.) (2=0)

gen pd=1 if (S06P17==1 | S06P18==1) & pet==1

*Poblacion economicamente activa (PEA)
gen pea=1 if (po==1 | pd==1) & pet==1 
replace pea=0 if po==0 & pd==0 & pet==1

*Poblacion economicamente inactiva (NEA)
recode S06P19 (-2=.)
gen nea=1 if S06P19!=.

*Weekly working hours 
tab S06P23
recode S06P23 (-2=.)

*Wage workers
gen wage=1 if (S06P16A==1 | S06P16B==1) & pet==1

*Non salaried workers 
gen nowage=1 if S06P16C<7 & pet==1

*Type of worker
recode S06P22 (-2=.)
gen public=1 if S06P16A==1 & S06P22==1
gen private=1 if S06P16A==1 & S06P22==2
gen boss=1 if S06P16A==1 & S06P22==3
gen independent=1 if S06P16A==1 & S06P22==6

*Having a son or daughter 
tab S06P25
recode S06P25 (-2=.) (2=0)		

*Teen pregnancy 
gen teen_pregnancy=S06P25  
replace teen_pregnancy=. if S06P03A>19

tab S06P25 teen_pregnancy, m
tab S06P03A teen_pregnancy, m

*Total population 
gen total_pop=1

*Data at the gender level 
preserve

	*Collapsing at the segment gender level 
	collapse (mean) literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A remittance_rate=S06P15A work_hours=S06P23 (sum) pet po pd pea nea wage nowage public private boss independent, by(segm_id S06P02)

	*Tasa de desempleo 
	gen td=pd/pea 
	
	*Normalizing the active and employed population over pet
	gen po_pet=po/pet
	gen pea_pet=pea/pet
	gen wage_pet=wage/pet
	gen public_pet=public/pet
	gen private_pet=private/pet
	gen boss_pet=boss/pet
	gen independent_pet=independent/pet
		
	*Reshaping to leave the segment as unique identifier 
	reshape wide literacy_rate asiste_rate mean_educ_years remittance_rate pet po pd pea nea td wage nowage public private boss independent po_pet pea_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet, i(segm_id) j(S06P02)

	*Renaming vars
	ren *0 *_f
	ren *1 *_m

	*Saving the data 
	tempfile Gender
	save `Gender', replace 

restore 

*Data at the age range level 
preserve

	*Collapsing at the segment age range level 
	collapse (mean) literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A work_hours=S06P23 (sum) pet po pd pea nea wage nowage total_pop public private boss independent, by(segm_id age_range)

	*Tasa de desempleo 
	gen td=pd/pea 
	
	*Normalizing the active and employed population over pet
	gen po_pet=po/pet
	gen pea_pet=pea/pet
	gen wage_pet=wage/pet 
	gen public_pet=public/pet
	gen private_pet=private/pet
	gen boss_pet=boss/pet
	gen independent_pet=independent/pet
	
	*Reshaping to leave the segment as unique identifier 
	reshape wide literacy_rate asiste_rate mean_educ_years pet po pd pea nea td wage nowage public private boss independent total_pop po_pet pea_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet, i(segm_id) j(age_range)
	
	*Renaming vars
	ren *1 *_0_14_yrs
	ren *2 *_15_29_yrs
	ren *3 *_30_44_yrs
	ren *4 *_45_59_yrs
	ren *5 *_60_more_yrs
	
	*Saving the data 
	tempfile Age
	save `Age', replace 	

restore 

preserve

	*Keeping only population that never left the segment 
	keep if always==1
		
	*Collapsing at the segment level 
	collapse (mean) sex_sh=S06P02 female_head mean_age=S06P03A literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A married_rate=married_mu remittance_rate=S06P15A had_child_rate=S06P25 teen_pregnancy_rate=teen_pregnancy work_hours=S06P23 always_sh=always (sum) pet po pd pea nea wage nowage total_pop female male public private boss independent, by(segm_id)

	*Tasa de desempleo 
	gen td=pd/pea 

	*Normalizing the active and employed population over pet
	gen po_pet=po/pet
	gen pea_pet=pea/pet
	gen wage_pet=wage/pet 
	gen public_pet=public/pet
	gen private_pet=private/pet
	gen boss_pet=boss/pet
	gen independent_pet=independent/pet
	
	*Renaming variables
	rename sex_sh-independent_pet =_always
	
	*Saving the data 
	tempfile Always
	save `Always', replace 	

restore

preserve

	*Keeping only population that never left the segment and endured the war according to their age
	keep if always==1 & age_war==1
	
	*Collapsing at the segment level 
	collapse (mean) sex_sh=S06P02 female_head mean_age=S06P03A literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A married_rate=married_mu remittance_rate=S06P15A had_child_rate=S06P25 teen_pregnancy_rate=teen_pregnancy work_hours=S06P23 always_sh=always (sum) pet po pd pea nea wage nowage total_pop female male public private boss independent, by(segm_id)

	*Tasa de desempleo 
	gen td=pd/pea 

	*Normalizing the active and employed population over pet
	gen po_pet=po/pet
	gen pea_pet=pea/pet
	gen wage_pet=wage/pet 
	gen public_pet=public/pet
	gen private_pet=private/pet
	gen boss_pet=boss/pet
	gen independent_pet=independent/pet
	
	*Renaming variables
	rename sex_sh-independent_pet =_waralways
	
	*Saving the data 
	tempfile Waralways
	save `Waralways', replace 	

restore


preserve

	*Keeping only population that never left the segment and endured the war according to their age
	keep if always==1 & age_war==1
	keep if age_war_range!=.
	
	*Collapsing at the segment level by age range 
	collapse (mean) sex_sh=S06P02 mean_age=S06P03A literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A married_rate=married_mu remittance_rate=S06P15A had_child_rate=S06P25 teen_pregnancy_rate=teen_pregnancy work_hours=S06P23 always_sh=always (sum) pet po pd pea nea wage nowage total_pop female male public private boss independent, by(segm_id age_war_range)

	*Tasa de desempleo 
	gen td=pd/pea 

	*Normalizing the active and employed population over pet
	gen po_pet=po/pet
	gen pea_pet=pea/pet
	gen wage_pet=wage/pet 
	gen public_pet=public/pet
	gen private_pet=private/pet
	gen boss_pet=boss/pet
	gen independent_pet=independent/pet
	
	*Reshaping to leave the segment as unique identifier 
	reshape wide sex_sh mean_age literacy_rate asiste_rate mean_educ_years married_rate had_child_rate remittance_rate pet po pd pea nea td wage nowage public private boss independent total_pop female male po_pet pea_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet, i(segm_id) j(age_war_range)
	
	*Renaming vars
	ren *1 *_27_43_yrs_waral
	ren *2 *_43_58_yrs_waral
	
	*Saving the data 
	tempfile Agewaralways
	save `Agewaralways', replace 	

restore

*Collapsing at the segment level 
collapse (mean) female_head sex_sh=S06P02 mean_age=S06P03A literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A married_rate=married_mu remittance_rate=S06P15A had_child_rate=S06P25 teen_pregnancy_rate=teen_pregnancy work_hours=S06P23 always_sh=always moving_sh=moving_pop (sum) pet po pd pea nea wage nowage total_pop female male always arrived_war moving_pop moving_incntry_pop moving_outcntry_pop public private boss independent, by(segm_id)

*Tasa de desempleo 
gen td=pd/pea 

*Normalizing the active and employed population over pet
gen po_pet=po/pet
gen pea_pet=pea/pet
gen wage_pet=wage/pet 
gen public_pet=public/pet
gen private_pet=private/pet
gen boss_pet=boss/pet
gen independent_pet=independent/pet

*Merging the other modules 
merge 1:1 segm_id using `Household', nogen 
merge 1:1 segm_id using `Gender', nogen 
merge 1:1 segm_id using `Age', nogen 
merge 1:1 segm_id using `Mortality', nogen 
merge 1:1 segm_id using `Migration', nogen 
merge 1:1 segm_id using `Always', nogen 
merge 1:1 segm_id using `Waralways', nogen 
merge 1:1 segm_id using `Agewaralways', nogen 


*Saving the data 
save "${data}/temp\census07_segm_lvl.dta", replace 







graph close _all
*END
