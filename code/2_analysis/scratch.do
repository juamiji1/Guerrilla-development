/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
*Robustness of results using different BW (map 82)
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_pxl_lvl.dta", clear

gl breakfe="fmln_break_fe_400"

*-------------------------------------------------------------------------------
* Within vs. outside any FMLN zone
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
mat coef1=J(3,40,.)
mat coef2=J(3,40,.)
mat coef3=J(3,40,.)
mat coef4=J(3,40,.)
mat coef5=J(3,40,.)
mat coef6=J(3,40,.)

local h=0.1
forval c=1/40{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_fmln/`h')) if abs(z_run_fmln)<=`h'
	
	*Estimating elevation results
	reghdfe elevation2 within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	*Estimating slope results
	reghdfe slope within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)
	
	*Estimating hydrography results
	reghdfe hydrography within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef3[1,`c']= r(estimate) 
	mat coef3[2,`c']= r(lb)
	mat coef3[3,`c']= r(ub)
	
	*Estimating roads results
	reghdfe roads within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef4[1,`c']= r(estimate) 
	mat coef4[2,`c']= r(lb)
	mat coef4[3,`c']= r(ub)
	
	*Estimating rail results
	reghdfe rail within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef5[1,`c']= r(estimate) 
	mat coef5[2,`c']= r(lb)
	mat coef5[3,`c']= r(ub)
			
	*Estimating NL arcsine results
	reghdfe arcsine_nl13 within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef6[1,`c']= r(estimate) 
	mat coef6[2,`c']= r(lb)
	mat coef6[3,`c']= r(ub)
	
	local h=`h'+0.1
}

mat coln coef1= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef2= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef3= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef4= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef5= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef6= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_elev_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_slope_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_hydro_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_road_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef5[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_rail_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef6[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_arcnl_bw_robustness_pxl_82.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
mat coef1=J(3,40,.)
mat coef2=J(3,40,.)
mat coef3=J(3,40,.)
mat coef4=J(3,40,.)
mat coef5=J(3,40,.)
mat coef6=J(3,40,.)

local h=0.1
forval c=1/40{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h'
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	*Estimating slope results
	reghdfe slope within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)
	
	*Estimating hydrography results
	reghdfe hydrography within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef3[1,`c']= r(estimate) 
	mat coef3[2,`c']= r(lb)
	mat coef3[3,`c']= r(ub)
	
	*Estimating roads results
	reghdfe roads within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef4[1,`c']= r(estimate) 
	mat coef4[2,`c']= r(lb)
	mat coef4[3,`c']= r(ub)
	
	*Estimating rail results
	reghdfe rail within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef5[1,`c']= r(estimate) 
	mat coef5[2,`c']= r(lb)
	mat coef5[3,`c']= r(ub)
			
	*Estimating NL arcsine results
	reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef6[1,`c']= r(estimate) 
	mat coef6[2,`c']= r(lb)
	mat coef6[3,`c']= r(ub)
	
	local h=`h'+0.1
}

mat coln coef1= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef2= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef3= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef4= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef5= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef6= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_slope_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_hydro_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_road_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef5[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_rail_bw_robustness_pxl_82.pdf", as(pdf) replace 

coefplot (mat(coef6[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_arcnl_bw_robustness_pxl_82.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
*Robustness of results using different BW (map 91)
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_pxl_lvl_onu_91.dta", clear 

gl breakfe="fmln_break_fe_400"

*-------------------------------------------------------------------------------
* Within vs. outside any FMLN zone
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
mat coef1=J(3,40,.)
mat coef2=J(3,40,.)
mat coef3=J(3,40,.)
mat coef4=J(3,40,.)
mat coef5=J(3,40,.)
mat coef6=J(3,40,.)

local h=0.1
forval c=1/40{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_fmln/`h')) if abs(z_run_fmln)<=`h'
	
	*Estimating elevation results
	reghdfe elevation2 within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	*Estimating slope results
	reghdfe slope within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)
	
	*Estimating hydrography results
	reghdfe hydrography within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef3[1,`c']= r(estimate) 
	mat coef3[2,`c']= r(lb)
	mat coef3[3,`c']= r(ub)
	
	*Estimating roads results
	reghdfe roads within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef4[1,`c']= r(estimate) 
	mat coef4[2,`c']= r(lb)
	mat coef4[3,`c']= r(ub)
	
	*Estimating rail results
	reghdfe rail within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef5[1,`c']= r(estimate) 
	mat coef5[2,`c']= r(lb)
	mat coef5[3,`c']= r(ub)
			
	*Estimating NL arcsine results
	reghdfe arcsine_nl13 within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef6[1,`c']= r(estimate) 
	mat coef6[2,`c']= r(lb)
	mat coef6[3,`c']= r(ub)
	
	local h=`h'+0.1
}

mat coln coef1= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef2= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef3= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef4= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef5= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef6= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_elev_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_slope_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_hydro_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_road_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef5[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_rail_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef6[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_arcnl_bw_robustness_pxl_91.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
mat coef1=J(3,40,.)
mat coef2=J(3,40,.)
mat coef3=J(3,40,.)
mat coef4=J(3,40,.)
mat coef5=J(3,40,.)
mat coef6=J(3,40,.)

local h=0.1
forval c=1/40{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h'
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	*Estimating slope results
	reghdfe slope within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)
	
	*Estimating hydrography results
	reghdfe hydrography within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef3[1,`c']= r(estimate) 
	mat coef3[2,`c']= r(lb)
	mat coef3[3,`c']= r(ub)
	
	*Estimating roads results
	reghdfe roads within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef4[1,`c']= r(estimate) 
	mat coef4[2,`c']= r(lb)
	mat coef4[3,`c']= r(ub)
	
	*Estimating rail results
	reghdfe rail within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef5[1,`c']= r(estimate) 
	mat coef5[2,`c']= r(lb)
	mat coef5[3,`c']= r(ub)
			
	*Estimating NL arcsine results
	reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef6[1,`c']= r(estimate) 
	mat coef6[2,`c']= r(lb)
	mat coef6[3,`c']= r(ub)
	
	local h=`h'+0.1
}

mat coln coef1= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef2= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef3= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef4= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 
mat coln coef5= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
mat coln coef6= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_slope_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_hydro_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_road_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef5[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_rail_bw_robustness_pxl_91.pdf", as(pdf) replace 

coefplot (mat(coef6[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_arcnl_bw_robustness_pxl_91.pdf", as(pdf) replace 










*END
