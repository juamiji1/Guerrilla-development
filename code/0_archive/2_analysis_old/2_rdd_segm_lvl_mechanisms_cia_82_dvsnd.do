/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Spatial RDD at the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl.dta", clear

*-------------------------------------------------------------------------------
* 				Mechanisms related to household conditions
*-------------------------------------------------------------------------------
*Total Households
summ total_household, d
gl mean_nl=round(r(mean), .01)

rdrobust total_household z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_household within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Total Households") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Ownership Rate
summ owner_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust owner_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe owner_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Ownership Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Sanitary Service Rate
summ sanitary_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sanitary_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe sanitary_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Sanitary Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Sewerage Service Rate
summ sewerage_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sewerage_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe sewerage_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Sewerage Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Water Pipes Service Rate
summ pipes_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust pipes_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe pipes_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Water Pipes Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Daily Water Rate
summ daily_water_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust daily_water_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe daily_water_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Daily Water Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Electricity Service Rate
summ electricity_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust electricity_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe electricity_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Electricity Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Garbage Service Rate
summ garbage_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust garbage_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe garbage_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Garbage Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Number of Hospitals
summ total_hospitals, d
gl mean_nl=round(r(mean), .01)

rdrobust total_hospitals z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_hospitals within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_house_segm_82.tex", tex(frag) keep(within_control) ctitle("Number of Hospitals") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to demographics
*-------------------------------------------------------------------------------
*Total Population
summ total_pop, d
gl mean_nl=round(r(mean), .01)

rdrobust total_pop z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_pop within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82.tex", tex(frag) keep(within_control) ctitle("Total Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Gender Share
summ sex_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sex_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe sex_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82.tex", tex(frag) keep(within_control) ctitle("Gender Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append

*Average Age
summ mean_age, d
gl mean_nl=round(r(mean), .01)

rdrobust mean_age z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe mean_age within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82.tex", tex(frag) keep(within_control) ctitle("Average Age") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Fertility Rate
summ had_child_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust had_child_rate z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe had_child_rate within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82.tex", tex(frag) keep(within_control) ctitle("Fertility Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Teen Pregnancy Rate
summ teen_pregnancy_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust teen_pregnancy_rate z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe teen_pregnancy_rate within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82.tex", tex(frag) keep(within_control) ctitle("Teen Pregnancy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Total Population (without migrants)
summ total_pop_always , d
gl mean_nl=round(r(mean), .01)

rdrobust total_pop_always  z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_pop_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Total Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Gender Share (without migrants)
summ sex_sh_always , d
gl mean_nl=round(r(mean), .01)

rdrobust sex_sh_always  z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe sex_sh_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82_always.tex", tex(frag) keep(within_control)  ctitle("Gender Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append

*Average Age (without migrants)
summ mean_age_always , d
gl mean_nl=round(r(mean), .01)

rdrobust mean_age_always  z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe mean_age_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Average Age") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Fertility Rate (without migrants)
summ had_child_rate_always , d
gl mean_nl=round(r(mean), .01)

rdrobust had_child_rate_always  z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe had_child_rate_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Fertility Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Teen Pregnancy Rate (without migrants)
summ teen_pregnancy_rate_always , d
gl mean_nl=round(r(mean), .01)

rdrobust teen_pregnancy_rate_always  z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe teen_pregnancy_rate_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_demog_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Teen Pregnancy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to education
*-------------------------------------------------------------------------------
*Number of Schools
summ total_schools, d
gl mean_nl=round(r(mean), .01)

rdrobust total_schools z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_schools within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82.tex", tex(frag) keep(within_control) ctitle("Number of Schools") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Total Enrollment
summ total_matricula, d
gl mean_nl=round(r(mean), .01)

