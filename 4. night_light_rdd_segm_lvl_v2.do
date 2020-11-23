/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Spatial RDD of Night Light Density 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development"
gl path "C:\Users\jmjimenez\Dropbox\Mica-projects\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}

*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${maps}/night_lights/slvShp_segm_info_sp", data("${data}/slvShp_segm_info_sp.dta") coord("${data}/slvShp_segm_info_coord.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "slvShp_segm_info_sp.dta", clear

*Keeping only important vars 
keep pixel_id wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_nl mean_lv mean_cc-min_ben lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2
rename (wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_nl mean_lv mean_cc mean_bn med_nl med_elv med_cac med_ben max_nl max_elv max_cac max_ben min_nl min_elv min_cac min_ben lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2) (within_control_v2 within_expansion_v2 within_disputed_v2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 nl13_density elevation cacao bean md_nl13 md_elevation md_cacao md_bean max_nl13 max_elevation max_cacao max_bean min_nl13 min_elevation min_cacao min_bean lake river1 river2 dist_control dist_expansion dist_disputed within_control within_expansion within_disputed)

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*HERE I AM USING THE VERSION 2 VARS
ren (dist_control dist_expansion dist_disputed within_control within_expansion within_disputed) (dist_control_v1 dist_expansion_v1 dist_disputed_v1 within_control_v1 within_expansion_v1 within_disputed_v1)
ren (dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2) (dist_control dist_expansion dist_disputed within_control within_expansion within_disputed)

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_expansion=dist_expansion/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn= dist_expansion 
replace z_run_xpsn= -1*dist_expansion if within_expansion==0

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)

*Labelling for results 
la var nl13_density "Night light density (2013)"
la var z_run_cntrl "Distance to nearest control zone (v2)"
la var z_run_xpsn "Distance to nearest expansion zone (v2)"
la var z_run_dsptd "Distance to nearest disputed zone (v2)"

*-------------------------------------------------------------------------------
*Night light density distribution to put in context the results found:
*-------------------------------------------------------------------------------
*Summary statistics
summ nl13_density, d
tabstat nl13_density dist_control dist_expansion dist_disputed, s(N mean sd min p1 p5 p10 p25 p50 p75 p90 p95 p99 max) save
tabstatmat A

tempfile X
frmttable using `X', s(A) ctitle("Stat", "Night light", "Distance to nearest", "Distance to nearest", "Distance to nearest" \ "", "density (2013)", "control zone", "expansion zone", "disputed zone") tex fragment nocenter replace 
filefilter `X' "${tables}\summary_stats_segm_v2.tex", from("r}\BS\BS") to("r}") replace

