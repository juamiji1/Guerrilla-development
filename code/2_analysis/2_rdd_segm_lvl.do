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
*	 Night light density distribution to put in context the results found
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl.dta", clear

*Summary statistics
summ nl13_density, d
tabstat nl13_density dist_control dist_expansion dist_disputed, s(N mean sd min p1 p5 p10 p25 p50 p75 p90 p95 p99 max) save
tabstatmat A

tempfile X
frmttable using `X', s(A) ctitle("Stat", "Night light", "Distance to nearest", "Distance to nearest", "Distance to nearest" \ "", "density (2013)", "control zone", "expansion zone", "disputed zone") tex fragment nocenter replace 
filefilter `X' "${tables}\summary_stats_segm.tex", from("r}\BS\BS") to("r}") replace

*Test of means between groups (formatting?)
do "${do}/0_archive\my_ttest.do"
my_ttest nl13_density, by(treat_cntrl)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(SD)", "(SD)", "(p-value)†") fragment tex nocenter
filefilter `X' "${tables}\ttest_treat_cntrl_segm.tex", from("r}\BS\BS") to("r}") replace

*Checking the distribution 
hist nl13_density, freq graphregion(color(white)) 
gr export "${plots}\hist_nl_13_segm.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* 					Checking Assumptions for the Spatial RDD 
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* No manipulation Test:
*-------------------------------------------------------------------------------
*On control zones 
kdensity z_run_cntrl, graphregion(color(white)) xtitle("Normalized distance to the nearest controlled zone border") title("")
gr export "${plots}\kden_z_run_cntrl_segm.pdf", as(pdf) replace 

rddensity z_run_cntrl
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_cntrl, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_cntrl_segm.pdf", as(pdf) replace 

*On expansion zones
kdensity z_run_xpsn, graphregion(color(white)) xtitle("Normalized distance to the nearest expansion zone border") title("")
gr export "${plots}\kden_z_run_xpsn_segm.pdf", as(pdf) replace 

rddensity z_run_xpsn
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_xpsn, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest expansion zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_xpsn_segm.pdf", as(pdf) replace 

*On disputed zones
kdensity z_run_dsptd, graphregion(color(white)) xtitle("Normalized distance to the nearest disputed zone border") title("")
gr export "${plots}\kden_z_run_dsptd_segm.pdf", as(pdf) replace 

rddensity z_run_dsptd
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_dsptd, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest disputed zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_dsptd_segm.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Local continuity assumption:
*-------------------------------------------------------------------------------
*Between pixels within FMLN controlled zones and disputed zones (not including pixels in expansion zones)
rdrobust elevation z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust hydrography z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Hydrography") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust cacao z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_1 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Elevation (0-500)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_2 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Elevation (500-1000)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_3 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Elevation (1000-1500)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_4 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Elevation (1500-Max)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust rail_road z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_segm.tex", tex(frag) ctitle("Roads or railway") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust elevation z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust hydrography z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Hydrography") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust cacao z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_1 z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Elevation (0-500)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_2 z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Elevation (500-1000)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_3 z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Elevation (1000-1500)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust sum_elev_4 z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Elevation (1500-Max)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust rail_road z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_segm.tex", tex(frag) ctitle("Roads or railway") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 


*-------------------------------------------------------------------------------
* 						Spatial RDD Results
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Sharp RDD results:
*-------------------------------------------------------------------------------
*Between pixels within FMLN controlled zones and disputed zones (not including pixels in expansion zones)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdmse nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_cvsd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_cvsd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

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

coefplot (mat(coef[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-8(2)5) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") graphregion(color(white))
gr export "${plots}\rdd_z_run_cvsd_h_robustness_segm.pdf", as(pdf) replace 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_dvsnd_segm.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

mat coef=J(3,25,.)
local h=1.2
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

mat coln coef= 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5 5.2 5.4 5.6 5.8 6

coefplot (mat(coef[1]), ci((2 3))), vert recast(connected) ciopts(recast(rcap)) yline(0,lp(dash)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ylabel(-10(1)0) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") graphregion(color(white))
gr export "${plots}\rdd_z_run_dvsnd_h_robustness_segm.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Checking the robustness of results
*-------------------------------------------------------------------------------
*Trimming the nl density
summ nl13_density, d
gen nl13_density_v2=nl13_density if nl13_density>`r(p1)' & nl13_density<`r(p99)'

summ nl13_density, d
gen nl13_density_v3=nl13_density if nl13_density>`r(p5)' & nl13_density<`r(p95)'

*Between pixels within FMLN controlled zones and disputed zones (not including pixels in expansion zones)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p1.tex", tex(frag) ctitle("Night light") addtext("Note", "Main") addstat("Polynomial", 1) nonote replace 

rdrobust nl13_density_v2 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p1.tex", tex(frag) ctitle("Night light") addtext("Note", "Trim p1-p99") addstat("Polynomial", 1) nonote append  

rdrobust nl13_density_v3 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p1.tex", tex(frag) ctitle("Night light") addtext("Note", "Trim p5-p95") addstat("Polynomial", 1) nonote append 

rdrobust ln_nl13 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p1.tex", tex(frag) ctitle("ln(Night light)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append 

rdrobust ln_nl13_plus z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p1.tex", tex(frag) ctitle("ln(Night light+0.01)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append  

rdrobust arcsine_nl13 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p1.tex", tex(frag) ctitle("arcsine(Night light)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append 

rdrobust mean_nl_z z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p2.tex", tex(frag) ctitle("Night light (no zeros)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote replace  

