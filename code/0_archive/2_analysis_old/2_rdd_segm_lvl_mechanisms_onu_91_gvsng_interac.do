/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Spatial RDD at the segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

/*
gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development\code"
gl path "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}
*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*-------------------------------------------------------------------------------
* 				Mechanisms related to household conditions
*-------------------------------------------------------------------------------
*Total Households
summ total_household, d
gl mean_nl=round(r(mean), .01)

rdrobust total_household z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_household within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Total Households") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Ownership Rate
summ owner_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust owner_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe owner_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Ownership Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Sanitary Service Rate
summ sanitary_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sanitary_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe sanitary_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Sanitary Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Sewerage Service Rate
summ sewerage_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sewerage_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe sewerage_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Sewerage Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Water Pipes Service Rate
summ pipes_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust pipes_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe pipes_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Water Pipes Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Daily Water Rate
summ daily_water_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust daily_water_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe daily_water_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Daily Water Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Electricity Service Rate
summ electricity_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust electricity_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe electricity_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Electricity Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Garbage Service Rate
summ garbage_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust garbage_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe garbage_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Garbage Service Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Number of Hospitals
summ total_hospitals, d
gl mean_nl=round(r(mean), .01)

rdrobust total_hospitals z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_hospitals within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_house_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Number of Hospitals") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to demographics
*-------------------------------------------------------------------------------
*Total Population
summ total_pop, d
gl mean_nl=round(r(mean), .01)

rdrobust total_pop z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_pop within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Total Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Gender Share
summ sex_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sex_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe sex_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Gender Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append

*Average Age
summ mean_age, d
gl mean_nl=round(r(mean), .01)

rdrobust mean_age z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe mean_age within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Average Age") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Fertility Rate
summ had_child_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust had_child_rate z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe had_child_rate within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Fertility Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Teen Pregnancy Rate
summ teen_pregnancy_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust teen_pregnancy_rate z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe teen_pregnancy_rate within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Teen Pregnancy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Total Population (without migrants)
summ total_pop_always , d
gl mean_nl=round(r(mean), .01)

rdrobust total_pop_always  z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_pop_always  within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Total Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Gender Share (without migrants)
summ sex_sh_always , d
gl mean_nl=round(r(mean), .01)

rdrobust sex_sh_always  z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe sex_sh_always  within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Gender Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append

*Average Age (without migrants)
summ mean_age_always , d
gl mean_nl=round(r(mean), .01)

rdrobust mean_age_always  z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe mean_age_always  within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Average Age") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Fertility Rate (without migrants)
summ had_child_rate_always , d
gl mean_nl=round(r(mean), .01)

rdrobust had_child_rate_always  z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe had_child_rate_always  within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Fertility Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Teen Pregnancy Rate (without migrants)
summ teen_pregnancy_rate_always , d
gl mean_nl=round(r(mean), .01)

rdrobust teen_pregnancy_rate_always  z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe teen_pregnancy_rate_always  within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_demog_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Teen Pregnancy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to education
*-------------------------------------------------------------------------------
*Number of Schools
summ total_schools, d
gl mean_nl=round(r(mean), .01)

rdrobust total_schools z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_schools within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Number of Schools") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Total Enrollment
summ total_matricula, d
gl mean_nl=round(r(mean), .01)

rdrobust total_matricula z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_matricula within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Total Enrollment") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Literacy Rate
summ literacy_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust literacy_rate z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe literacy_rate within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Literacy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Assist(ed) School
summ asiste_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust asiste_rate z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe asiste_rate within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Assist(ed) School") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Years of Education
summ mean_educ_years, d
gl mean_nl=round(r(mean), .01)

rdrobust mean_educ_years z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe mean_educ_years within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Years of Education") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Literacy Rate (without migrants)
summ literacy_rate_always, d
gl mean_nl=round(r(mean), .01)

rdrobust literacy_rate_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe literacy_rate_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Literacy Rate") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Assist(ed) School (without migrants)
summ asiste_rate_always, d
gl mean_nl=round(r(mean), .01)

rdrobust asiste_rate_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe asiste_rate_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Assist(ed) School") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Years of Education (without migrants)
summ mean_educ_years_always, d
gl mean_nl=round(r(mean), .01)

rdrobust mean_educ_years_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe mean_educ_years_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_educ_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Years of Education") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to labor markets
*-------------------------------------------------------------------------------
*Active Population
summ pea_pet, d
gl mean_nl=round(r(mean), .01)

rdrobust pea_pet z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe pea_pet within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Active Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Working Population
summ po_pet, d
gl mean_nl=round(r(mean), .01)

rdrobust po_pet z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe po_pet within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Working Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Salaried Population
summ wage_pet, d
gl mean_nl=round(r(mean), .01)

rdrobust wage_pet z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe wage_pet within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Salaried Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Weekly Working Hours
summ work_hours, d
gl mean_nl=round(r(mean), .01)

rdrobust work_hours z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe work_hours within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Weekly Working Hours") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Active Population (without migrants)
summ pea_pet_always, d
gl mean_nl=round(r(mean), .01)

rdrobust pea_pet_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe pea_pet_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Active Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Working Population (without migrants)
summ po_pet_always, d
gl mean_nl=round(r(mean), .01)

rdrobust po_pet_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe po_pet_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Working Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Salaried Population (without migrants)
summ wage_pet_always, d
gl mean_nl=round(r(mean), .01)

rdrobust wage_pet_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe wage_pet_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Salaried Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Weekly Working Hours (without migrants)
summ work_hours_always, d
gl mean_nl=round(r(mean), .01)

rdrobust work_hours_always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe work_hours_always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_labor_segm_always.tex", tex(frag) keep(within_fmln within_control) ctitle("Weekly Working Hours") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to migration
*-------------------------------------------------------------------------------
*Total Migrants
summ total_migrant, d
gl mean_nl=round(r(mean), .01)

rdrobust total_migrant z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe total_migrant within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_migra_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Total Migrants") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Total War Migrants
summ war_migrant, d
gl mean_nl=round(r(mean), .01)

rdrobust war_migrant z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe war_migrant within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_migra_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Total War Migrants") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Migrants' Gender Share
summ sex_migrant_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust sex_migrant_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe sex_migrant_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_migra_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Migrants' Gender Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Remittances Share
summ remittance_rate, d
gl mean_nl=round(r(mean), .01)

rdrobust remittance_rate z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe remittance_rate within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_migra_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Remittances Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Non Moving Share
summ always_sh, d
gl mean_nl=round(r(mean), .01)

rdrobust always_sh z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe always_sh within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_migra_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Non Moving Share") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Non Moving Population
summ always, d
gl mean_nl=round(r(mean), .01)

rdrobust always z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe always within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_migra_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Non Moving Population") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 









*END
