
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

gen estsample=1 if abs(z_run_cntrl)<=${h}

keep segm_id arcsine_nl13 nl13_density wmean_nl1 elevation2 within_control z_run_cntrl z_wi mean_educ_years estsample control_break_fe_400

tempfile INFO
save `INFO', replace 


*ROBUSTNESS TEST
import excel "${data}\nbr_matrix_p3.xls", sheet("nbr_matrix_p3") firstrow clear

tempfile P3
save `P3', replace 

import excel "${data}\nbr_matrix_p2.xls", sheet("nbr_matrix_p2") firstrow clear

tempfile P2
save `P2', replace 

import excel "${data}\nbr_matrix_p1.xls", sheet("nbr_matrix_p1") firstrow clear
append using `P2' `P3'

ren (src_SEG_ID nbr_SEG_ID) (segm_id_cntr segm_id)

drop OBJECTID LENGTH NODE_COUNT

*Merging info of pairs
merge m:1 segm_id using `INFO', keep(3) nogen 
ren (arcsine_nl13 nl13_density wmean_nl1 elevation2 within_control z_run_cntrl z_wi mean_educ_years estsample control_break_fe_400) nbr_=
ren segm_id segm_id_nbr 
ren segm_id_cntr segm_id

merge m:1 segm_id using `INFO', keep(3) nogen 

*Calculating the differences 
gen diff_elevation2= elevation2 - nbr_elevation2
gen diff_nl13_density= nl13_density - nbr_nl13_density
gen diff_arcsine_nl13= arcsine_nl13 - nbr_arcsine_nl13
gen diff_wmean_nl1= wmean_nl1-nbr_wmean_nl1
gen diff_z_wi= z_wi - nbr_z_wi
gen diff_mean_educ_years= mean_educ_years - nbr_mean_educ_years

keep if diff_elevation2>0

summ diff_elevation2, d

gen sample=1 if diff_elevation2>=15 & diff_elevation2<21

reg diff_arcsine_nl13 if sample==1 & within_control==0 & nbr_within_control==0, r
reg diff_nl13_density if sample==1 & within_control==0 & nbr_within_control==0, r
reg diff_wmean_nl1 if sample==1 & within_control==0 & nbr_within_control==0, r

reg diff_elevation2 if sample==1, r
outreg2 using "${tables}\rdd_all_elev_placebo_p1.tex", tex(frag) replace
reg diff_arcsine_nl13 if sample==1, r
outreg2 using "${tables}\rdd_all_elev_placebo_p1.tex", tex(frag) append
reg diff_arcsine_nl13 if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}\rdd_all_elev_placebo_p1.tex", tex(frag) append

reg diff_elevation2 if diff_elevation2>=20  & diff_elevation2<=100, r
outreg2 using "${tables}\rdd_all_elev_placebo_p1.tex", tex(frag) append
reg diff_arcsine_nl13 if diff_elevation2>=20  & diff_elevation2<=100, r
outreg2 using "${tables}\rdd_all_elev_placebo_p1.tex", tex(frag) append
reg diff_arcsine_nl13 if diff_elevation2>=20  & diff_elevation2<=100 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}\rdd_all_elev_placebo_p1.tex", tex(frag) append

*reg diff_arcsine_nl13 if sample==1 & within_control==1 & nbr_within_control==0, r
*outreg2 using "${tables}\rdd_all_elev_placebo.tex", tex(frag) append

reg diff_z_wi if sample==1
outreg2 using "${tables}\rdd_all_elev_placebo_p2.tex", tex(frag) replace
reg diff_z_wi if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}\rdd_all_elev_placebo_p2.tex", tex(frag) append
reg diff_z_wi if diff_elevation2>=20 & diff_elevation2<=100, r
outreg2 using "${tables}\rdd_all_elev_placebo_p2.tex", tex(frag) append
reg diff_z_wi if diff_elevation2>=20 & diff_elevation2<=100 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}\rdd_all_elev_placebo_p2.tex", tex(frag) append


*reg diff_z_wi if sample==1 & within_control==1 & nbr_within_control==0, r
*outreg2 using "${tables}\rdd_all_elev_placebo.tex", tex(frag) append

