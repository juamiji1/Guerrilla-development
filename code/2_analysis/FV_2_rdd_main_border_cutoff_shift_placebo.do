
clear all

*-------------------------------------------------------------------------------
* Plot of the border-shift placebo: placebo borders in black/gray, the estimate
* at the actual boundary (shift = 0) in black (same gray palette as the SE plots). Expects matrix C
* (rows: estimate, lb, ub; columns: shifts from -3 to 3 km in 0.5 km steps).
*-------------------------------------------------------------------------------
cap program drop plot_border_shift
program define plot_border_shift
	syntax, ytitle(string) file(string)
	preserve
	clear
	mat Ct = C'
	svmat Ct
	gen shift = -3 + 0.5*(_n-1)
	twoway (rcap Ct2 Ct3 shift if shift!=0, lc(gs6) lw(medthin)) ///
		(scatter Ct1 shift if shift!=0, mc(gs6) ms(O) msize(medium)) ///
		(rcap Ct2 Ct3 shift if shift==0, lc(black) lw(medthick)) ///
		(scatter Ct1 shift if shift==0, mc(black) ms(D) msize(large)), ///
		yline(0, lc(black)) xlabel(-3(0.5)3) ytitle("") xtitle("") ///
		legend(order(2 "Placebo borders" 4 "Actual boundary") pos(6) rows(1)) ///
		l2title("`ytitle'", size(medsmall)) b2title("Border cutoff shift (km)")
	gr export "${plots}/`file'", as(pdf) replace
	restore
end

/*-------------------------------------------------------------------------------
* 				 Placebo Borders for Main outcomes (Night Light)
*
*
*-------------------------------------------------------------------------------*/
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

mat C_pos=J(3,7,.)
mat C_neg=J(3,6,.)

*-------------------------------------------------------------------------------
* 						Main result for Night Light
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
lincom within_control
mat C_pos[1,1]= r(estimate) 
mat C_pos[2,1]= r(lb)
mat C_pos[3,1]= r(ub)
	
*-------------------------------------------------------------------------------
* 						Changing border by .5 kms as placebo
*-------------------------------------------------------------------------------
local c=2

