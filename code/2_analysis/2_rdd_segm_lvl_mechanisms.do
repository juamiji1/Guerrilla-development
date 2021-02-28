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

use "${data}/night_light_13_segm_lvl.dta", clear


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* 				Mechanisms related to household conditions
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust total_household z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Total Households") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote replace 

rdrobust owner_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Ownership Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append 

rdrobust sanitary_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Sanitary Service Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust sewerage_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Sewerage Service Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust pipes_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Water Pipes Service Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust daily_water_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Daily Water Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust electricity_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Electricity Service Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust garbage_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Garbage Service Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust total_hospitals z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_house.tex", tex(frag) ctitle("Number of Hospitals") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

*-------------------------------------------------------------------------------
* 					Mechanisms related to demographics
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust total_pop z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_demog.tex", tex(frag) ctitle("Total Population") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote replace 

rdrobust sex_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_demog.tex", tex(frag) ctitle("Gender Share") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append  

rdrobust mean_age z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_demog.tex", tex(frag) ctitle("Mean Age") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append   

rdrobust had_child_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_demog.tex", tex(frag) ctitle("Fertility Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append  

rdrobust teen_pregnancy_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_demog.tex", tex(frag) ctitle("Teenage Pregnancy Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append  

*-------------------------------------------------------------------------------
* 					Mechanisms related to education
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust total_schools z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_educ.tex", tex(frag) ctitle("Number of Schools") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote replace  

rdrobust literacy_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_educ.tex", tex(frag) ctitle("Literacy Rate") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append  

rdrobust asiste_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_educ.tex", tex(frag) ctitle("Assist(ed) School") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append  

rdrobust mean_educ_years z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_educ.tex", tex(frag) ctitle("Years of Education") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append  

*-------------------------------------------------------------------------------
* 					Mechanisms related to labor markets
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust pea_pet z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_labor.tex", tex(frag) ctitle("Active Population") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote replace 

rdrobust po_pet z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_labor.tex", tex(frag) ctitle("Working Population") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append 

rdrobust wage_pet z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_labor.tex", tex(frag) ctitle("Salaried Population") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append 

rdrobust work_hours z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_labor.tex", tex(frag) ctitle("Weekly Working Hours") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append 

*-------------------------------------------------------------------------------
* 					Mechanisms related to migration
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust total_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_migr.tex", tex(frag) ctitle("Total Migrants") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote replace

rdrobust war_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_migr.tex", tex(frag) ctitle("Total War Migrants") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust sex_migrant_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_migr.tex", tex(frag) ctitle("Migrant's Gender Share") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append

rdrobust remittance_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
local h=e(h_l) 
local n=e(N_h_l)+e(N_h_r)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_migr.tex", tex(frag) ctitle("Remittances Share") addstat("Eff. Observations",`n',"Bandwidth", `h',"Polynomial", 1) nonote append 


