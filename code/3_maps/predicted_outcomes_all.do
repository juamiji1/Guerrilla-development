/*-----------------------------------------------------------------------------
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
use "${data}/sample_try.dta", clear

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

*Global of outcomes
gl outcomes "arcsine_nl13 z_wi mean_educ_years bean05 maize05 coffe05 sugar05 h_bean05 h_maize05 h_coffee05 h_sugar05 prod_bean05 prod_maize05 prod_coffee05 prod_sugar05 size_comer sizet_comer sizec_comer sh_prod_own_comer si_all_segm si_comer_segm si_subs_segm z_index_pp z_index_ep z_index_ap z_index_trst"

*Against the distance
foreach var of global outcomes{
	*Predicting outcomes
	reghdfe `var' ${controls_resid} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_r
	predict `var'_r, resid
}

foreach var of global outcomes{
	*Predicting outcomes
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	cap drop `var'_xb
	predict `var'_xb, xb
	
	gen `var'_xb_m=`var'_xb
	replace `var'_xb_m=. if `var'==.
}

*Sample indicator
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample_reg=e(sample)

tab region if sample_reg==1
tabstat total_pop if sample_reg==1, by(region) s(N sum mean sd  min max)

*zona central 
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if} & region==2, vce(r) a(i.${breakfe}) 
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if} & region==3, vce(r) a(i.${breakfe}) 

*zona oeste
reghdfe z_index_trst ${controls} [aw=tweights] ${if} & region==2, vce(r) a(i.${breakfe}) 
reghdfe z_index_trst ${controls} [aw=tweights] ${if} & region==3, vce(r) a(i.${breakfe}) 

*Rename
ren (COD_D COD_M COD_C MPIO CANTO) (codepto codmuni codcanton muni_name canto_name)

preserve
	keep if sample_reg==1 & region==3
	keep segm_id codepto codmuni codcanton depto_name muni_name canto_name within_control region total_pop 
	export delimited using "${data}\info_consulting_sample.csv", replace
restore

preserve 
	keep segm_id sample_reg within_control region total_pop
	export delimited using "${data}\info_consulting.csv", replace
restore 

keep segm_id codepto codmuni codcanton ${outcomes} *_r *_xb *_xb_m sample_reg within_control z_run_cntrl region total_pop
export delimited using "${data}\predicted_outcomes_all.csv", replace




* observaciones en los 41 segmentos 
* Cuantos 41 y N en controladas vs no controladas 
*

*NIght light a nivel de segmento 
*Size de comerciantes 

*Lista de hogar con jefe y 30 a 70 annos 








