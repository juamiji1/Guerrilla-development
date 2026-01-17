/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Results for occupations by ISIC category 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

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

*Labels for outcomes
la var isic1_agr "Agriculture"
la var isic1_ind "Industry"
la var isic1_serv "Services"
la var isic2_agr "Agriculture"
la var isic2_cons "Construction" 
la var isic2_man "Manufacture"
la var isic2_mserv "Market services"
la var isic2_min "Mining and energy"
la var isic2_nmserv "Non-market services"
la var agr_azcf "Grow cereals and fruits"  // cereals and fruits
la var agr_azcf_v2 "Grow food (v2)"
la var man_azcf "Manufacture food"
la var man_azcf_v2 "Manufacture food (v2)"
la var serv_azcf "Selling agro product"
la var serv_azcf_v2 "Selling agro (v2)"


*-------------------------------------------------------------------------------
*PLot of structural transformation 
*-------------------------------------------------------------------------------
summ z_run_cntrl, d
gen z_integer=round(z_run_cntrl)
replace z_integer=z_integer+67

gl isic1 "isic1_agr isic1_ind isic1_serv agr_azcf"


*Plots of structural transformation at the 1st level
foreach var in $isic1 {
	
	*Capturing the means
	eststo est1: mean `var' if z_integer>49, over(z_integer)
	
	*Capturing and fixing the labels of the coefficients for the coefplots
	mat b=e(b)
	local cnames: colnames b
	tokenize "`cnames'"
	local i = 1
	local coeflabels =""
	while "``i''" != "" {
		cap dis ustrregexm("``i''","[0-9]{2}")
		local number=  ustrregexs(0)
				local number=`number'-67
		local arg="``i''"+"="+"`number'"
		local coeflabels= "`coeflabels'"+" " +"`arg'"
		
		local ++i
	}
	gl coeflabels1=subinstr("`coeflabels'","bn","",1)
	
	coefplot est1, xline(18) coeflabels(${coeflabels1}) vert recast(connected) ciopts(recast(rcap)) xlabel(,labsize(small) angle(45)) graphregion(color(white))
	gr export "${plots}/mean_`var'.pdf", as(pdf) replace
	
}
*END