*-------------------------------------------------------------------------------
* 					Coefplots of the mechanisms by age range 
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* 					Mechanisms related to education
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
mat coef1=J(3,4,.)
mat coef2=J(3,4,.)
mat coef3=J(3,4,.)
local c=1
foreach r in "_15_29_yrs" "_30_44_yrs" "_45_59_yrs" "_60_more_yrs" {
	*Literacy rate
	rdrobust literacy_rate`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef1[1,`c']= e(tau_bc)
	mat coef1[2,`c']= e(ci_l_rb)
	mat coef1[3,`c']= e(ci_r_rb)
	
	*Assistance to formal education
	rdrobust asiste_rate`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef2[1,`c']= e(tau_bc)
	mat coef2[2,`c']= e(ci_l_rb)
	mat coef2[3,`c']= e(ci_r_rb)
	
	*Average years of education 
	rdrobust mean_educ_years`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef3[1,`c']= e(tau_bc)
	mat coef3[2,`c']= e(ci_l_rb)
	mat coef3[3,`c']= e(ci_r_rb)
	
	local ++c
}

*Labeling columns 
mat coln coef1 = "15 to 29" "30 to 44" "45 to 59" "60 or more"
mat coln coef2 = "15 to 29" "30 to 44" "45 to 59" "60 or more"
mat coln coef3 = "15 to 29" "30 to 44" "45 to 59" "60 or more"

*Plotting the coefficients 
coefplot (mat(coef1[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(-.12(.02)0) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_literacy_age.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(-.12(.02)0) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_asiste_age.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(-2(.5)0) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_educ_years_age.pdf", as(pdf) replace  

*-------------------------------------------------------------------------------
* 					Mechanisms related to labor markets
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
mat coef1=J(3,4,.)
mat coef2=J(3,4,.)
mat coef3=J(3,4,.)
mat coef4=J(3,4,.)
local c=1
foreach r in "_15_29_yrs" "_30_44_yrs" "_45_59_yrs" "_60_more_yrs" {
	*PEA normalized over PET
	rdrobust pea_pet`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef1[1,`c']= e(tau_bc)
	mat coef1[2,`c']= e(ci_l_rb)
	mat coef1[3,`c']= e(ci_r_rb)
	
	*PO normalized over PET
	rdrobust po_pet`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef2[1,`c']= e(tau_bc)
	mat coef2[2,`c']= e(ci_l_rb)
	mat coef2[3,`c']= e(ci_r_rb)
	
	*PO normalized over PET
	rdrobust wage_pet`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef3[1,`c']= e(tau_bc)
	mat coef3[2,`c']= e(ci_l_rb)
	mat coef3[3,`c']= e(ci_r_rb)
	
	*Weekly working hours 
	rdrobust work_hours`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	mat coef4[1,`c']= e(tau_bc)
	mat coef4[2,`c']= e(ci_l_rb)
	mat coef4[3,`c']= e(ci_r_rb)
	
	local ++c
}

*Labeling columns 
mat coln coef1 = "15 to 29" "30 to 44" "45 to 59" "60 or more"
mat coln coef2 = "15 to 29" "30 to 44" "45 to 59" "60 or more"
mat coln coef3 = "15 to 29" "30 to 44" "45 to 59" "60 or more"
mat coln coef4 = "15 to 29" "30 to 44" "45 to 59" "60 or more"

*Plotting the coefficients 
coefplot (mat(coef1[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_pea_age.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_po_age.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_wage_age.pdf", as(pdf) replace  

coefplot (mat(coef4[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) l2title("Coeficient magnitud") b2title("Age Range") 
gr export "${plots}\rdd_z_run_dvsnd_whours_age.pdf", as(pdf) replace  












*END







/*-------------------------------------------------------------------------------
* 						SCRATCH: Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)

*Mechanisms on education and labor markets
rdrobust literacy_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

rdrobust asiste_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

rdrobust mean_educ_years z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

rdrobust pet z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Working Age Pop") addstat("Polynomial", 1) nonote append 

rdrobust po z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Employed Pop") addstat("Polynomial", 1) nonote append 

rdrobust wage z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Wage Workers") addstat("Polynomial", 1) nonote append 

rdrobust nowage z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("No Wage Workers") addstat("Polynomial", 1) nonote append 

rdrobust pd z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Unemployed Pop") addstat("Polynomial", 1) nonote append 

rdrobust pea z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Active Pop") addstat("Polynomial", 1) nonote append 

rdrobust nea z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Inactive Pop") addstat("Polynomial", 1) nonote append 

rdrobust to z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Employment Rate") addstat("Polynomial", 1) nonote append 

rdrobust td z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Unemployment Rate") addstat("Polynomial", 1) nonote append 

rdrobust work_hours z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p1.tex", tex(frag) ctitle("Working Hours") addstat("Polynomial", 1) nonote append 
  	
	
*Mechanisms on migration
rdrobust remittance_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p2.tex", tex(frag) ctitle("Remittances Share") addstat("Polynomial", 1) nonote replace 

rdrobust female_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Female Migrants") addstat("Polynomial", 1) nonote append 

rdrobust male_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Male Migrants") addstat("Polynomial", 1) nonote append 

rdrobust war_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p2.tex", tex(frag) ctitle("War Migrants") addstat("Polynomial", 1) nonote append 

rdrobust total_migrant z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Migrants") addstat("Polynomial", 1) nonote append 

rdrobust sex_migrant_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p2.tex", tex(frag) ctitle("Migrant's Gender Share") addstat("Polynomial", 1) nonote append 

*Mechanisms on mortality
rdrobust total_dead z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Deceased") addstat("Polynomial", 1) nonote replace 

rdrobust female_dead z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Females Deceased") addstat("Polynomial", 1) nonote append 

rdrobust male_dead z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Males Deceased") addstat("Polynomial", 1) nonote append 

rdrobust sex_dead_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p3.tex", tex(frag) ctitle("Deceased's Gender Share") addstat("Polynomial", 1) nonote append 

*Mechanisms on demography 
rdrobust total_pop z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Population") addstat("Polynomial", 1) nonote replace 

rdrobust female z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Females") addstat("Polynomial", 1) nonote append 

rdrobust male z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Males") addstat("Polynomial", 1) nonote append 

rdrobust sex_sh z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Gender Share") addstat("Polynomial", 1) nonote append 

rdrobust mean_age z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Mean Age") addstat("Polynomial", 1) nonote append 

rdrobust married_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Married Share") addstat("Polynomial", 1) nonote append 

rdrobust had_child_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Fertility Rate") addstat("Polynomial", 1) nonote append 

rdrobust teen_pregnancy_rate z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p4.tex", tex(frag) ctitle("Teenage Pregnancy Rate") addstat("Polynomial", 1) nonote append 


*Mechanisms on education and labor markets by gender 
rdrobust literacy_rate_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

rdrobust asiste_rate_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

rdrobust mean_educ_years_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

rdrobust pet_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Working Age Pop") addstat("Polynomial", 1) nonote append 

rdrobust po_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Employed Pop") addstat("Polynomial", 1) nonote append 

rdrobust wage_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Wage Workers") addstat("Polynomial", 1) nonote append 

rdrobust nowage_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("No Wage Workers") addstat("Polynomial", 1) nonote append 

rdrobust pd_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Unemployed Pop") addstat("Polynomial", 1) nonote append 

rdrobust pea_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Active Pop") addstat("Polynomial", 1) nonote append 

rdrobust nea_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Inactive Pop") addstat("Polynomial", 1) nonote append 

rdrobust to_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Employment Rate") addstat("Polynomial", 1) nonote append 

rdrobust td_f z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p5.tex", tex(frag) ctitle("Unemployment Rate") addstat("Polynomial", 1) nonote append 


rdrobust literacy_rate_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

rdrobust asiste_rate_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

rdrobust mean_educ_years_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

rdrobust pet_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Working Age Pop") addstat("Polynomial", 1) nonote append 

rdrobust po_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Employed Pop") addstat("Polynomial", 1) nonote append 

rdrobust wage_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Wage Workers") addstat("Polynomial", 1) nonote append 

rdrobust nowage_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("No Wage Workers") addstat("Polynomial", 1) nonote append 

rdrobust pd_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Unemployed Pop") addstat("Polynomial", 1) nonote append 

rdrobust pea_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Active Pop") addstat("Polynomial", 1) nonote append 

rdrobust nea_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Inactive Pop") addstat("Polynomial", 1) nonote append 

rdrobust to_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Employment Rate") addstat("Polynomial", 1) nonote append 

rdrobust td_m z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p6.tex", tex(frag) ctitle("Unemployment Rate") addstat("Polynomial", 1) nonote append 


*Mechanisms on education and labor markets by age group 
local i=7
local r="_0_14_yrs"
rdrobust literacy_rate`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

rdrobust asiste_rate`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

rdrobust mean_educ_years`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

local i=8
foreach r in "_15_29_yrs" "_30_44_yrs" "_45_59_yrs" "_60_more_yrs" {
	rdrobust literacy_rate`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

	rdrobust asiste_rate`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

	rdrobust mean_educ_years`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

	rdrobust pet`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Working Age Pop") addstat("Polynomial", 1) nonote append 

	rdrobust po`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Employed Pop") addstat("Polynomial", 1) nonote append 

	rdrobust wage`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Wage Workers") addstat("Polynomial", 1) nonote append 

	rdrobust nowage`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("No Wage Workers") addstat("Polynomial", 1) nonote append 

	rdrobust pd`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Unemployed Pop") addstat("Polynomial", 1) nonote append 

	rdrobust pea`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Active Pop") addstat("Polynomial", 1) nonote append 

	rdrobust nea`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Inactive Pop") addstat("Polynomial", 1) nonote append 

	rdrobust to`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Employment Rate") addstat("Polynomial", 1) nonote append 

	rdrobust td`r' z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) covs(elevation)
	outreg2 using "${tables}\rdd_dvsnd_mechanisms_segm_p`i'.tex", tex(frag) ctitle("Unemployment Rate") addstat("Polynomial", 1) nonote append 

	local ++i
}


/*Between pixels within FMLN controlled zones and disputed zones (not including pixels in expansion zones)
*Mechanisms on education 
rdrobust literacy_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p1.tex", tex(frag) ctitle("Literacy Rate") addstat("Polynomial", 1) nonote replace  

rdrobust asiste_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p1.tex", tex(frag) ctitle("Assist(ed) FEC") addstat("Polynomial", 1) nonote append 

rdrobust mean_educ_years z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p1.tex", tex(frag) ctitle("Years of Education") addstat("Polynomial", 1) nonote append  

rdrobust work_formal_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p1.tex", tex(frag) ctitle("Formal Workers Share") addstat("Polynomial", 1) nonote append 

rdrobust work_informal_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p1.tex", tex(frag) ctitle("Informal Workers Share") addstat("Polynomial", 1) nonote append 

*Mechanisms on migration
rdrobust remittance_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p2.tex", tex(frag) ctitle("Remittances Share") addstat("Polynomial", 1) nonote replace 

rdrobust female_migrant z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Female Migrants") addstat("Polynomial", 1) nonote append 

rdrobust male_migrant z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Male Migrants") addstat("Polynomial", 1) nonote append 

rdrobust total_migrant z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p2.tex", tex(frag) ctitle("Total Migrants") addstat("Polynomial", 1) nonote append 

rdrobust sex_migrant_sh z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p2.tex", tex(frag) ctitle("Migrant's Gender Share") addstat("Polynomial", 1) nonote append 

*Mechanisms on mortality
rdrobust total_dead z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Deceased") addstat("Polynomial", 1) nonote replace 

rdrobust female_dead z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Females Deceased") addstat("Polynomial", 1) nonote append 

rdrobust male_dead z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p3.tex", tex(frag) ctitle("Total Males Deceased") addstat("Polynomial", 1) nonote append 

rdrobust sex_dead_sh z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p3.tex", tex(frag) ctitle("Deceased's Gender Share") addstat("Polynomial", 1) nonote append 

*Mechanisms on demography 
rdrobust total_pop z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Population") addstat("Polynomial", 1) nonote replace 

rdrobust female z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Females") addstat("Polynomial", 1) nonote append 

rdrobust male z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Total Males") addstat("Polynomial", 1) nonote append 

rdrobust sex_sh z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Gender Share") addstat("Polynomial", 1) nonote append 

rdrobust mean_age z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Mean Age") addstat("Polynomial", 1) nonote append 

rdrobust married_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Married Share") addstat("Polynomial", 1) nonote append 

rdrobust had_child_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Fertility Rate") addstat("Polynomial", 1) nonote append 

rdrobust teen_pregnancy_rate z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_cvsd_mechanisms_segm_p4.tex", tex(frag) ctitle("Teenage Pregnancy Rate") addstat("Polynomial", 1) nonote append 
*/