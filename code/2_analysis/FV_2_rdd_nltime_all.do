/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes over time
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

gl nly "nl92_y nl93_y nl94_y nl95_y nl96_y nl97_y nl98_y nl99_y nl00_y nl01_y nl02_y nl03_y nl04_y nl05_y nl06_y nl07_y nl08_y nl09_y nl10_y nl11_y nl12_y nl13_y"

foreach var of global nly{
	gen ln_`var'=ln(`var') 
	gen arcs_`var'=ln(`var'+sqrt(`var'^2+1))
}

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

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Coefplot)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nly "nl92_y nl93_y nl94_y nl95_y nl96_y nl97_y nl98_y nl99_y nl00_y nl01_y nl02_y nl03_y nl04_y nl05_y nl06_y nl07_y nl08_y nl09_y nl10_y nl11_y nl12_y nl13_y"
gl lnnl "ln_nl92_y ln_nl93_y ln_nl94_y ln_nl95_y ln_nl96_y ln_nl97_y ln_nl98_y ln_nl99_y ln_nl00_y ln_nl01_y ln_nl02_y ln_nl03_y ln_nl04_y ln_nl05_y ln_nl06_y ln_nl07_y ln_nl08_y ln_nl09_y ln_nl10_y ln_nl11_y ln_nl12_y ln_nl13_y"
gl arcsnl "arcs_nl92_y arcs_nl93_y arcs_nl94_y arcs_nl95_y arcs_nl96_y arcs_nl97_y arcs_nl98_y arcs_nl99_y arcs_nl00_y arcs_nl01_y arcs_nl02_y arcs_nl03_y arcs_nl04_y arcs_nl05_y arcs_nl06_y arcs_nl07_y arcs_nl08_y arcs_nl09_y arcs_nl10_y arcs_nl11_y arcs_nl12_y arcs_nl13_y"

*Creating matrix to export estimates
mat coef=J(3,22,.)
local c=1

foreach var of global nly{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	lincom within_control	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local ++c	
}

*Labeling coef matrix rows according to each bw
mat coln coef= 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13
	
*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(small) angle(45)) l2title("Effect on Night Light Arcsine ") b2title("Year")
gr export "${plots}\rdd_nl_all_time_separate.pdf", as(pdf) replace 

*Creating matrix to export estimates
mat coef=J(3,22,.)
local c=1

foreach var of global lnnl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	lincom within_control	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local ++c	
}

*Labeling coef matrix rows according to each bw
mat coln coef= 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13
	
*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Year")
gr export "${plots}\rdd_lnnl_all_time_separate.pdf", as(pdf) replace 

*Creating matrix to export estimates
mat coef=J(3,22,.)
local c=1

foreach var of global arcsnl{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	lincom within_control	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local ++c	
}

*Labeling coef matrix rows according to each bw
mat coln coef= 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13
	
*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(small) angle(45)) l2title("Effect on Night Light (Arcsine) ") b2title("Year") ylabel(-.25(.05)0)
gr export "${plots}\rdd_arcsnl_all_time_separate.pdf", as(pdf) replace 