rdrobust wmean_nl1 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p2.tex", tex(frag) ctitle("Night light (weighted)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append  

rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all covs(elevation) kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p2.tex", tex(frag) ctitle("Night light") addtext("Note", "Elevation control") addstat("Polynomial", 1) nonote append 

rdrobust ln_nl13 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all covs(elevation) kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p2.tex", tex(frag) ctitle("ln(Night light)") addtext("Note", "Elevation control") addstat("Polynomial", 1) nonote append 

rdrobust arcsine_nl13 z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all covs(elevation) kernel(triangular)
outreg2 using "${tables}\rdd_robustness_cvsd_segm_p2.tex", tex(frag) ctitle("arcsine(Night light)")addtext("Note", "Elevation control") addstat("Polynomial", 1) nonote append 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p1.tex", tex(frag) ctitle("Night light") addtext("Note", "Main") addstat("Polynomial", 1) nonote replace 

rdrobust nl13_density_v2 z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p1.tex", tex(frag) ctitle("Night light") addtext("Note", "Trim p1-p99") addstat("Polynomial", 1) nonote append  

rdrobust nl13_density_v3 z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p1.tex", tex(frag) ctitle("Night light") addtext("Note", "Trim p5-p95") addstat("Polynomial", 1) nonote append 

rdrobust ln_nl13 z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p1.tex", tex(frag) ctitle("ln(Night light)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append 

rdrobust ln_nl13_plus z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p1.tex", tex(frag) ctitle("ln(Night light+0.01)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append  

rdrobust arcsine_nl13 z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p1.tex", tex(frag) ctitle("arcsine(Night light)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append 

rdrobust mean_nl_z z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p2.tex", tex(frag) ctitle("Night light (no zeros)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote replace  

rdrobust wmean_nl1 z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p2.tex", tex(frag) ctitle("Night light (weighted)") addtext("Note", "Transformation") addstat("Polynomial", 1) nonote append  

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all covs(elevation) kernel(triangular) 
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p2.tex", tex(frag) ctitle("Night light") addtext("Note", "Elevation control") addstat("Polynomial", 1) nonote append 

rdrobust ln_nl13 z_run_dsptd if within_expansion==0 & within_control==0, all covs(elevation) kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p2.tex", tex(frag) ctitle("ln(Night light)") addtext("Note", "Elevation control") addstat("Polynomial", 1) nonote append 

rdrobust arcsine_nl13 z_run_dsptd if within_expansion==0 & within_control==0, all covs(elevation) kernel(triangular)
outreg2 using "${tables}\rdd_robustness_dvsnd_segm_p2.tex", tex(frag) ctitle("arcsine(Night light)")addtext("Note", "Elevation control") addstat("Polynomial", 1) nonote append 

*-------------------------------------------------------------------------------
* Robustness with disputed line breaks FE:
*-------------------------------------------------------------------------------
*Checking the specification 
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(uniform)
gl h=e(h_l) 

reg nl13_density within_disputed z_run_dsptd i.within_disputed#c.z_run_dsptd if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, r

*RDD with break fe and triangular weights  
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
gl h=e(h_l) 

cap drop weights
gen weights=(1-abs(z_run_dsptd/${h})) if within_expansion==0 & within_control==0 & z_run_dsptd<0 & z_run_dsptd>=-${h}
replace weights=(1-abs(z_run_dsptd/${h})) if within_expansion==0 & within_control==0 & z_run_dsptd>=0 & z_run_dsptd<=${h}

reg nl13_density within_disputed z_run_dsptd i.within_disputed#c.z_run_dsptd [aw=weights] if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, r

reghdfe nl13_density within_disputed z_run_dsptd i.within_disputed#c.z_run_dsptd [aw=weights] if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, vce(r) a(i.disputa_break_fe_400)
reghdfe nl13_density within_disputed z_run_dsptd i.within_disputed#c.z_run_dsptd [aw=weights] if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, vce(r) a(i.disputa_break_fe_200)
reghdfe nl13_density within_disputed z_run_dsptd i.within_disputed#c.z_run_dsptd [aw=weights] if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, vce(r) a(i.disputa_break_fe_100)
reghdfe nl13_density within_disputed z_run_dsptd i.within_disputed#c.z_run_dsptd [aw=weights] if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, vce(r) a(i.disputa_break_fe_50)

*-------------------------------------------------------------------------------
* Sharp RDD plots:
*-------------------------------------------------------------------------------
*Between pixels within FMLN controlled zones and disputed zones (not including pixels in expansion zones)
rdrobust nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1), all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdplot nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1) & abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) nbins(80) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p1_z_run_cvsd_segm.pdf", as(pdf) replace 

rdplot nl13_density z_run_cntrl if within_expansion==0 & (within_control==1 | within_disputed==1) & abs(z_run_cntrl)<=${h}, all p(2) h(${h}) b(${b}) kernel(triangular) nbins(80) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p2_z_run_cvsd_segm.pdf", as(pdf) replace 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

rdplot nl13_density z_run_dsptd if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) nbins(80) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest disputed zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p1_z_run_dvsnd_segm.pdf", as(pdf) replace 

rdplot nl13_density z_run_dsptd if within_expansion==0 & within_control==0 & abs(z_run_dsptd)<=${h}, all p(2) h(${h}) b(${b}) kernel(triangular) nbins(80) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest disputed zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p2_z_run_dvsnd_segm.pdf", as(pdf) replace 








  


*END
