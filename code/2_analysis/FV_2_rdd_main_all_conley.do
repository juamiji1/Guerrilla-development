/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating main outcomes but with conley SE
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* 						Conley (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl main "arcsine_nl13 z_wi mean_educ_years"

*Erasing table before exporting
cap erase "${tables}\rdd_main_all_conley2kms.tex"
cap erase "${tables}\rdd_main_all_conley2kms.txt"
cap erase "${tables}\rdd_main_all_conley500kms.tex"
cap erase "${tables}\rdd_main_all_conley500kms.txt"
cap erase "${tables}\rdd_main_all_conley4kms.tex"
cap erase "${tables}\rdd_main_all_conley4kms.txt"

*Creating needed vars bc the command does not accept factor vars
gen wcxz=within_control*z_run_cntrl 
tab control_break_fe_400, g(fe_)

*New globals to use 
gl controls "within_control wcxz z_run_cntrl"

*Estimation with Conley SE
foreach var of global main{

	*Actual estimations using acreg package 
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(.5) pfe1(${breakfe}) dropsingletons 
	outreg2 using "${tables}\rdd_main_all_conley500kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 0.5) label nonote nocons append 
	
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(2) pfe1(${breakfe})  dropsingletons 
	outreg2 using "${tables}\rdd_main_all_conley2kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 2) label nonote nocons append 	
	
	acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(4) pfe1(${breakfe}) dropsingletons 
	outreg2 using "${tables}\rdd_main_all_conley4kms.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Conley (Kms)", 4) label nonote nocons append 

}

