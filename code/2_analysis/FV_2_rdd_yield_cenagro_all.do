*Preparing census tracts IDs
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

tempfile SegmID
save `SegmID', replace

*Comercial yields
import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA1S70") firstrow clear

rename _all, low

destring s07p21 s07p23 portid, replace
gen yield_sugar_comer=s07p23/s07p21

ren (s07p23 s07p21) (prod_sugar_comer areac_sugar_comer)

*Merge segment ID
merge m:1 portid using `SegmID', keep(1 3) nogen 

*Collapsing at the segment level 
collapse yield_sugar_comer prod_sugar_comer areac_sugar_comer (sum) tprod_sugar_comer=prod_sugar_comer tareac_sugar_comer=areac_sugar_comer, by(segm_id)

tempfile Ysugar
save `Ysugar', replace 

*Comercial grain yields
import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA1S03") firstrow clear

*keeping only vars of interest 
rename _all, low

destring s03p07 s03p02 s03p20 s03p18 portid, replace

gen yield_maize=s03p07/s03p02
gen yield_bean=s03p20/s03p18

ren (s03p07 s03p02 s03p20 s03p18) (prod_maize areac_maize prod_bean areac_bean) 

keep portid fb1p06a fb1p06b yield_* prod* areac*

gen subsistence=0 

tempfile YieldC
save `YieldC', replace

*Comercial yields
import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA2S03") firstrow clear

*keeping only vars of interest 
rename _all, low

destring s03p04 s03p02 s03p15 s03p13 portid, replace

gen yield_maize=s03p04/s03p02
gen yield_bean=s03p15/s03p13

ren (s03p04 s03p02 s03p15 s03p13) (prod_maize areac_maize prod_bean areac_bean) 

keep portid fb1p06a fb1p06b yield_* prod* areac*

gen subsistence=1

*Appending comercial yields
append using `YieldC'
merge m:1 portid using `SegmID', keep(1 3) nogen 

*Creating vars specific to subsistence type 
foreach var in prod_maize areac_maize prod_bean areac_bean yield_maize yield_bean {
	summ `var', d
	replace `var'=. if `var'<`r(p1)' | `var'>`r(p99)' 
	
	gen `var'_comer=`var' if subsistence==0
	gen `var'_subs=`var' if subsistence==1
}

*Collapsing at the segment level 
collapse prod_maize areac_maize prod_bean areac_bean yield_maize yield_bean prod_maize_comer areac_maize_comer prod_bean_comer areac_bean_comer yield_maize_comer yield_bean_comer prod_maize_subs areac_maize_subs prod_bean_subs areac_bean_subs yield_maize_subs yield_bean_subs (sum) tprod_maize=prod_maize tareac_maize=areac_maize tprod_bean=prod_bean tareac_bean=areac_bean tprod_maize_comer=prod_maize_comer tareac_maize_comer=areac_maize_comer tprod_bean_comer=prod_bean_comer tareac_bean_comer=areac_bean_comer tprod_maize_subs=prod_maize_subs tareac_maize_subs=areac_maize_subs tprod_bean_subs=prod_bean_subs tareac_bean_subs=areac_bean_subs, by(segm_id)

*Merging sugar yields 
merge 1:1 segm_id using `Ysugar', nogen 

*Creating total yields
gl prod "tprod_maize tprod_bean tprod_maize_comer tprod_bean_comer tprod_maize_subs tprod_bean_subs tprod_sugar_comer"
gl area "tareac_maize tareac_bean tareac_maize_comer tareac_bean_comer tareac_maize_subs tareac_bean_subs tareac_sugar_comer"

foreach var of global prod{
	replace `var'=`var'*0.1
}

foreach var of global area{
	replace `var'=`var'*0.7
}

gen tyield_maize=tprod_maize/tareac_maize
gen tyield_bean=tprod_bean/tareac_bean
gen tyield_maize_comer=tprod_maize_comer/tareac_maize_comer
gen tyield_bean_comer=tprod_bean_comer/tareac_bean_comer
gen tyield_maize_subs=tprod_maize_subs/tareac_maize_subs
gen tyield_bean_subs=tprod_bean_subs/tareac_bean_subs
gen tyield_sugar_comer=tprod_sugar_comer/tareac_sugar_comer

tempfile Yield
save `Yield', replace 

*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

drop _merge
merge 1:1 segm_id using `Yield', keep(1 3) nogen

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

gl yield "yield_maize yield_bean yield_maize_comer yield_bean_comer yield_sugar_comer yield_maize_subs yield_bean_subs"
gl tyield "tyield_maize tyield_bean tyield_maize_comer tyield_bean_comer tyield_sugar_comer tyield_maize_subs tyield_bean_subs"

*Erasing table before exporting
cap erase "${tables}\rdd_cenagroyield.tex"
cap erase "${tables}\rdd_cenagroyield.txt"
cap erase "${tables}\rdd_cenagrotyield.tex"
cap erase "${tables}\rdd_cenagrotyield.txt"

*Tables
foreach var of global yield{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagroyield.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

*Tables
foreach var of global tyield{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrotyield.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

*Erasing table before exporting
cap erase "${tables}\rdd_cenagroyield.tex"
cap erase "${tables}\rdd_cenagroyield.txt"
cap erase "${tables}\rdd_cenagrotyield.tex"
cap erase "${tables}\rdd_cenagrotyield.txt"

*Tables
foreach var of global yield{

	*RDD with break fe and triangular weights 
	rdrobust `var' z_run_cntrl, all kernel(triangular)
	gl h=e(h_l)
	
	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagroyield.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global tyield{

	*RDD with break fe and triangular weights 
	rdrobust `var' z_run_cntrl, all kernel(triangular)
	gl h=e(h_l)
	
	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrotyield.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}



















*END






