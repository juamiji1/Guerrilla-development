/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring possible mechanisms
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control w_cntrl_age_war_2 age_war_2 i.within_control#c.z_run_cntrl c.z_run_cntrl#ib1.age_war_range i.within_control#c.z_run_cntrl#ib1.age_war_range z_run_cntrl x_coord y_coord c.x_coord#c.z_run_cntrl c.y_coord#c.z_run_cntrl dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"

*Capturing the bandwidth 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*-------------------------------------------------------------------------------
*	Using only the popoulation who endured the war and never moved
*-------------------------------------------------------------------------------
keep segm_id within_control x_coord y_coord z_run_cntrl elevation2 *_break_fe* *_waral river1 dist_capital dist_coast

*Renaming vars 
ren *_27_43_yrs_waral *1  
ren *_43_58_yrs_waral *2
*ren *_59_mor_yrs_waral *3

reshape long sex_sh mean_age literacy_rate asiste_rate mean_educ_years married_rate had_child_rate remittance_rate pet po pd pea nea to td wage nowage public private boss independent total_pop female male po_pet pea_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet, i(segm_id) j(age_war_range)

tab age_war_range, g(age_war_)

*Creating vars for regressions 
gen w_cntrl_age_war_1=within_control*age_war_1
gen w_cntrl_age_war_2=within_control*age_war_2
*gen w_cntrl_age_war_3=within_control*age_war_3

*Labeling vars
la var age_war_1 "0-15 yrs old in 1980 (war beginnings)"
la var age_war_2 "16-31 yrs in old 1980 (war beginnings)"
*la var age_war_3 "59$+$ yrs"
la var w_cntrl_age_war_1 "Guerrilla control $\times$ 0-15 yrs old in 1980"
la var w_cntrl_age_war_2 "Guerrilla control $\times$ 16-31 yrs old in 1980"
*la var w_cntrl_age_war_3 "Within $\times$ 59$+$ years"
la var within_control "Guerrilla control $\times$ 0-15 yrs old in 1980"

*-------------------------------------------------------------------------------
* 					Mechanisms related to education
*-------------------------------------------------------------------------------
gl educ "literacy_rate asiste_rate mean_educ_years"

*Labeling for tables 
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"

*Erasing files 
cap erase "${tables}\rdd_dvsnd_educ_agewaralways_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_educ_agewaralways_mechanisms_onu_91.txt"

*Tables
foreach var of global educ{
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

	*Estimations 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_educ_agewaralways_mechanisms_onu_91.tex", tex(frag) keep(within_control w_cntrl_age_war_2) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* 					Mechanisms related to labor markets
*-------------------------------------------------------------------------------
gl lab "pea_pet po_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet"

*Labeling for tables 
la var pea_pet "Economically Active Population"
la var po_pet "Working Population"
la var wage_pet "Salaried Population"
la var work_hours "Weekly Worked Hours"
la var public_pet "Public Worker"
la var private_pet "Private Worker"
la var boss_pet "Employer"
la var independent_pet "Independent Worker"

*Erasing files 
cap erase "${tables}\rdd_dvsnd_lab_agewaralways_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_lab_agewaralways_mechanisms_onu_91.txt"

*Tables
foreach var of global lab{
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

	*Estimations 
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_lab_agewaralways_mechanisms_onu_91.tex", tex(frag) keep(within_control w_cntrl_age_war_2) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}







*END

