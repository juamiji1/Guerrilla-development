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
shp2dta using "${maps}/pixel_lvl_vars/nl13Shp_pixels_info_sp_x10_res", data("${data}/nl13Shp_pixels_info_sp_x10_res.dta") coord("${data}/nl13Shp_pixels_info_sp_x10_res_coord.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Spatial RDD of Night Light Density
*
*-------------------------------------------------------------------------------
*Loading the data 
*use "nl13Shp_pixels.dta", clear
use "nl13Shp_pixels_info_sp_x10_res.dta", clear

*Renaming variables
*rename (value wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp) (nl13_density within_control within_expansion within_disputed dist_control dist_expansion dist_disputed)
rename (value wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_lv mean_cc mean_bn) (nl13_density within_control within_expansion within_disputed dist_control dist_expansion dist_disputed elevation cacao bean)


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
la var z_run_cntrl "Distance to nearest control zone"
la var z_run_xpsn "Distance to nearest expansion zone"
la var z_run_dsptd "Distance to nearest disputed zone"

*-------------------------------------------------------------------------------
* No manipulation Test:
*-------------------------------------------------------------------------------
*On control zones 
kdensity z_run_cntrl, graphregion(color(white)) xtitle("Normalized distance to the nearest controlled zone border") title("")
gr export "${plots}\kden_z_run_cntrl_x10_res.pdf", as(pdf) replace 

rddensity z_run_cntrl
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_cntrl, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_cntrl_x10_res.pdf", as(pdf) replace 

*On expansion zones
kdensity z_run_xpsn, graphregion(color(white)) xtitle("Normalized distance to the nearest expansion zone border") title("")
gr export "${plots}\kden_z_run_xpsn_x10_res.pdf", as(pdf) replace 

rddensity z_run_xpsn
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_xpsn, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest expansion zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_xpsn_x10_res.pdf", as(pdf) replace 

*On disputed zones
kdensity z_run_dsptd, graphregion(color(white)) xtitle("Normalized distance to the nearest disputed zone border") title("")
gr export "${plots}\kden_z_run_dsptd_x10_res.pdf", as(pdf) replace 

rddensity z_run_dsptd
local t=round(e(T_q), .01)
local p=round(e(pv_q), .01)
rddensity z_run_dsptd, plot graph_opt(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest disputed zone border") note("t-stat=`t', p-val=`p'"))
gr export "${plots}\manip_test_z_run_dsptd_x10_res.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Sharp RDD results:
*-------------------------------------------------------------------------------
*Checking the methodology
rdrobust nl13_density z_run_cntrl, all p(0) kernel(uniform)
local h=e(h_l) 
reg nl13_density treat_cntrl if abs(z_run_cntrl)<=`h' 				// So the OLS estimate is the conventional one in the rdd. It Shows the difference between treated and untreated.

*For control zones
rdrobust nl13_density z_run_cntrl, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

*Between pixels within and outside controlled FMLN zones 
rdmse nl13_density z_run_cntrl, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cntrl_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_cntrl, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cntrl_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_cntrl, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cntrl_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_cntrl, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_cntrl_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_cntrl, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_cntrl_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

*Between pixels within FMLN zones and disputed zones (not including pixels in expansion zones)
rdmse nl13_density z_run_cntrl if within_expansion==0, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_cntrl if within_expansion==0, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_cntrl if within_expansion==0, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_cntrl if within_expansion==0, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_cvsd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_cntrl if within_expansion==0, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_cvsd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_cntrl if within_expansion==0, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_cvsd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

*For disputed zones
rdrobust nl13_density z_run_dsptd, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

rdmse nl13_density z_run_dsptd if within_expansion==0 & within_control==0, p(3) h(${h}) b(${b}) 
gl amsep3=round(e(amse_bc), .001)
rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all p(3) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_dvsnd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_dvsnd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_dsptd if within_expansion==0 & within_control==0, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_dvsnd_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

*For expansion zones
rdrobust nl13_density z_run_xpsn, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

*Between pixels within and outside expansion FMLN zones (not including pixels in controlled and disputed zones)
rdmse nl13_density z_run_xpsn if within_disputed==0 & within_control==0, p(1) h(${h}) b(${b})
gl amsep1=round(e(amse_bc), .001)
rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all p(1) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_xvsnx_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1, "AMSE", ${amsep1}) nonote replace 

rdmse nl13_density z_run_xpsn if within_disputed==0 & within_control==0, p(2) h(${h}) b(${b})
gl amsep2=round(e(amse_bc), .001)
rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all p(2) h(${h}) b(${b}) kernel(triangular)
outreg2 using "${tables}\rdd_z_run_xvsnx_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 2, "AMSE", ${amsep2}) nonote append

cap nois {
	rdmse nl13_density z_run_xpsn if within_disputed==0 & within_control==0, p(3) h(${h}) b(${b}) 
	gl amsep3=round(e(amse_bc), .001)
	rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all p(3) h(${h}) b(${b}) kernel(triangular)
	outreg2 using "${tables}\rdd_z_run_xvsnx_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 3, "AMSE", ${amsep3}) nonote append
}

rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all h(${h}) b(${b}) kernel(epa)
outreg2 using "${tables}\rdd_z_run_xvsnx_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Epanechnikov") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

rdrobust nl13_density z_run_xpsn if within_disputed==0 & within_control==0, all h(${h}) b(${b}) kernel(uni)
outreg2 using "${tables}\rdd_z_run_xvsnx_x10_res.tex", tex(frag) ctitle("Night light density (2013)") addtext("Kernel", "Uniform") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append

/*-------------------------------------------------------------------------------
* Sharp RDD plots:
*-------------------------------------------------------------------------------
rdplot nl13_density z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(1) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p1_z_run_cntrl.pdf", as(pdf) replace 

rdplot nl13_density z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(2) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p2_z_run_cntrl.pdf", as(pdf) replace 

rdplot nl13_density z_run_cntrl if abs(z_run_cntrl)<=${h}, all p(3) h(${h}) b(${b}) kernel(triangular) graph_options(graphregion(color(white)) legend(off) xtitle("Normalized distance to the nearest controlled zone border", size(small)) ytitle("Average night light density within bin", size(small)) title("")) 
gr export "${plots}\rdplot_p3_z_run_cntrl.pdf", as(pdf) replace 
*/

*-------------------------------------------------------------------------------
* Local continuity assumption:
*-------------------------------------------------------------------------------
*Between pixels within and outside controlled FMLN zones 
rdrobust elevation z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_x10_res.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust cacao z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_x10_res.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_cntrl, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cntrl_lc_x10_res.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within FMLN zones and disputed zones (not including pixels in expansion zones)
rdrobust elevation z_run_cntrl if within_expansion==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_x10_res.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust cacao z_run_cntrl if within_expansion==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_x10_res.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_cntrl if within_expansion==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_cvsd_lc_x10_res.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
rdrobust elevation z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_x10_res.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust cacao z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_x10_res.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_dsptd if within_expansion==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_dvsnd_lc_x10_res.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*Between pixels within and outside expansion FMLN zones (not including pixels in controlled and disputed zones)
rdrobust elevation z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_x10_res.tex", tex(frag) ctitle("Elevation") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote replace 
rdrobust cacao z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_x10_res.tex", tex(frag) ctitle("Cacao yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 
rdrobust bean z_run_xpsn if within_disputed==0 & within_control==0, all p(1) kernel(triangular)
gl h=e(h_l) 
outreg2 using "${tables}\rdd_z_run_xvsnx_lc_x10_res.tex", tex(frag) ctitle("Bean yield") addtext("Kernel", "Triangular") addstat("Bandwidth", ${h},"Polynomial", 1) nonote append 

*-------------------------------------------------------------------------------
*Night light density distribution to put in context the results found:
*-------------------------------------------------------------------------------
*Summary statistics
summ nl13_density, d
tabstat nl13_density dist_control dist_expansion dist_disputed, s(N mean sd min p1 p5 p10 p25 p50 p75 p90 p95 p99 max) save
tabstatmat A

tempfile X
frmttable using `X', s(A) ctitle("Stat", "Night light", "Distance to nearest", "Distance to nearest", "Distance to nearest" \ "", "density (2013)", "control zone", "expansion zone", "disputed zone") tex fragment nocenter replace 
filefilter `X' "${tables}\summary_stats_x10_res.tex", from("r}\BS\BS") to("r}") replace

*Test of means between groups (formatting?)
do "${do}/0. my_ttest.do"
my_ttest nl13_density, by(treat_cntrl)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(SD)", "(SD)", "(p-value)†") fragment tex nocenter
filefilter `X' "${tables}\ttest_treat_cntrl_x10_res.tex", from("r}\BS\BS") to("r}") replace







*END
