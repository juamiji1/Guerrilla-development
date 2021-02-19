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

*Age
tab S06P03A
gen age_range=1 if S06P03A<15
replace age_range=2 if S06P03A>=15 & S06P03A<30 
replace age_range=3 if S06P03A>=30 & S06P03A<45 
replace age_range=4 if S06P03A>=45 & S06P03A<60 
replace age_range=5 if S06P03A>=60

*Literacy 
tab S06P09
recode S06P09 (-2=.) (2=0) 

*Assit to a formal educational center 
tab S06P10
recode S06P10 (-2=.) 

gen asiste=(S06P10<3) if S06P10!=.

tab asiste S06P10, m

*Years of education
tab S06P11A

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
replace po=0 if S06P16A==0 & S06P16B==0 & S06P16C==7 & pet==1

*Poblacion desocupada 
recode S06P17 S06P18 (-2=.) (2=0)

gen pd=1 if (S06P17==1 | S06P18==1) & pet==1 
replace pd=0 if S06P17==0 & S06P18==0 & pet==1

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
	collapse (mean) literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A remittance_rate=S06P15A (sum) pet po pd pea nea wage nowage, by(segm_id S06P02)

	*Tasa de ocupacion 
	gen to=po/pea

	*Tasa de desempleo 
	gen td=pd/pea 

	*Reshaping to leave the segment as unique identifier 
	reshape wide literacy_rate asiste_rate mean_educ_years remittance_rate pet po pd pea nea to td wage nowage, i(segm_id) j(S06P02)

	*Renaming vars
	ren *0 *_f
	ren *1 *_m

	*Saving the data 
	tempfile Gender
	save `Gender', replace 

restore 

*Data at the age range level 
preserve

	*Collapsing at the segment gender level 
	collapse (mean) literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A (sum) pet po pd pea nea wage nowage total_pop, by(segm_id age_range)

	*Tasa de ocupacion 
	gen to=po/pea

	*Tasa de desempleo 
	gen td=pd/pea 

	*Reshaping to leave the segment as unique identifier 
	reshape wide literacy_rate asiste_rate mean_educ_years pet po pd pea nea to td wage nowage total_pop, i(segm_id) j(age_range)
	
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

*Collapsing at the segment level 
collapse (mean) sex_sh=S06P02 mean_age=S06P03A literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A married_rate=married_mu remittance_rate=S06P15A had_child_rate=S06P25 teen_pregnancy_rate=teen_pregnancy work_hours=S06P23 (sum) pet po pd pea nea wage nowage total_pop female male, by(segm_id)

*Tasa de ocupacion 
gen to=po/pea

*Tasa de desempleo 
gen td=pd/pea 

*Merging the other modules 
merge 1:1 segm_id using `Gender', nogen 
merge 1:1 segm_id using `Age', nogen 
merge 1:1 segm_id using `Mortality', nogen 
merge 1:1 segm_id using `Migration', nogen 


*Saving the data 
save "${data}/temp\census07_segm_lvl.dta", replace 






*END
