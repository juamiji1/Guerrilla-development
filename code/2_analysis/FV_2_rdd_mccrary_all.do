*MCcrary Test:
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

*hist z_run_cntrl, freq
kdensity z_run_cntrl if abs(z_run_cntrl)<10, xline(0) lcolor(gs3) title("") xtitle("") ytitle("") l2title("Kernel density estimate", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall))  
gr export "${plots}\kdensity_z_run_cntrl.pdf", as(pdf) replace 

rddensity z_run_cntrl_v2 
local p=round(`e(pv_q)', 0.001)
dis "`p'"
rddensity z_run_cntrl_v2, plot graph_opt(legend(off) note("Bias corrected P-value: `p'") xline(0, lcolor(black)) ytitle("Density") b2title("Distance to Boundary"))
gr export "${plots}\rddensityplot_p1.pdf", as(pdf) replace 

rddensity z_run_cntrl
local p=round(`e(pv_q)', 0.001)
dis "`p'"
rddensity z_run_cntrl, plot graph_opt(legend(off) note("Bias corrected P-value: `p'") xline(0, lcolor(black)) ytitle("Density") b2title("Distance to Boundary"))
gr export "${plots}\rddensityplot_p2.pdf", as(pdf) replace 

mat O1=(e(N_l),e(N_r) \ e(N_h_l),e(N_h_r) \ e(h_l), e(h_l))
mat O2=(e(T_q), e(pv_q))

mat rown O1= "Total N" "Effective N" "Bandwidth (h)"
mat rown O2= "Robust"

tempfile X
frmttable using `X', statmat(O1) ctitle("Cut-off in 0", "Left", "Right") sdec(0\0\3) fragment tex nocenter replace  	
filefilter `X' "${tables}/rdd_all_mccrary1.tex", from("{tabular}\BS\BS") to("{tabular}") replace

frmttable using `X', statmat(O2) ctitle("Method", "Bias-corrected t-statistic", "P-value for density test") sdec(3) fragment tex nocenter replace  	
filefilter `X' "${tables}/rdd_all_mccrary2.tex", from("{tabular}\BS\BS") to("{tabular}") replace




/*--------------------------------OTHER IDEA:
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear
keep segm_id z_run_cntrl z_run_cntrl_v2

tempfile Zvar
save `Zvar', replace                                            

use "${data}/censo2007\data\hogar.dta", clear

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

keep segm_id VIVID HOGID

merge m:1 segm_id using `Zvar', keep(1 3) nogen

rddensity z_run_cntrl if z_run_cntrl_v2>0.5 | z_run_cntrl_v2<-0.5, plot
  

rddensity z_run_cntrl_v2, plot 

rddensity z_run_cntrl_v2, plot nomasspoints





	
*END

  
  
  