reg diff_mean_educ_years if sample==1, r
outreg2 using "${tables}\rdd_all_elev_placebo_p3.tex", tex(frag) replace
reg diff_mean_educ_years if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}\rdd_all_elev_placebo_p3.tex", tex(frag) append
reg diff_mean_educ_years if diff_elevation2>=20 & diff_elevation2<=100, r
outreg2 using "${tables}\rdd_all_elev_placebo_p3.tex", tex(frag) append
reg diff_mean_educ_years if diff_elevation2>=20 & diff_elevation2<=100 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}\rdd_all_elev_placebo_p3.tex", tex(frag) append



summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p1)', r

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p5)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p10)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p25)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p50)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p75)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p90)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p95)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2<=`r(p99)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2>=`r(p10)' & diff_elevation2<=`r(p90)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2>=`r(p5)' & diff_elevation2<=`r(p95)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2>=`r(p10)' & diff_elevation2<=`r(p95)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2>=`r(p10)' & diff_elevation2<=`r(p99)'

summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2>=`r(p10)'


summ diff_elevation2, d 
reg diff_arcsine_nl13 if diff_elevation2>=20 & diff_elevation2<=100
summ diff_elevation2, d 
reg diff_z_wi if diff_elevation2>=20 & diff_elevation2<=`r(p90)'
summ diff_elevation2, d 
reg diff_mean_educ_years if diff_elevation2>=20 & diff_elevation2<=`r(p90)'


gen Dh=round(diff_elevation2, 1)
tabstat diff_arcsine_nl13, by(Dh) s(N mean sd min max)

summ diff_elevation2, d 
gen p_dh=1 if diff_elevation2<=`r(p1)'
replace p_dh=2 if diff_elevation2>`r(p1)' & diff_elevation2<=`r(p5)'
replace p_dh=3 if diff_elevation2>`r(p5)' & diff_elevation2<=`r(p10)'
replace p_dh=4 if diff_elevation2>`r(p10)' & diff_elevation2<=`r(p25)'
replace p_dh=5 if diff_elevation2>`r(p25)' & diff_elevation2<=`r(p50)'
replace p_dh=6 if diff_elevation2>`r(p50)' & diff_elevation2<=`r(p75)'
replace p_dh=7 if diff_elevation2>`r(p75)' & diff_elevation2<=`r(p90)'
replace p_dh=8 if diff_elevation2>`r(p90)' & diff_elevation2<=`r(p95)'
replace p_dh=9 if diff_elevation2>`r(p95)' & diff_elevation2<=`r(p99)'
replace p_dh=10 if diff_elevation2>`r(p99)' & diff_elevation2<=.

tabstat diff_arcsine_nl13, by(p_dh) s(N mean sd min max)
tabstat diff_elevation2, by(p_dh) s(N mean sd min max)

tabstat diff_arcsine_nl13 if within_control==0 & nbr_within_control==0, by(p_dh) s(N mean sd min max)
tabstat diff_elevation2 if within_control==0 & nbr_within_control==0, by(p_dh) s(N mean sd min max)


tabstat diff_arcsine_nl13 if estsample==1 & nbr_estsample==1, by(p_dh) s(N mean sd min max)
tabstat diff_elevation2 if estsample==1 & nbr_estsample==1, by(p_dh) s(N mean sd min max)

tabstat elevation2, by(p_dh) s(N mean sd min max)



*gen x=1 if p_dh>=9 & p_dh<.
gen x=1 if diff_elevation2>=100 & diff_elevation2<.
bys segm_id: egen out=mean(x)

tab out

collapse out, by(segm_id)

tempfile Out
save `Out', replace 


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

drop _merge

merge 1:1 segm_id using `Out'

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if out==., all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & out==."

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}


*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl main "arcsine_nl13 z_wi mean_educ_years" 

*Erasing table before exporting
cap erase "${tables}\rdd_main_all_out.tex"
cap erase "${tables}\rdd_main_all_out.txt"

foreach var of global main{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_main_all_out.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}












/*reg diff_mean_educ_years if sample==1 & within_control==1 & nbr_within_control==0, r
*outreg2 using "${tables}\rdd_all_elev_placebo.tex", tex(frag) append


summ diff_elevation2, d
reg diff_arcsine_nl13 if diff_elevation2>50, r
reg diff_arcsine_nl13 if diff_elevation2>50 & within_control==0 & nbr_within_control==0, r

summ diff_elevation2 if within_control==0 & nbr_within_control==0, d

summ diff_arcsine_nl13 if within_control==0 & nbr_within_control==0 & diff_elevation2>0, d

summ diff_arcsine_nl13 if within_control==0 & nbr_within_control==0, d


*END





drop sample