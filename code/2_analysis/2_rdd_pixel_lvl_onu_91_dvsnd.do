/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Spatial RDD at the night light pixel level 
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
*Night light density distribution to put in context the results found:
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_pxl_lvl_onu_91.dta", clear

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
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}

*Lat-lon
reghdfe arcsine_nl13 within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd.tex", tex(frag) keep(within_control) ctitle("Arcsine(Night Light)") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

*Dist poly 
reghdfe arcsine_nl13 within_control z_run_cntrl i.within_control#c.z_run_cntrl [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd.tex", tex(frag) keep(within_control) ctitle("Arcsine(Night Light)") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Lat-lon & dist
reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200) 
outreg2 using "${tables}\rdd_dvsnd.tex", tex(frag) keep(within_control) ctitle("Arcsine(Night Light)") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

*Plot of dist poly 
rdplot arcsine_nl13 z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(legend(off) xtitle("Normalized distance to the nearest FMLN-dominated zone border", size(small)) ytitle("Average night light density within bin", size(small)) title(""))
gr export "${plots}\rdplot_dvsnd.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Sharp RDD results under different bw:
*-------------------------------------------------------------------------------
*Creating matrices to export estimates
mat coef1=J(3,25,.)

local h=0.2
forval c=1/25{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h'
	
	*Estimating results
	reghdfe arcsine_nl13 within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h', vce(r) a(i.control_break_fe_200)
	lincom within_control	
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)
	
	local h=`h'+0.2
}

mat coln coef1= .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within FMLN-dominated zone") color(maroon)), vert recast(connected) ciopts(recast(rcap) color(maroon)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-.3(.05).05) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") legend(size(small)) 
gr export "${plots}\rdd_dvsnd_bw_robustness.pdf", as(pdf) replace 


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

rdrobust elevation z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe elevation within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_elev.tex", tex(frag) keep(within_control) ctitle("Elevation") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe elevation within_control z_run_cntrl i.within_control#c.z_run_cntrl [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_elev.tex", tex(frag) keep(within_control) ctitle("Elevation") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe elevation within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200) 
outreg2 using "${tables}\rdd_dvsnd_elev.tex", tex(frag) keep(within_control) ctitle("Elevation") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

rdplot elevation z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(legend(off) xtitle("Normalized distance to the nearest FMLN-dominated zone border", size(small)) ytitle("Average elevation within bin", size(small)) title(""))
gr export "${plots}\rdplot_dvsnd_elev.pdf", as(pdf) replace 

*Hydrography
summ hydrography, d
gl mean_nl=round(r(mean), .01)

rdrobust hydrography z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe hydrography within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_hydro.tex", tex(frag) keep(within_control) ctitle("Hydrography") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe hydrography within_control z_run_cntrl i.within_control#c.z_run_cntrl [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_hydro.tex", tex(frag) keep(within_control) ctitle("Hydrography") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe hydrography within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200) 
outreg2 using "${tables}\rdd_dvsnd_hydro.tex", tex(frag) keep(within_control) ctitle("Hydrography") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

rdplot hydrography z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(legend(off) xtitle("Normalized distance to the nearest FMLN-dominated zone border", size(small)) ytitle("Average hydrography within bin", size(small)) title(""))
gr export "${plots}\rdplot_dvsnd_hydro.pdf", as(pdf) replace 

*Cacao
summ cacao, d
gl mean_nl=round(r(mean), .01)

rdrobust cacao z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe cacao within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_cacao.tex", tex(frag) keep(within_control) ctitle("Cacao Yield") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe cacao within_control z_run_cntrl i.within_control#c.z_run_cntrl [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_cacao.tex", tex(frag) keep(within_control) ctitle("Cacao Yield") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe cacao within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200) 
outreg2 using "${tables}\rdd_dvsnd_cacao.tex", tex(frag) keep(within_control) ctitle("Cacao Yield") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

rdplot cacao z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(legend(off) xtitle("Normalized distance to the nearest FMLN-dominated zone border", size(small)) ytitle("Average cacao yield within bin", size(small)) title(""))
gr export "${plots}\rdplot_dvsnd_cacao.pdf", as(pdf) replace 

*Bean
summ bean, d
gl mean_nl=round(r(mean), .01)

rdrobust bean z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe bean within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_bean.tex", tex(frag) keep(within_control) ctitle("Bean Yield") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe bean within_control z_run_cntrl i.within_control#c.z_run_cntrl [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_bean.tex", tex(frag) keep(within_control) ctitle("Bean Yield") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe bean within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200) 
outreg2 using "${tables}\rdd_dvsnd_bean.tex", tex(frag) keep(within_control) ctitle("Bean Yield") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

rdplot bean z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(legend(off) xtitle("Normalized distance to the nearest FMLN-dominated zone border", size(small)) ytitle("Average bean yield within bin", size(small)) title(""))
gr export "${plots}\rdplot_dvsnd_bean.pdf", as(pdf) replace 

*Rail and roads
summ rail_road, d
gl mean_nl=round(r(mean), .01)

rdrobust rail_road z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) if abs(z_run_cntrl)<=${h}
	
reghdfe rail_road within_control x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_rail.tex", tex(frag) keep(within_control ) ctitle("Roads or Railway") addtext("Controls","Lat-Lon", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons replace 

reghdfe rail_road within_control z_run_cntrl i.within_control#c.z_run_cntrl [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200)
outreg2 using "${tables}\rdd_dvsnd_rail.tex", tex(frag) keep(within_control ) ctitle("Roads or Railway") addtext("Controls","Distance", "Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

reghdfe rail_road within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=${h}, vce(r) a(i.control_break_fe_200) 
outreg2 using "${tables}\rdd_dvsnd_rail.tex", tex(frag) keep(within_control ) ctitle("Roads or Railway") addtext("Controls" ,"Lat-Lon, Dist","Break FE", "Yes", "Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "Dependent mean", ${mean_nl}) label nonote nocons append 

rdplot rail_road z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(legend(off) xtitle("Normalized distance to the nearest FMLN-dominated zone border", size(small)) ytitle("Average roads or railway within bin", size(small)) title(""))
gr export "${plots}\rdplot_dvsnd_rail.pdf", as(pdf) replace 









*END
