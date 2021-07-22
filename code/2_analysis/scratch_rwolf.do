/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast c.dist_capital#c.z_run_cntrl c.dist_coast#c.z_run_cntrl"
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"

*-------------------------------------------------------------------------------
* 						
*-------------------------------------------------------------------------------
*P val matrix 
mat p = J(7,3,.)
mat colnames p = "Outcome" "Treatment" "p-value" 

*Outcome counter
forval j=1/7 {
	mat p[`j',1]=`j'
}

*Treatment counter
forvalues j=1/7 {
	mat p[`j',2]=1
}

*Saving p-values 
local i=1
foreach var of global nl{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	test within_control=0
	mat p[`i', 3]=r(p)
	
	local ++i
}


*Get p-values in a data file to use 
drop _all
svmat double p
rename p1 outcome
rename p2 treatment
rename p3 pval

*set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
*set more on




cap ssc install mhtexp
set seed 123
mhtexp ${nl}, treatment(treatment) bootstrap(3000)


* Install latest version
net install wyoung, from("https://raw.githubusercontent.com/reifjulian/wyoung/master") replace

*** New controls command when controls differ across equations
wyoung ${nl}, cmd(reghdfe OUTCOMEVAR within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) familyp(within_control) bootstraps(50) seed(123)



cap ssc install rwolf2

gen educ=mean_educ_years
gen literacy=literacy_rate
 
rwolf2 (reghdfe arcsine_nl13 within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe ln_nl13 within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe nl13_density within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe wmean_nl1 within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe z_wi within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe educ within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe literacy within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})), indepvars(within_control, within_control, within_control, within_control, within_control, within_control, within_control) seed(123) reps(50)


rwolf2 (reg arcsine_nl13 within_control ${controls_resid}, r) (reg z_wi within_control ${controls_resid}, r) , indepvars(within_control, within_control) seed(123) reps(50)




(reghdfe ln_nl13 within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe nl13_density within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe wmean_nl1 within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe z_wi within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe educ within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})) (reghdfe literacy within_control ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe})), indepvars(within_control, within_control, within_control, within_control, within_control, within_control, within_control) seed(123) reps(50)















