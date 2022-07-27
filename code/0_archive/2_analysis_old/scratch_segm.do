/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
*Robustness of results using different BW (map 91)
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear 

gl breakfe="fmln_break_fe_400"

*-------------------------------------------------------------------------------
* Within vs. outside any FMLN zone
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
forval i=1/18{
	mat coef`i'=J(3,40,.)
}

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
	
	*Estimating bean arcsine results
	reghdfe cacao within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef6[1,`c']= r(estimate) 
	mat coef6[2,`c']= r(lb)
	mat coef6[3,`c']= r(ub)
	
	*Estimating cacao arcsine results
	reghdfe bean within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef7[1,`c']= r(estimate) 
	mat coef7[2,`c']= r(lb)
	mat coef7[3,`c']= r(ub)
	
	*Estimating cocoa results
	reghdfe mean_cocoa within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef8[1,`c']= r(estimate) 
	mat coef8[2,`c']= r(lb)
	mat coef8[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_bean2 within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef9[1,`c']= r(estimate) 
	mat coef9[2,`c']= r(lb)
	mat coef9[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_coffee within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef10[1,`c']= r(estimate) 
	mat coef10[2,`c']= r(lb)
	mat coef10[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_cotton within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef11[1,`c']= r(estimate) 
	mat coef11[2,`c']= r(lb)
	mat coef11[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_dryrice within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef12[1,`c']= r(estimate) 
	mat coef12[2,`c']= r(lb)
	mat coef12[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_maize within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef13[1,`c']= r(estimate) 
	mat coef13[2,`c']= r(lb)
	mat coef13[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_soybean within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef14[1,`c']= r(estimate) 
	mat coef14[2,`c']= r(lb)
	mat coef14[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_sugarcane within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef15[1,`c']= r(estimate) 
	mat coef15[2,`c']= r(lb)
	mat coef15[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_wetrice within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef16[1,`c']= r(estimate) 
	mat coef16[2,`c']= r(lb)
	mat coef16[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_wheat within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef17[1,`c']= r(estimate) 
	mat coef17[2,`c']= r(lb)
	mat coef17[3,`c']= r(ub)
	
	*Estimating NL arcsine results
	reghdfe arcsine_nl13 within_fmln i.within_fmln#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_fmln	
	mat coef18[1,`c']= r(estimate) 
	mat coef18[2,`c']= r(lb)
	mat coef18[3,`c']= r(ub)
	
	local h=`h'+0.1
}

forval i=1/18{
	mat coln coef`i'= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
}


*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_elev_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_slope_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_hydro_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_road_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef5[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_rail_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef6[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_cacao_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef7[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_bean_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef8[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_cocoa_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef9[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_bean2_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef11[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_coffee_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef11[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_cotton_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef12[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_drice_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef13[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_maize_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef14[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_soybean_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef15[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_sugarcane_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef16[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_wrice_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef17[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_wheat_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef18[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_gvsng_arcnl_bw_robustness_segm_91.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
forval i=1/18{
	mat coef`i'=J(3,40,.)
}

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
			
	*Estimating bean arcsine results
	reghdfe cacao within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef6[1,`c']= r(estimate) 
	mat coef6[2,`c']= r(lb)
	mat coef6[3,`c']= r(ub)
	
	*Estimating cacao arcsine results
	reghdfe bean within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef7[1,`c']= r(estimate) 
	mat coef7[2,`c']= r(lb)
	mat coef7[3,`c']= r(ub)
	
	*Estimating cocoa results
	reghdfe mean_cocoa within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef8[1,`c']= r(estimate) 
	mat coef8[2,`c']= r(lb)
	mat coef8[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_bean2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef9[1,`c']= r(estimate) 
	mat coef9[2,`c']= r(lb)
	mat coef9[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_coffee within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef10[1,`c']= r(estimate) 
	mat coef10[2,`c']= r(lb)
	mat coef10[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_cotton within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef11[1,`c']= r(estimate) 
	mat coef11[2,`c']= r(lb)
	mat coef11[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_dryrice within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef12[1,`c']= r(estimate) 
	mat coef12[2,`c']= r(lb)
	mat coef12[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_maize within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef13[1,`c']= r(estimate) 
	mat coef13[2,`c']= r(lb)
	mat coef13[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_soybean within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef14[1,`c']= r(estimate) 
	mat coef14[2,`c']= r(lb)
	mat coef14[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_sugarcane within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef15[1,`c']= r(estimate) 
	mat coef15[2,`c']= r(lb)
	mat coef15[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_wetrice within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef16[1,`c']= r(estimate) 
	mat coef16[2,`c']= r(lb)
	mat coef16[3,`c']= r(ub)
	
	*Estimating bean2 arcsine results
	reghdfe mean_wheat within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef17[1,`c']= r(estimate) 
	mat coef17[2,`c']= r(lb)
	mat coef17[3,`c']= r(ub)
	
	*Estimating NL arcsine results
	reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef18[1,`c']= r(estimate) 
	mat coef18[2,`c']= r(lb)
	mat coef18[3,`c']= r(ub)
	
	local h=`h'+0.1
}

forval i=1/18{
	mat coln coef`i'= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
}

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_slope_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_hydro_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef4[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_road_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef5[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_rail_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef6[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_cacao_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef7[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_bean_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef8[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_cocoa_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef9[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_bean2_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef11[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_coffee_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef11[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_cotton_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef12[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_drice_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef13[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_maize_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef14[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_soybean_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef15[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_sugarcane_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef16[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_wrice_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef17[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_wheat_bw_robustness_segm_91.pdf", as(pdf) replace 

coefplot (mat(coef18[1]), ci((2 3)) label("Within any FMLN zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)")
gr export "${plots}\rdd_dvsnd_arcnl_bw_robustness_segm_91.pdf", as(pdf) replace 







*END