forval s_p = .5(.5)3 {
	
	gen z_p = z_run_cntrl+ `s_p'
	gen in_p = (z_p>=0) 
	
	*Global of border FE for all estimates
	gl breakfe="control_break_fe_400"
	gl controls "in_p i.in_p#c.z_p z_p"

	*RDD with break fe and triangular weights 
	rdrobust arcsine_nl13 z_p, all kernel(triangular)
	gl h_p= 2.271
	
	*Conditional for all specifications
	gl if "if abs(z_p)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_p/${h})) ${if}
	
	*Estimates
	reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	lincom in_p
	
	mat C_pos[1,`c']= r(estimate) 
	mat C_pos[2,`c']= r(lb)
	mat C_pos[3,`c']= r(ub)
		
	drop z_p in_p
	
	local c=`c'+1
}

local c=6

forval s_p = -.5(-.5)-3 {
	
	gen z_p = z_run_cntrl+ `s_p'
	gen in_p = (z_p>=0) 
	
	*Global of border FE for all estimates
	gl breakfe="control_break_fe_400"
	gl controls "in_p i.in_p#c.z_p z_p"

	*RDD with break fe and triangular weights 
	rdrobust arcsine_nl13 z_p, all kernel(triangular)
	gl h_p= 2.271
	
	*Conditional for all specifications
	gl if "if abs(z_p)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_p/${h})) ${if}
	
	*Estimates
	reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	lincom in_p
	
	mat C_neg[1,`c']= r(estimate) 
	mat C_neg[2,`c']= r(lb)
	mat C_neg[3,`c']= r(ub)
		
	drop z_p in_p
	
	local c=`c'-1
}

mat C=C_neg,C_pos
mat coln C = -3 -2.5 -2 -1.5 -1 -.5 0 .5 1 1.5 2 2.5 3
mat l C

*Plotting estimates
plot_border_shift, ytitle("Effect of guerrilla control on night light") ///
	file(rdd_border_shift_placebo_arcsine_nl13.pdf)


*-------------------------------------------------------------------------------
* 						Main outcomes (Wealth index)
*
*-------------------------------------------------------------------------------
clear   // (not "clear all": keeps the plot_border_shift program defined above)

use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

mat C_pos=J(3,7,.)
mat C_neg=J(3,6,.)

*-------------------------------------------------------------------------------
* 						Main result
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
lincom within_control
mat C_pos[1,1]= r(estimate) 
mat C_pos[2,1]= r(lb)
mat C_pos[3,1]= r(ub)
	
*-------------------------------------------------------------------------------
* 						Changing border by .5 kms as placebo
*-------------------------------------------------------------------------------
local c=2

forval s_p = .5(.5)3 {
	
	gen z_p = z_run_cntrl+ `s_p'
	gen in_p = (z_p>=0) 
	
	*Global of border FE for all estimates
	gl breakfe="control_break_fe_400"
	gl controls "in_p i.in_p#c.z_p z_p"

	*RDD with break fe and triangular weights 
	rdrobust arcsine_nl13 z_p, all kernel(triangular)
	gl h_p= 2.271
	
	*Conditional for all specifications
	gl if "if abs(z_p)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_p/${h})) ${if}
	
	*Estimates
	reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	lincom in_p
	
	mat C_pos[1,`c']= r(estimate) 
	mat C_pos[2,`c']= r(lb)
	mat C_pos[3,`c']= r(ub)
		
	drop z_p in_p
	
	local c=`c'+1
}

local c=6

forval s_p = -.5(-.5)-3 {
	
	gen z_p = z_run_cntrl+ `s_p'
	gen in_p = (z_p>=0) 
	
	*Global of border FE for all estimates
	gl breakfe="control_break_fe_400"
	gl controls "in_p i.in_p#c.z_p z_p"

	*RDD with break fe and triangular weights 
	rdrobust arcsine_nl13 z_p, all kernel(triangular)
	gl h_p= 2.271
	
	*Conditional for all specifications
	gl if "if abs(z_p)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_p/${h})) ${if}
	
	*Estimates
	reghdfe z_wi ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	lincom in_p
	
	mat C_neg[1,`c']= r(estimate) 
	mat C_neg[2,`c']= r(lb)
	mat C_neg[3,`c']= r(ub)
		
	drop z_p in_p
	
	local c=`c'-1
}

mat C=C_neg,C_pos
mat coln C = -3 -2.5 -2 -1.5 -1 -.5 0 .5 1 1.5 2 2.5 3
mat l C

*Plotting estimates
plot_border_shift, ytitle("Effect of guerrilla control on wealth index") ///
	file(rdd_border_shift_placebo_z_wi.pdf)


*-------------------------------------------------------------------------------
* 						Main outcomes (Years of Education)
*
*-------------------------------------------------------------------------------
clear   // (not "clear all": keeps the plot_border_shift program defined above)

use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

mat C_pos=J(3,7,.)
mat C_neg=J(3,6,.)

*-------------------------------------------------------------------------------
* 						Main result
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
lincom within_control
mat C_pos[1,1]= r(estimate) 
mat C_pos[2,1]= r(lb)
mat C_pos[3,1]= r(ub)
	
*-------------------------------------------------------------------------------
* 						Changing border by .5 kms as placebo
*-------------------------------------------------------------------------------
local c=2

forval s_p = .5(.5)3 {
	
	gen z_p = z_run_cntrl+ `s_p'
	gen in_p = (z_p>=0) 
	
	*Global of border FE for all estimates
	gl breakfe="control_break_fe_400"
	gl controls "in_p i.in_p#c.z_p z_p"

	*RDD with break fe and triangular weights 
	rdrobust arcsine_nl13 z_p, all kernel(triangular)
	gl h_p= 2.271
	
	*Conditional for all specifications
	gl if "if abs(z_p)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_p/${h})) ${if}
	
	*Estimates
	reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	lincom in_p
	
	mat C_pos[1,`c']= r(estimate) 
	mat C_pos[2,`c']= r(lb)
	mat C_pos[3,`c']= r(ub)
		
	drop z_p in_p
	
	local c=`c'+1
}

local c=6

forval s_p = -.5(-.5)-3 {
	
	gen z_p = z_run_cntrl+ `s_p'
	gen in_p = (z_p>=0) 
	
	*Global of border FE for all estimates
	gl breakfe="control_break_fe_400"
	gl controls "in_p i.in_p#c.z_p z_p"

	*RDD with break fe and triangular weights 
	rdrobust arcsine_nl13 z_p, all kernel(triangular)
	gl h_p= 2.271
	
	*Conditional for all specifications
	gl if "if abs(z_p)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_p/${h})) ${if}
	
	*Estimates
	reghdfe mean_educ_years ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe})
	lincom in_p
	
	mat C_neg[1,`c']= r(estimate) 
	mat C_neg[2,`c']= r(lb)
	mat C_neg[3,`c']= r(ub)
		
	drop z_p in_p
	
	local c=`c'-1
}

mat C=C_neg,C_pos
mat coln C = -3 -2.5 -2 -1.5 -1 -.5 0 .5 1 1.5 2 2.5 3
mat l C

*Plotting estimates
plot_border_shift, ytitle("Effect of guerrilla control on years of education") ///
	file(rdd_border_shift_placebo_mean_educ_years.pdf)


/*-------------------------------------------------------------------------------
* 			 	Randomization Inference for Main outcomes
*
*
*-------------------------------------------------------------------------------*/
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl ht= round(${h}, .001)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl mainoutcomes "arcsine_nl13 z_wi mean_educ_years"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Estimating RI p-values through Randomization Inference (RI)
*-------------------------------------------------------------------------------
eststo clear

set seed 123
gl reps = 10000

local i=1
foreach yvar of global mainoutcomes {
	
	*Base Estimation
	reghdfe `yvar' within_control ${if}, vce(r) a(i.${breakfe}) 
	eststo r`i'
	
	*RI permutation
	ritest within_control _b[within_control], reps(${reps}) ///
	strata(${breakfe}) force: ///
	reghdfe `yvar' within_control ${if}, vce(r) a(i.${breakfe}) 
	
	gl ri_p_`i'= r(p)[1,1]
		
	local ++i
	
	*Base Estimation
 	reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
 	eststo r`i'
	
 	*RI permutation
 	ritest within_control _b[within_control], reps(${reps}) ///
 	strata(${breakfe}) force: ///
 	reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	
 	gl ri_p_`i'= r(p)[1,1]
		
 	local ++i
	
}

*-------------------------------------------------------------------------------
* Table 
*-------------------------------------------------------------------------------
*Exporting results: only the baseline specification (with the linear polynomial,
*r2 r4 r6). The no-polynomial estimates r1 r3 r5 are still computed above but
*no longer reported (reply letter Table R.11, Nov 2026).
foreach i in 2 4 6 {
	gl ri_p_`i'_f = string(${ri_p_`i'}, "%5.3f")
}

esttab r2 r4 r6 using "${tables}/rdd_main_all_RI.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Wealth Index & Years of Education \\"' ///
            `" & (1) & (2) & (3) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`"Permutation p-value & ${ri_p_2_f} & ${ri_p_4_f} & ${ri_p_6_f} \\"' ///
		`"Permutation reps & ${reps} & ${reps} & ${reps} \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"')


/*-------------------------------------------------------------------------------
* 			 Adding soft geographic controls for Main outcomes
*
*
*-------------------------------------------------------------------------------*/
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl ht= round(${h}, .001)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controlslatlon "within_control i.within_control#c.z_run_cntrl z_run_cntrl c.x_coord##c.y_coord c.x_coord#c.x_coord c.y_coord#c.y_coord"
gl mainoutcomes "arcsine_nl13 z_wi mean_educ_years"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*-------------------------------------------------------------------------------
* Estimating 
*-------------------------------------------------------------------------------
eststo clear

local i=1
foreach yvar of global mainoutcomes {
	
	*Base Estimation
	eststo b`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	eststo bl`i': reg `yvar' ${controlslatlon} i.${breakfe} [aw=tweights] ${if} & e(sample)==1, r 
	
	local ++i
}


*-------------------------------------------------------------------------------
* Table 
*-------------------------------------------------------------------------------
*Exporting results 
esttab b1 bl1 b2 bl2 b3 bl3 using "${tables}/rdd_main_all_latlonpoly.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Night Light & Wealth Index & Wealth Index & Years of Education & Years of Education \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`"Lat-lon polynomial (2nd degree) & No & Yes & No & Yes & No & Yes \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 

		
/*-------------------------------------------------------------------------------
* 			 Spatial dependence test for Main outcomes (Becker et al)
*
*
*-------------------------------------------------------------------------------*/
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl ht= round(${h}, .001)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl mainoutcomes "arcsine_nl13 z_wi mean_educ_years"

gen wc_z=within_control*z_run_cntrl

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

gen s_1=y_coord
gen s_2=x_coord

*-------------------------------------------------------------------------------
* Soft geographic controls and unit root test 
*-------------------------------------------------------------------------------
eststo clear

local i=1
foreach yvar of global mainoutcomes {
	
	*Base Estimation
	eststo b`i': reghdfe `yvar' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	eststo bl`i': reg `yvar' ${controlslatlon} i.${breakfe} [aw=tweights] ${if} & e(sample)==1, r 
	
	spurtest i1resid `yvar' within_control wc_z z_run_cntrl ${if}, latlong
	gl p_`i'=r(p)
	
	local ++i
}


*-------------------------------------------------------------------------------
* Table 
*-------------------------------------------------------------------------------
*Exporting results 
esttab b1 bl1 b2 bl2 b3 bl3 using "${tables}/rdd_main_all_latlonpoly.tex", keep(within_control) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \hline \toprule"'                     ///
            `" & Night Light & Night Light & Wealth Index & Wealth Index & Years of Education & Years of Education \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" \toprule"' ///
		`"Lat-lon polynomial (2nd degree) & No & Yes & No & Yes & No & Yes \\"' ///
		`"Muller-Watson I(1) p-value & ${p_1} & - & ${p_2} & - & ${p_3} & - \\"' ///
		`" Bandwidth (Km) & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
		`"\bottomrule \end{tabular}"') 


		

*END
