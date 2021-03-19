/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Spatial RDD at the census segment level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
*Night light density distribution to put in context the results found:
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*-------------------------------------------------------------------------------
* 						Spatial RDD results
*
*-------------------------------------------------------------------------------
*Summary statistics
summ arcsine_nl13, d
gl mean_nl=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Sharp RDD results:
*-------------------------------------------------------------------------------
*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_fmln, all kernel(triangular)
gl h=e(h_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}

*Lat-lon
reghdfe arcsine_nl13 within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Arcsine(Night Light)") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Dist poly 
reghdfe arcsine_nl13 within_fmln within_control z_run_fmln i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Arcsine(Night Light)") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Lat-lon & dist
reghdfe arcsine_nl13 within_fmln within_control i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200) 
outreg2 using "${tables}\rdd_gvsng_interac_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Arcsine(Night Light)") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*-------------------------------------------------------------------------------
* Sharp RDD results under different bw:
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
mat coef1=J(3,25,.)
mat coef2=J(3,25,.)

local h=0.2
forval c=1/25{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_fmln/`h')) if abs(z_run_fmln)<=`h'
	
	*Estimating results
	reghdfe arcsine_nl13 within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=`h', vce(r) a(i.fmln_break_fe_200)
	lincom within_fmln	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	lincom within_control	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)
	
	local h=`h'+0.2
}

mat coln coef1= .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5
mat coln coef2= .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within any FMLN zone")) (mat(coef2[1]), ci((2 3)) label("Within FMLN-controlled zone")), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-.4(.05)0) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") legend(size(small)) 
gr export "${plots}\rdd_gvsng_interac_bw_robustness_segm.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* 					Checking Assumptions for the Spatial RDD 
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Local continuity assumption:
*-------------------------------------------------------------------------------
*Elevation
summ elevation, d
gl mean_nl=round(r(mean), .01)

rdrobust elevation z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe elevation within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_elev_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Elevation") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe elevation within_fmln within_control z_run_fmln i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_elev_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Elevation") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe elevation within_fmln within_control i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200) 
outreg2 using "${tables}\rdd_gvsng_interac_elev_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Elevation") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Hydrography
summ hydrography, d
gl mean_nl=round(r(mean), .01)

rdrobust hydrography z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe hydrography within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_hydro_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Hydrography") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe hydrography within_fmln within_control z_run_fmln i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_hydro_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Hydrography") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe hydrography within_fmln within_control i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200) 
outreg2 using "${tables}\rdd_gvsng_interac_hydro_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Hydrography") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Cacao
summ cacao, d
gl mean_nl=round(r(mean), .01)

rdrobust cacao z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe cacao within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_cacao_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Cacao Yield") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe cacao within_fmln within_control z_run_fmln i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_cacao_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Cacao Yield") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe cacao within_fmln within_control i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200) 
outreg2 using "${tables}\rdd_gvsng_interac_cacao_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Cacao Yield") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Bean
summ bean, d
gl mean_nl=round(r(mean), .01)

rdrobust bean z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe bean within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_bean_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Bean Yield") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe bean within_fmln within_control z_run_fmln i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_bean_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Bean Yield") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe bean within_fmln within_control i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200) 
outreg2 using "${tables}\rdd_gvsng_interac_bean_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Bean Yield") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Rail and roads
summ rail_road, d
gl mean_nl=round(r(mean), .01)

rdrobust rail_road z_run_fmln, all p(1) kernel(triangular)
gl h=e(h_l) 

cap drop tweights
gen tweights=(1-abs(z_run_fmln/${h})) if abs(z_run_fmln)<=${h}
	
reghdfe rail_road within_fmln within_control x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_rail_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Roads or Railway") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe rail_road within_fmln within_control z_run_fmln i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200)
outreg2 using "${tables}\rdd_gvsng_interac_rail_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Roads or Railway") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe rail_road within_fmln within_control i.within_fmln#c.z_run_fmln i.within_control#c.z_run_fmln z_run_fmln x_coord y_coord [aw=tweights] if abs(z_run_fmln)<=${h}, vce(r) a(i.fmln_break_fe_200) 
outreg2 using "${tables}\rdd_gvsng_interac_rail_segm.tex", tex(frag) keep(within_fmln within_control) ctitle("Roads or Railway") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 









*END