*-------------------------------------------------------------------------------
* 				Main outcomes under different Conley (Plot)
*-------------------------------------------------------------------------------
*Plot of many Conley SE under different distance thresholds 
foreach var of global main{
		
	mat coef=J(3,20,.)
		
	local h=0.5
	forval c=1/20{
		
		*Total Households
		acreg `var' ${controls} [pw=tweights] ${if}, spatial latitude(y_coord) longitude(x_coord) dist(`h') pfe1(${breakfe}) dropsingletons 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+0.5
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef= .5 1 1.5 2 2.5 3 3.5 4 4.5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 

	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), ///
		vert recast(line) lwidth(*2) color(gs2%70) ///
		ciopts(recast(rarea) lpattern(dash) color(gs6%40)) ///
		yline(0) yscale(range(0 .)) ///
		ylabel(, labsize(small)) xlabel(, labsize(small)) ///
		l2title("Coeficient magnitud") b2title("Threshold chosen for Conley SE in Kms") ///
		name(`var', replace)
		
	gr export "${plots}\rdd_all_`var'_conley.pdf", as(pdf) replace 

}

*-------------------------------------------------------------------------------
* 		 Main outcomes under different grid-resolution clusters (Plot)
*-------------------------------------------------------------------------------
*Changing grid level resolution
gen lon_001 = round(x_coord / 0.01) * 0.01
gen lat_001 = round(y_coord / 0.01) * 0.01

gen lon_005 = round(x_coord / 0.05) * 0.05
gen lat_005 = round(y_coord / 0.05) * 0.05

gen lon_01 = round(x_coord / 0.1) * 0.1
gen lat_01 = round(y_coord / 0.1) * 0.1

gen latlon_001=lat_001*lon_001
gen latlon_005=lat_005*lon_005
gen latlon_01=lat_01*lon_01

*Creating matrix to export estimates
mat coef1=J(4,3,.)
mat coef2=J(4,3,.)
mat coef3=J(4,3,.)

*Results with a 0.01^o degrees of resolution (around 1.2 Km2)
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(cl i.lon_001#i.lat_001) a(i.${breakfe}) 
unique latlon_001 if e(sample)==1

cap drop n001 n_latlon001
gen n001=1 if e(sample)==1
bys latlon_001: egen n_latlon001=total(n001)

preserve
	collapse arcsine_nl13, by(latlon_001 n_latlon001)
	replace n_latlon001=. if n_latlon001==0
	summ n_latlon001, d
restore 

lincom within_control	
mat coef1[1,1]= r(estimate) 
mat coef1[2,1]= r(lb)
mat coef1[3,1]= r(ub)
mat coef1[4,1]= r(p)

*Results with a 0.05^o degrees of resolution (around 6 Km2)
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(cl i.lon_005#i.lat_005) a(i.${breakfe}) 
unique latlon_005 if e(sample)==1

cap drop n005 n_latlon005
gen n005=1 if e(sample)==1
bys latlon_005: egen n_latlon005=total(n005)

preserve
	collapse arcsine_nl13, by(latlon_005 n_latlon005)
	replace n_latlon005=. if n_latlon005==0
	summ n_latlon005, d
restore 

lincom within_control	
mat coef1[1,2]= r(estimate) 
mat coef1[2,2]= r(lb)
mat coef1[3,2]= r(ub)
mat coef1[4,2]= r(p)

*Results with a 0.1^o degrees of resolution (around 12 Km2)
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(cl i.lon_01#i.lat_01) a(i.${breakfe}) 
unique latlon_01 if e(sample)==1

cap drop n01 n_latlon01
gen n01=1 if e(sample)==1
bys latlon_01: egen n_latlon01=total(n01)

preserve
	collapse arcsine_nl13, by(latlon_01 n_latlon01)
	replace n_latlon01=. if n_latlon01==0
	summ n_latlon01, d
restore 

lincom within_control	
mat coef1[1,3]= r(estimate) 
mat coef1[2,3]= r(lb)
mat coef1[3,3]= r(ub)
mat coef1[4,3]= r(p)

*Rest of variables
reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(cl i.lon_001#i.lat_001) a(i.${breakfe}) 
lincom within_control	
mat coef2[1,1]= r(estimate) 
mat coef2[2,1]= r(lb)
mat coef2[3,1]= r(ub)
mat coef2[4,1]= r(p)

reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(cl i.lon_005#i.lat_005) a(i.${breakfe})
lincom within_control	
mat coef2[1,2]= r(estimate) 
mat coef2[2,2]= r(lb)
mat coef2[3,2]= r(ub)
mat coef2[4,2]= r(p)
 
reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(cl i.lon_01#i.lat_01) a(i.${breakfe}) 
lincom within_control	
mat coef2[1,3]= r(estimate) 
mat coef2[2,3]= r(lb)
mat coef2[3,3]= r(ub)
mat coef2[4,3]= r(p)

reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(cl i.lon_001#i.lat_001) a(i.${breakfe})
lincom within_control	
mat coef3[1,1]= r(estimate) 
mat coef3[2,1]= r(lb)
mat coef3[3,1]= r(ub)
mat coef3[4,1]= r(p)
 
reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(cl i.lon_005#i.lat_005) a(i.${breakfe}) 
lincom within_control	
mat coef3[1,2]= r(estimate) 
mat coef3[2,2]= r(lb)
mat coef3[3,2]= r(ub)
mat coef3[4,2]= r(p)

reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(cl i.lon_01#i.lat_01) a(i.${breakfe}) 
lincom within_control	
mat coef3[1,3]= r(estimate) 
mat coef3[2,3]= r(lb)
mat coef3[3,3]= r(ub)
mat coef3[4,3]= r(p)

*Coefplot
coefplot (mat(coef1[1]), ci((2 3)) aux(4) msymbol(circle) mcolor(gs6) label("Night Light")) ///
	(mat(coef2[1]), ci((2 3)) aux(4) msymbol(triangle) mcolor(gs6) label("Wealth Index")) ///
	(mat(coef3[1]), ci((2 3)) aux(4) msymbol(diamond) mcolor(gs6) label("Years of Education")), /// 
	yline(0, lc("black")) vert ciopts(recast(rcap) lcolor(gs6)) citop ///
	xlabel( 1 "0.01° (~1.2 Km²)" 2 "0.05° (~6 Km²)" 3 "0.1° (~12 Km²)", labsize(medsmall)) ///
	l2title("Coeficient magnitud") b2title("Grid resolution of spatial clusters") ///
	ylabel(, format(%9.2f)) legend(position(6) rows(1)) ///
	mlabel(cond(@aux1<=.01,"***", cond(@aux1<=.05,"**", cond(@aux1<=.1,"*", cond(@aux1<=.15,"†",""""))))) ///
	mlabposition(3) mlabcolor(black) mlabsize(medsmall)

gr export "${plots}\rdd_main_all_gridcluster.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* 		 Main outcomes under different admin clusters (Plot)
*-------------------------------------------------------------------------------
encode muni_name, gen(cod_muni)

*Creating matrix to export estimates
mat coef1=J(4,2,.)
mat coef2=J(4,2,.)
mat coef3=J(4,2,.)

* Loop over each outcome
local i = 1
foreach var of global main {

    * === Robust SE ===
    reghdfe `var' ${controls} [aw=tweights] ${if}, vce(robust) a(i.${breakfe})
    lincom within_control
    mat coef`i'[1,1] = r(estimate)
    mat coef`i'[2,1] = r(lb)
    mat coef`i'[3,1] = r(ub)
    mat coef`i'[4,1] = r(p)

    * === Clustered SE ===
    reghdfe `var' ${controls} [aw=tweights] ${if}, vce(cluster i.cod_muni) a(i.${breakfe})
    lincom within_control
    mat coef`i'[1,2] = r(estimate)
    mat coef`i'[2,2] = r(lb)
    mat coef`i'[3,2] = r(ub)
    mat coef`i'[4,2] = r(p)

    * Increment counter
    local ++i
}

*Coefplot
coefplot (mat(coef1[1]), ci((2 3)) aux(4) msymbol(circle) mcolor(gs6) label("Night Light")) ///
	(mat(coef2[1]), ci((2 3)) aux(4) msymbol(triangle) mcolor(gs6) label("Wealth Index")) ///
	(mat(coef3[1]), ci((2 3)) aux(4) msymbol(diamond) mcolor(gs6) label("Years of Education")), /// 
	yline(0, lc("black")) vert ciopts(recast(rcap) lcolor(gs6)) citop ///
	xlabel( 1 "Robust" 2 "Cluster by municipality", labsize(medsmall)) ///
	l2title("Coeficient magnitud") b2title("Type of SE") ///
	ylabel(, format(%9.2f)) legend(position(6) rows(1)) ///
	mlabel(cond(@aux1<=.01,"***", cond(@aux1<=.05,"**", cond(@aux1<=.1,"*", cond(@aux1<=.15,"†",""""))))) ///
	mlabposition(3) mlabcolor(black) mlabsize(medsmall)

gr export "${plots}\rdd_main_all_admincluster.pdf", as(pdf) replace 





*END