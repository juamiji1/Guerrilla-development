/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Spatial RDD Mechanisms
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl if elevation2>=200 & river1==0, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h} & elevation2>=200 & river1==0"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord dist_capital dist_coast [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 


predict arcsine_nl13_xb, xb
gen sample_reg1=e(sample)

tabstat z_run_cntrl if e(sample)==1, by(within_control) s(N mean sd min p50 max)
hist z_run_cntrl if e(sample)==1 & within_control==1, frac
*70% of the sample

gl if "if abs(z_run_cntrl)<=2 & elevation2>=200 & river1==0"
reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample_reg2=e(sample)

gl if "if abs(z_run_cntrl)<=4 & elevation2>=200 & river1==0"
reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample_reg3=e(sample)

gl if "if abs(z_run_cntrl)<=10 & elevation2>=200 & river1==0"
reghdfe arcsine_nl13 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample_reg4=e(sample)

keep segm_id arcsine_nl13_xb sample_reg*
export excel using "${data}\predicted.xls", firstrow(variables)

