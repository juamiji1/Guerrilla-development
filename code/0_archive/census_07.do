/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Collapsing 2007 census to sthe segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development"
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

*Total of migrants 
gen total_migrant=1

*Collapsing at the segment-year level 
preserve 
	collapse (sum) female_migrant male_migrant total_migrant, by(S05BC05)
	
	*Plot showing temporal migration patterns 
	two (line total_migrant S05BC05, legend(label(1 "Total"))) (line female_migrant S05BC05, legend(label(2 "Female"))) (line male_migrant S05BC05, legend(label(3 "Male"))), ytitle(Total) xtitle(Year) xlabel(1920(5)2007, angle(45) labsize(small)) legend(c(3))
restore 

*Collapsing at the segment level 
collapse (mean) sex_migrant_sh=S05BC02 age_migrant=S05BC03 (sum) female_migrant male_migrant total_migrant, by(segm_id)

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

*Worked last week as a formal 
tab S06P16A
recode S06P16A S06P16B (-2=.) (2=0)

gen work_formal=1 if S06P16A==1 | S06P16B==1
replace work_formal=0 if S06P16A==0 & S06P16B==0

tab work_formal S06P16A

*Worked as informal 
tab S06P16C
recode S06P16C (-2=.)

tab S06P16C work_formal, m

gen work_informal=1 if S06P16C<7
replace work_informal=0 if (S06P16C==. & work_formal==1) | S06P16C==7

tab work_formal work_informal, m

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

*Collapsing at the segment level 
collapse (mean) sex_sh=S06P02 mean_age=S06P03A literacy_rate=S06P09 asiste_rate=asiste mean_educ_years=S06P11A married_rate=married_mu remittance_rate=S06P15A work_formal_rate=work_formal work_informal_rate=work_informal had_child_rate=S06P25 teen_pregnancy_rate=teen_pregnancy (sum) total_pop female male, by(segm_id)

*Merging the other modules 
merge 1:1 segm_id using `Mortality', nogen 
merge 1:1 segm_id using `Migration', nogen 


tempfile Population
save `Population', replace 


*-------------------------------------------------------------------------------
* 					     		Night light 
*	
*-------------------------------------------------------------------------------
*Loading the data 
use "slvShp_segm_info_sp.dta", clear

*Renaming important variables 
rename (SEG_ID wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_nl mean_lv mean_cc mean_bn wmn_nl1 mn_nl_z wmn_nl_ sm_lv_1 sm_lv_2 sm_lv_3 sm_lv_4 men_nl2 men_lv2 wmn_nl2 wmn_lv2 lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2 rail_nt road_nt) (segm_id within_control within_expansion within_disputed dist_control dist_expansion dist_disputed nl13_density elevation cacao bean wmean_nl1 mean_nl_z wmean_nl_z sum_elev_1 sum_elev_2 sum_elev_3 sum_elev_4 mean_nl2 mean_elev2 wmean_nl2 wmean_elev2 lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 rail roads) 

*Merging the census 2007
merge 1:1 segm_id using `Population', nogen 

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_expansion=dist_expansion/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn= dist_expansion 
replace z_run_xpsn= -1*dist_expansion if within_expansion==0

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)






*Robusteness of disputed results
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)

*Mechanisms results 
rdrobust literacy_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p1.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

rdrobust asiste_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p1.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

rdrobust mean_educ_years z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p1.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

rdrobust work_formal_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p1.tex", tex(frag) ctitle("Formal Workers Share") addstat("Polynomial", 1) nonote append 

rdrobust work_informal_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p1.tex", tex(frag) ctitle("Informal Workers Share") addstat("Polynomial", 1) nonote append 


*
rdrobust remittance_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p2.tex", tex(frag) ctitle("Remittances Share") addstat("Polynomial", 1) nonote append 

rdrobust female_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Female Migrants") addstat("Polynomial", 1) nonote append 

rdrobust male_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Male Migrants") addstat("Polynomial", 1) nonote append 

rdrobust total_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Migrants") addstat("Polynomial", 1) nonote append 

rdrobust sex_migrant_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p2.tex", tex(frag) ctitle("Migrant's Gender Share") addstat("Polynomial", 1) nonote append 


*
rdrobust total_dead z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Deceased") addstat("Polynomial", 1) nonote append 

rdrobust female_dead z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Females Deceased") addstat("Polynomial", 1) nonote append 

rdrobust male_dead z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Males Deceased") addstat("Polynomial", 1) nonote append 

rdrobust sex_dead_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p3.tex", tex(frag) ctitle("Deceased's Gender Share") addstat("Polynomial", 1) nonote append 


*
rdrobust total_pop z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Population") addstat("Polynomial", 1) nonote append 

rdrobust female z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Females") addstat("Polynomial", 1) nonote append 

rdrobust male z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Males") addstat("Polynomial", 1) nonote append 

rdrobust sex_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Gender Share") addstat("Polynomial", 1) nonote append 

rdrobust mean_age z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Mean Age") addstat("Polynomial", 1) nonote append 

rdrobust married_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Married Share") addstat("Polynomial", 1) nonote append 

rdrobust had_child_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Fertility Rate") addstat("Polynomial", 1) nonote append 

rdrobust teen_pregnancy_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_dsptd_mechanisms_segm_p4.tex", tex(frag) ctitle("Teenage Pregnancy Rate") addstat("Polynomial", 1) nonote append 


  






*END 