*Test of means between groups (formatting?)
do "${do}/0. my_ttest.do"
my_ttest nl13_density, by(treat_cntrl)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(SD)", "(SD)", "(p-value)†") fragment tex nocenter
filefilter `X' "${tables}\ttest_treat_cntrl_segm_v2.tex", from("r}\BS\BS") to("r}") replace

*Checking the distribution 
hist nl13_density, freq graphregion(color(white)) 
gr export "${plots}\hist_nl_13_segm_v2.pdf", as(pdf) replace 

*Comparing to other functions of aggregating night light
tabstat nl13_density md_nl13 max_nl13 min_nl13, s(N mean sd min p50 max)


*-------------------------------------------------------------------------------
* 					Spatial RDD of Night Light Density
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* No manipulation Test:
*-------------------------------------------------------------------------------
*On control zones 
kdensity z_run_cntrl, graphregion(color(white)) xtitle("Normalized distance to the nearest controlled zone border") title("")
gr export "${plots}\kden_z_run_cntrl_segm_v2.pdf", as(pdf) replace 

rddensity z_run_cntrl
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_cntrl, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_cntrl_segm_v2.pdf", as(pdf) replace 

*On expansion zones
kdensity z_run_xpsn, graphregion(color(white)) xtitle("Normalized distance to the nearest expansion zone border") title("")
gr export "${plots}\kden_z_run_xpsn_segm_v2.pdf", as(pdf) replace 

rddensity z_run_xpsn
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_xpsn, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest expansion zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_xpsn_segm_v2.pdf", as(pdf) replace 

*On disputed zones
kdensity z_run_dsptd, graphregion(color(white)) xtitle("Normalized distance to the nearest disputed zone border") title("")
gr export "${plots}\kden_z_run_dsptd_segm_v2.pdf", as(pdf) replace 

rddensity z_run_dsptd
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_dsptd, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest disputed zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_dsptd_segm_v2.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Local continuity assumption:
*-------------------------------------------------------------------------------
*Between pixels within and outside controlled FMLN zones 
rdrobust elevation z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_segm_v2.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust hydrography z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_segm_v2.tex", tex(frag) ctitle("Hydrography") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust cacao z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_segm_v2.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_segm_v2.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within FMLN zones and disputed zones (not including pixels in expansion zones)
rdrobust elevation z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm_v2.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust hydrography z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm_v2.tex", tex(frag) ctitle("Hydrography") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust cacao z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm_v2.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm_v2.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust elevation z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm_v2.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust hydrography z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm_v2.tex", tex(frag) ctitle("Hydrography") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust cacao z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm_v2.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm_v2.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within and outside expansion FMLN zones (not including pixels in controlled and disputed zones)
rdrobust elevation z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_segm_v2.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust hydrography z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_segm_v2.tex", tex(frag) ctitle("Hydrography") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust cacao z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_segm_v2.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_segm_v2.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*-------------------------------------------------------------------------------
* Sharp RDD results:
*-------------------------------------------------------------------------------
*Checking the methodology
rdrobust nl13_density z_run_cntrl, all p(0) kernel(uniform)
local h=e(h_l) 
reg nl13_density treat_cntrl if abs(z_run_cntrl)<=`h' 				// So the OLS estimate is the conventional one in the rdd. It Shows the difference between treated and untreated.

*Between pixels within and outside controlled FMLN zones 
rdrobust nl13_density z_run_cntrl, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdmse nl13_density z_run_cntrl, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cntrl_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_cntrl, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cntrl_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_cntrl, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cntrl_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_cntrl, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_cntrl_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_cntrl, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_cntrl_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

