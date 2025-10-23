** PREPARE ADDITIONAL VARIABLES **
clear all 

import delimited "${data}/localcontinuity/Output Data/BECs1974.csv", clear
replace baseec=0 if baseec==. 
 gen d_name = ustrlower( ustrregexra( ustrnormalize(adm1_es, "nfd" ) , "\p{Mark}", "" )  )
 gen m_name= ustrlower( ustrregexra( ustrnormalize(adm2_es, "nfd" ) , "\p{Mark}", "" )  )
 rename baseec baseec74
keep d_name m_name baseec74
save "${data}/localcontinuity/Output Data/BECs1974.dta", replace


clear all 

import delimited "${data}/localcontinuity/Output Data/BECs2007.csv", clear
replace baseec07=0 if baseec07==. 
 gen d_name = ustrlower( ustrregexra( ustrnormalize(adm1_es, "nfd" ) , "\p{Mark}", "" )  )
 gen m_name= ustrlower( ustrregexra( ustrnormalize(adm2_es, "nfd" ) , "\p{Mark}", "" )  )
keep d_name m_name baseec07
save "${data}/localcontinuity/Output Data/BECs2007.dta", replace


** MERGE TO MAIN DATASET **

use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear


 gen d_name = ustrlower( ustrregexra( ustrnormalize(depto_name, "nfd" ) , "\p{Mark}", "" )  )
 gen m_name= ustrlower( ustrregexra( ustrnormalize(muni_name, "nfd" ) , "\p{Mark}", "" )  )
 
 
 replace m_name="san buenaventura" if m_name=="san buena ventura"
 replace m_name="mercedes umana" if m_name=="mercedes uma�a"
 replace m_name="santo domingo" if m_name=="santo domingo de guzman"
 replace m_name="delgado" if m_name=="ciudad delgado"
 replace m_name="san rafael" if m_name=="san rafael oriente"
 replace m_name="opico" if m_name=="san juan opico" 
  replace m_name="san jose las flores" if m_name=="las flores" 
 replace m_name="nueva san salvador" if m_name=="santa tecla" 
 
 
 replace d_name="cabanas" if d_name=="caba�as" 

 
 
merge m:1 d_name m_name using "${data}/localcontinuity/Output Data/BECs1974.dta", gen(base_merge)
merge m:1 d_name m_name using "${data}/localcontinuity/Output Data/BECs2007.dta", gen(base_merge2)

* No info from unmergeable places
replace baseec74=0 if baseec74==.
replace baseec07=0 if baseec07==.


gen weak_rb=(depto_name=="USULUTAN"|depto_name=="LA PAZ"|depto_name=="LA LIBERTAD")
gen strong_rb=(weak_rb==0)

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"


*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) 
*covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Night Light Luminosity (2013)"
la var mean_educ_years "Years of Education (2007)"
la var z_wi "Wealth Index (2007)"



gl nl "arcsine_nl13 z_wi mean_educ_years"

*************************
cap drop interact
gen interact=baseec07*within_control


local r replace
*Heterogeneous analysis results  
foreach var of global nl{
	
	*Table

	reghdfe `var' ${controls} interact i.baseec07 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
		
outreg2 using "${tables}/Table 8d.tex", tex(frag) keep(within_control interact) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons nor2 `r'

local r append 
		

}	
*************************
preserve 
import delimited "${data}/DistanceCensustoFMLN.csv", clear
 rename (min) (d_fmlnbase)
gen str8 segm_id = string(inputid, "%08.0f")
 keep segm_id d_fmlnbase 
 replace d_fmlnbase=d_fmlnbase/1000
 save "${data}/DistanceCensustoFMLN", replace
restore 
drop if segm_id==""
merge 1:1 segm_id using "${data}/DistanceCensustoFMLN", nogen 
cap drop interact
 sum d_fmlnbase, d
 local close r(p25)
  gen close=d_fmlnbase<=`close'
gen close2=close==1 & strong_rb==1
 
gen interact=close2*within_control


local r replace 

foreach var of global nl1{
	foreach control in close2 {
	cap drop interaction
	gen interaction=`control'*within_control

	*Table
	reghdfe `var' ${controls} interact [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	tab close2 if e(sample)==1
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/Table 8c.tex", tex(frag) keep(within_control interact) label nonote nocons nor2 `r' noobs 
	local r append
 }
}

*************************
cap drop interact
gen interact=strong_rb*within_control


local r replace
*Heterogeneous analysis results  
foreach var of global nl{
	
	*Table

	reghdfe `var' ${controls} interact i.strong_rb [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
		
	outreg2 using "${tables}/Table 8b.tex", tex(frag) keep(within_control interact) label nonote nocons nor2 `r' noobs 
	local r append 
		

}	

***********************

cap drop interact
gen interact=baseec74*within_control


local r replace
*Heterogeneous analysis results  
foreach var of global nl{
	
	*Table

	reghdfe `var' ${controls} interact i.baseec74 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	

	outreg2 using "${tables}/Table 8.tex", tex(frag) keep(within_control interact) label nonote nocons nor2 `r' noobs 
	local r append 
		

}	
*****************

foreach x in b c d {
preserve 
 insheet using "${tables}/Table 8`x'.txt", nonames clear
 save "${tables}/Table 8`x'" , replace 

restore 
}


preserve

insheet using "${tables}/Table 8.txt", nonames clear
append using "${tables}/Table 8b"
append using "${tables}/Table 8c"
append using "${tables}/Table 8d"


drop v2 
insobs 2, before(1)
replace v1 = "" in 4
replace v3 = "" in 4
replace v3 = "Night Light Luminosity " in 1
replace v3 = "(2013)" in 2
replace v4 = "Wealth Index" in 1
replace v4 = "(2007)" in 2
replace v5 = "Years of Education (2007)" in 1
replace v5 = "Years of Education" in 1
replace v5 = "(2007)" in 2
replace v4 = "" in 4
replace v5 = "" in 4
replace v1 = "Panel A: Heterogeneous Effects on Regions with Base Ecclesial Communities in 1974" in 4
replace v1 = "Guerrilla control" in 6
replace v1 = "Guerrilla control" in 14
replace v1 = "Guerrilla control" in 22
replace v1 = "Guerrilla control" in 30
drop in 11/12
drop in 11
insobs 1, before(11)
drop in 17/18

drop in 23/24
replace v1 = "Panel D: Heterogeneous Effects on Regions with Base Ecclesial Communities in 2007" in 22
replace v1 = "Panel C: Heterogeneous Effects on Regions Closer to FMLN" in 16
replace v1 = "Panel B: Heterogeneous Effects on Regions with Strong Self-Governance Promotion" in 10
replace v1 = "Guerrila control \$\times\$ Had BEC in 1974" in 8
replace v1 = "Guerrilla control \$\times\$ Strong Rebel Governance" in 14
replace v1 = "Guerrilla control \$\times\$ Close to FMLN" in 20
replace v1 = "Guerrilla control \$\times\$ Had BEC in 2007" in 26


local Pen=_N-1
gen n=_n 
replace n=90000 in `Pen'
sort n 
drop n

dataout, tex save("${tables}/rdd_main_selfgovernance") replace nohead  midborder(3)
restore 


foreach x in b c d {
preserve 
	cap erase "${tables}/Table 8`x'.tex"
	cap erase "${tables}/Table 8`x'.txt"
	cap erase "${tables}/Table 8`x'.dta"
restore 
}




