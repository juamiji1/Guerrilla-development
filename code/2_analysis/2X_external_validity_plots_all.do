use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Global of outcomes
gl nl1 "arcsine_nl13 z_wi mean_educ_years"

*PLot of external validity 
summ z_run_cntrl, d
gen z_integer=round(z_run_cntrl)
replace z_integer=z_integer+67

*Plots of structural transformation at the 1st level
foreach var in arcsine_nl13 z_wi mean_educ_years{
	
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
	
	coefplot est1, xline(18) coeflabels(${coeflabels1}) vert recast(connected) ciopts(recast(rcap)) xlabel(,labsize(small) angle(45)) name(`var', replace)
	gr export "${plots}/mean_`var'.pdf", as(pdf) replace
	
}



*END