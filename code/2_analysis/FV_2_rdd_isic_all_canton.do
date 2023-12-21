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
use "${data}/temp\census9207_canton_lvl.dta", clear 

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
la var isic1_agr92 "Agriculture"
la var isic1_ind92 "Industry"
la var isic1_serv92 "Services"
la var agr_azcf92 "Grow cereals and fruits"  // cereals and fruits

*-------------------------------------------------------------------------------
* 						Results (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl isic1 "isic1_agr92 isic1_ind92 isic1_serv92 agr_azcf92"

*Erasing table before exporting
local r replace

foreach var of global isic1{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_isic_all_canton.tex", tex(frag) keep(within_control) nor2 addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	
	local r append
	
}


preserve 
	insheet using "${tables}/rdd_isic_all_canton.txt", nonames clear
	  
	replace v1 = "Guerrilla control" in 4
	drop v2 
	drop in 2
	insobs 1, before(1)

	replace v3 = "Agriculture (1992)" in 1
	replace v4 = "Industry (1992)" in 1
	replace v5 = "Services (1992)" in 1
	replace v6 = "Growing Subsistence Crops (1992)" in 1
	dataout, tex save("${tables}/rdd_isic_all_canton_draft") replace nohead  midborder(2)
	 
restore


*-------------------------------------------------------------------------------
*PLot of structural transformation 
*-------------------------------------------------------------------------------
summ z_run_cntrl, d
gen z_integer=round(z_run_cntrl)
replace z_integer=z_integer+61 // Translating thex axis so it does admit the negative numbers

rename (isic1_agr92 isic1_ind92 isic1_serv92) (isic1_agr isic1_ind isic1_serv)

*Plots of structural transformation at the 1st level
foreach var in isic1_agr isic1_ind isic1_serv {
	
	*Capturing the means
	eststo est1: mean `var' if z_integer>44, over(z_integer)
	
	*Capturing and fixing the labels of the coefficients for the coefplots
	mat b=e(b)
	local cnames: colnames b
	tokenize "`cnames'"
	local i = 1
	local coeflabels =""
	while "``i''" != "" {
		cap dis ustrregexm("``i''","[0-9]{2}")
		local number=  ustrregexs(0)
				local number=`number'-61
		local arg="``i''"+"="+"`number'"
		local coeflabels= "`coeflabels'"+" " +"`arg'"
		
		local ++i
	}
	gl coeflabels1=subinstr("`coeflabels'","bn","",1)
	
	coefplot est1, xline(16, lp(shortdash)) coeflabels(${coeflabels1}) vert recast(connected) ciopts(recast(rcap)) xlabel(,labsize(small) angle(45))
	gr export "${plots}/mean_`var'92.pdf", as(pdf) replace
	
}






*END