mat coef=J(3,25,.)
local h=0.2
local lab=""
forval c=1/25{
	rdrobust nl13_density z_run_cntrl, all p(1) h(`h') kernel(triangular)
	mat coef[1,`c']= e(tau_bc)
	mat coef[2,`c']= e(ci_l_rb)
	mat coef[3,`c']= e(ci_r_rb)
	
	local h2=substr("`h'",1,3)
	local lab="`lab' `h2'"
	*dis "`lab'"
	
	local h=`h'+0.2
}

mat coln coef= .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5

coefplot (mat(coef[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-12(2)12) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") graphregion(color(white))
gr export "${plots}\rdd_z_run_cntrl_segm_h_robustness_v2.pdf", as(pdf) replace 

*Between pixels within FMLN zones and disputed zones (not including pixels in expansion zones)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdmse nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_cvsd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_cvsd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

mat coef=J(3,25,.)
local h=0.2
local lab=""
forval c=1/25{
	rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) h(`h') kernel(triangular)
	mat coef[1,`c']= e(tau_bc)
	mat coef[2,`c']= e(ci_l_rb)
	mat coef[3,`c']= e(ci_r_rb)
	
	local h2=substr("`h'",1,3)
	local lab="`lab' `h2'"
	*dis "`lab'"
	
	local h=`h'+0.2
}

mat coln coef= .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5

coefplot (mat(coef[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-12(2)12) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") graphregion(color(white))
gr export "${plots}\rdd_z_run_cvsd_segm_h_robustness_v2.pdf", as(pdf) replace 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

mat coef=J(3,25,.)
local h=0.2
local lab=""
forval c=1/25{
	rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(1) h(`h') kernel(triangular)
	mat coef[1,`c']= e(tau_bc)
	mat coef[2,`c']= e(ci_l_rb)
	mat coef[3,`c']= e(ci_r_rb)
	
	local h2=substr("`h'",1,3)
	local lab="`lab' `h2'"
	*dis "`lab'"
	
	local h=`h'+0.2
}

mat coln coef= .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5

coefplot (mat(coef[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-12(2)22) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") graphregion(color(white))
gr export "${plots}\rdd_z_run_dvsnd_segm_h_robustness_v2.pdf", as(pdf) replace 

*Between pixels within and outside expansion FMLN zones (not including pixels in controlled and disputed zones)
rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdmse nl13_density z_run_xpsn if within_disputed==0 & within_control==0, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_xvsnx_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_xpsn if within_disputed==0 & within_control==0, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_xvsnx_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_xpsn if within_disputed==0 & within_control==0, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_xvsnx_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_xvsnx_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_xvsnx_segm_v2.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

*------------------------------------------------------------------------------
* Sharp RDD plots:
*-------------------------------------------------------------------------------
*For control zones
rdrobust nl13_density z_run_cntrl, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdplot nl13_density z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p1_z_run_cntrl_segm_v2.pdf", as(pdf) replace 

rdplot nl13_density z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(2) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p2_z_run_cntrl_segm_v2.pdf", as(pdf) replace 

*Between pixels within FMLN zones and disputed zones (not including pixels in expansion zones)
rdrobust nl13_density z_run_cntrl if within_expansion==0, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdplot nl13_density z_run_cntrl if within_expansion==0 & abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p1_z_run_cvsd_segm_v2.pdf", as(pdf) replace 

rdplot nl13_density z_run_cntrl if within_expansion==0 & abs(z_run_cntrl)<=${h}, all p(2) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p2_z_run_cvsd_segm_v2.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* 					What's the @%$@!@$% difference?
*
*-------------------------------------------------------------------------------
ren (dist_control dist_expansion dist_disputed within_control within_expansion within_disputed) (dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2)

replace dist_control_v1=dist_control_v1/1000
replace dist_expansion_v1=dist_expansion_v1/1000
replace dist_disputed_v1=dist_disputed_v1/1000

gen z_run_cntrl_v1= dist_control_v1 
replace z_run_cntrl_v1= -1*dist_control_v1 if within_control_v1==0 	

la var dist_control_v1 ""
la var dist_control_v2 ""
la var dist_expansion_v1 ""
la var dist_expansion_v2 ""
la var dist_disputed_v1 ""
la var dist_disputed_v2 ""
la var within_control_v1 ""
la var within_control_v2 ""
la var within_expansion_v1 ""
la var within_expansion_v2 ""
la var within_disputed_v1 ""
la var within_disputed_v2 ""


tab within_control_v1 within_control_v2, row m
tab within_disputed_v1 within_disputed_v2, row m
tab within_expansion_v1 within_expansion_v2, row m

gen diff_dist_control=dist_control_v1-dist_control_v2
gen diff_dist_expansion=dist_expansion_v1-dist_expansion_v2
gen diff_dist_disputed=dist_disputed_v1-dist_disputed_v2

summ diff_dist_control dist_control_v1 dist_control_v2, d



rdrobust nl13_density z_run_cntrl if abs(z_run_cntrl)>0.1, all kernel(triangular)

rdrobust nl13_density z_run_cntrl_v1, all kernel(triangular)

tabstat nl13_density if within_control_v1==1 & within_control_v2==0, s(N mean min p50 max) 
tabstat nl13_density if within_control_v1==1 & within_control_v2==1, s(N mean min p50 max)
tabstat nl13_density if within_control_v1==0 & within_control_v2==0, s(N mean min p50 max)

hist z_run_cntrl, freq
hist z_run_cntrl_v1, freq







*END

