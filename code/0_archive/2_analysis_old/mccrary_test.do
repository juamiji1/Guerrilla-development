/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring possible mechanisms
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

keep if elevation2>=200 & river1==0
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

hist z_run_cntrl, freq
kdensity z_run_cntrl if abs(z_run_cntrl)<10, xline(0) lcolor(gs3) title("") xtitle("") ytitle("") l2title("Kernel density estimate", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall))  
gr export "${plots}\kdensity_z_run_cntrl.pdf", as(pdf) replace 

rddensity z_run_cntrl, h(${h}) p(1)

mat O1=(e(N_l),e(N_r) \ e(N_h_l),e(N_h_r) \ e(h_l), e(h_l))
mat O2=(e(T_q), e(pv_q))

mat rown O1= "Total N" "Effective N" "Bandwidth (h)"
mat rown O2= "Robust"

tempfile X
frmttable using `X', statmat(O1) ctitle("Cut-off in 0", "Left", "Right") sdec(0\0\3) fragment tex nocenter replace  	
filefilter `X' "${tables}/mccrary1.tex", from("{tabular}\BS\BS") to("{tabular}") replace

frmttable using `X', statmat(O2) ctitle("Method", "T(h)", "P-value") sdec(3) fragment tex nocenter replace  	
filefilter `X' "${tables}/mccrary2.tex", from("{tabular}\BS\BS") to("{tabular}") replace






*END