rdrobust total_matricula z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_matricula within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82.tex", tex(frag) keep(within_control) ctitle("Total Enrollment") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Literacy Rate
summ literacy_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust literacy_rate z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe literacy_rate within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82.tex", tex(frag) keep(within_control) ctitle("Literacy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Assist(ed) School
summ asiste_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust asiste_rate z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe asiste_rate within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82.tex", tex(frag) keep(within_control) ctitle("Assist(ed) School") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Years of Education
summ mean_educ_years, d
gl mean_nl=round(r(mean), .01)

rdrobust mean_educ_years z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe mean_educ_years within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82.tex", tex(frag) keep(within_control) ctitle("Years of Education") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Literacy Rate (without migrants)
summ literacy_rate_always, d
gl mean_nl=round(r(mean), .01)

rdrobust literacy_rate_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe literacy_rate_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Literacy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Assist(ed) School (without migrants)
summ asiste_rate_always, d
gl mean_nl=round(r(mean), .01)

rdrobust asiste_rate_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe asiste_rate_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Assist(ed) School") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Years of Education (without migrants)
summ mean_educ_years_always, d
gl mean_nl=round(r(mean), .01)

rdrobust mean_educ_years_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe mean_educ_years_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_educ_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Years of Education") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to labor markets
*-------------------------------------------------------------------------------
*Active Population
summ pea_pet, d
gl mean_nl=round(r(mean), .01)

rdrobust pea_pet z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe pea_pet within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82.tex", tex(frag) keep(within_control) ctitle("Active Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Working Population
summ po_pet, d
gl mean_nl=round(r(mean), .01)

rdrobust po_pet z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe po_pet within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82.tex", tex(frag) keep(within_control) ctitle("Working Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Salaried Population
summ wage_pet, d
gl mean_nl=round(r(mean), .01)

rdrobust wage_pet z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe wage_pet within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82.tex", tex(frag) keep(within_control) ctitle("Salaried Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Weekly Working Hours
summ work_hours, d
gl mean_nl=round(r(mean), .01)

rdrobust work_hours z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe work_hours within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82.tex", tex(frag) keep(within_control) ctitle("Weekly Working Hours") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Active Population (without migrants)
summ pea_pet_always, d
gl mean_nl=round(r(mean), .01)

rdrobust pea_pet_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe pea_pet_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Active Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Working Population (without migrants)
summ po_pet_always, d
gl mean_nl=round(r(mean), .01)

rdrobust po_pet_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe po_pet_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Working Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Salaried Population (without migrants)
summ wage_pet_always, d
gl mean_nl=round(r(mean), .01)

rdrobust wage_pet_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe wage_pet_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Salaried Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Weekly Working Hours (without migrants)
summ work_hours_always, d
gl mean_nl=round(r(mean), .01)

rdrobust work_hours_always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe work_hours_always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_labor_segm_82_always.tex", tex(frag) keep(within_control) ctitle("Weekly Working Hours") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to migration
*-------------------------------------------------------------------------------
*Total Migrants
summ total_migrant, d
gl mean_nl=round(r(mean), .01)

rdrobust total_migrant z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe total_migrant within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_migra_segm_82.tex", tex(frag) keep(within_control) ctitle("Total Migrants") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Total War Migrants
summ war_migrant, d
gl mean_nl=round(r(mean), .01)

rdrobust war_migrant z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe war_migrant within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_migra_segm_82.tex", tex(frag) keep(within_control) ctitle("Total War Migrants") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Migrants' Gender Share
summ sex_migrant_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sex_migrant_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe sex_migrant_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_migra_segm_82.tex", tex(frag) keep(within_control) ctitle("Migrants' Gender Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Remittances Share
summ remittance_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust remittance_rate z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe remittance_rate within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_migra_segm_82.tex", tex(frag) keep(within_control) ctitle("Remittances Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Non Moving Share
summ always_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust always_sh z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe always_sh within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_migra_segm_82.tex", tex(frag) keep(within_control) ctitle("Non Moving Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Non Moving Population
summ always, d
gl mean_nl=round(r(mean), .01)

rdrobust always z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe always within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_migra_segm_82.tex", tex(frag) keep(within_control) ctitle("Non Moving Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 









*END
