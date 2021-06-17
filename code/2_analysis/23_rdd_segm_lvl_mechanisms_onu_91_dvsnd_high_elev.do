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
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord c.x_coord#c.z_run_cntrl c.y_coord#c.z_run_cntrl dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"
	
*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* 				Mechanisms related to household conditions
*-------------------------------------------------------------------------------
gl hh "sewerage_sh pipes_sh electricity_sh garbage_sh total_hospitals total_schools "
*out: total_household owner_sh sanitary_sh daily_water_sh

*Labeling for tables 
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

*Erasing files 
cap erase "${tables}\rdd_dvsnd_hh_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_hh_mechanisms_onu_91.txt"
	
*Tables
foreach var of global hh{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_hh_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

*Plots
foreach var of global hh{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if2 "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if2}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}

*-------------------------------------------------------------------------------
* 					Mechanisms related to demographics
*-------------------------------------------------------------------------------
gl dem1 "total_pop female_head sex_sh mean_age had_child_rate"
gl dem2 "total_pop_always female_head_always sex_sh_always mean_age_always had_child_rate_always teen_pregnancy_rate_always"
gl dem3 "total_pop_waralways female_head_waralways sex_sh_waralways mean_age_waralways had_child_rate_waralways"

*Labeling for tables 
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

*Erasing files 
cap erase "${tables}\rdd_dvsnd_dem_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_dem_mechanisms_onu_91.txt"
cap erase "${tables}\rdd_dvsnd_dem_always_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_dem_always_mechanisms_onu_91.txt"
cap erase "${tables}\rdd_dvsnd_dem_waralways_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_dem_waralways_mechanisms_onu_91.txt"

*Tables
foreach var of global dem1{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)

	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_dem_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global dem2{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	dis "reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) "
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_dem_always_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global dem3{
	
	*Dependent's var mean
	cap nois summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_dem_waralways_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

*Plots
gl dem "total_pop sex_sh mean_age had_child_rate teen_pregnancy_rate total_pop_always sex_sh_always mean_age_always had_child_rate_always teen_pregnancy_rate_always"

foreach var of global dem{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if2 "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if2}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}

*-------------------------------------------------------------------------------
* 					Mechanisms related to education
*-------------------------------------------------------------------------------
gl educ1 "mean_educ_years literacy_rate asiste_rate"
gl educ2 "mean_educ_years_always literacy_rate_always asiste_rate_always"
gl educ3 "mean_educ_years_waralways literacy_rate_waralways asiste_rate_waralways"
*out: total_matricula 

*Labeling for tables 
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

*Erasing files 
cap erase "${tables}\rdd_dvsnd_educ_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_educ_mechanisms_onu_91.txt"
cap erase "${tables}\rdd_dvsnd_educ_always_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_educ_always_mechanisms_onu_91.txt"
cap erase "${tables}\rdd_dvsnd_educ_waralways_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_educ_waralways_mechanisms_onu_91.txt"

*Tables
foreach var of global educ1{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_educ_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global educ2{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_educ_always_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global educ3{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_educ_waralways_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

*Plots
gl educ "total_schools total_matricula literacy_rate asiste_rate mean_educ_years literacy_rate_always asiste_rate_always mean_educ_years_always"

foreach var of global educ{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if2 "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if2}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}

*-------------------------------------------------------------------------------
* 					Mechanisms related to labor markets
*-------------------------------------------------------------------------------
gl lab1 "pea_pet po_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet"
gl lab2 "pea_pet_always po_pet_always wage_pet_always work_hours_always public_pet_always private_pet_always boss_pet_always independent_pet_always"
gl lab3 "pea_pet_waralways po_pet_waralways wage_pet_waralways work_hours_waralways public_pet_waralways private_pet_waralways boss_pet_waralways independent_pet_waralways"

*Labeling for tables 
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

*Erasing files 
cap erase "${tables}\rdd_dvsnd_lab_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_lab_mechanisms_onu_91.txt"
cap erase "${tables}\rdd_dvsnd_lab_always_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_lab_always_mechanisms_onu_91.txt"
cap erase "${tables}\rdd_dvsnd_lab_waralways_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_lab_waralways_mechanisms_onu_91.txt"

*Tables
foreach var of global lab1{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_lab_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global lab2{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_lab_always_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

foreach var of global lab3{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_lab_waralways_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

*Plots
gl lab "pea_pet po_pet wage_pet work_hours pea_pet_always po_pet_always wage_pet_always work_hours_always"

foreach var of global lab{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if2 "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if2}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}

*-------------------------------------------------------------------------------
* 					Mechanisms related to migration
*-------------------------------------------------------------------------------
gl migr "total_pop total_migrant war_migrant sex_migrant_sh remittance_rate arrived_war moving_pop moving_sh"

*Labeling for tables 
la var total_pop "Total Population"
la var total_migrant "International Migrants"
la var war_migrant "Total War Migrants"
la var sex_migrant_sh "Migrants' Gender Rate"
la var remittance_rate "Remittances Rate"
la var moving_pop "Moving Population"
la var moving_sh "Moving Population Share"
la var moving_incntry_pop "Moving Population (Internal)"
la var moving_outcntry_pop "Moving Population (International)"

*Erasing files 
cap erase "${tables}\rdd_dvsnd_migr_mechanisms_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_migr_mechanisms_onu_91.txt"

*Tables
foreach var of global migr{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Total Households
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	outreg2 using "${tables}\rdd_dvsnd_migr_mechanisms_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Rdplot
	rdplot `var' z_run_cntrl ${if}, ci(95) covs_drop(fe_*) kernel(triangular) nbins(10) p(1) graph_options(title(""))
	gr export "${plots}\rdplot_`var'.pdf", as(pdf) replace 

}

*Plots
gl migr "total_migrant war_migrant sex_migrant_sh remittance_rate always_sh always arrived_war moving_pop moving_sh moving_incntry_pop moving_outcntry_pop"

foreach var of global migr{
	
	*Dependent's var mean
	summ `var' if elevation2>=200 & river1==0, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=0.1
	forval c=1/40{

		*Conditional for all specifications
		gl if2 "if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if2}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y})
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_segm_91_p25.pdf", as(pdf) replace 

}






*END

