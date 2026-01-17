/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: BTJS
TOPIC: Investement projects in el salvador at the canton lvl 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* Preparing the data 
* 
*-------------------------------------------------------------------------------
*Preparing the canton ID
import excel "${data}/fisdl/match_cantones.xlsx", sheet("Sheet1") firstrow clear

tostring dep mun can, replace
replace dep="0"+dep if length(dep)==1
replace mun="0"+mun if length(mun)==1
replace can="0"+can if length(can)==1

gen canton_id=dep+mun+can

duplicates drop canton_id code, force

keep code name departamento municipio canton_id

tempfile CantonId
save `CantonId', replace

*Importing the FISDL info
import excel "${data}/fisdl/proyectos_fisdl.xlsx", sheet("Hoja1") firstrow clear
gen YEAR=dofc(FECHAINGRESO) 
replace YEAR=year(YEAR)

ren _all, low
ren (codigodeporyecto nombredelproyecto) (code name)
destring code, replace 

merge m:1 departamento code using `CantonId', nogen

*Fixing vars
gen n=1 
gen educ=1 if strpos(tipologia, "EDUCACION")>0
gen water=1 if strpos(tipologia, "AGUA")>0 | strpos(tipologia, "SANITARIO")>0 | strpos(tipologia, "LETRINIZACION")>0  
gen electricity=1 if strpos(tipologia, "ELECTRIFICACION")>0
gen roads=1 if strpos(tipologia, "CAMINOS")>0 | strpos(tipologia, "CALLE")>0 | strpos(tipologia, "PUENTE")>0

gen post95=year>1995
gen post96=year>1996
gen post97=year>1997
gen post98=year>1998
gen post99=year>1999
gen post00=year>2000
gen post01=year>2001
gen post02=year>2002
gen post03=year>2003
gen post04=year>2004
gen post05=year>2005
gen post06=year>2006
gen post07=year>2007
gen post08=year>2008
gen post09=year>2009

foreach yearthresh in 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 {
preserve

collapse (mean) montoaprobado aportefisdl (sum) n educ water electricity roads , by(post`yearthresh' canton_id)

destring canton_id, replace

tempfile FISDL
save `FISDL', replace

*Loading the shapefile's info  
use "${data}/temp/slvShp_cantons_info.dta", clear

ren (nl elev2 wmen_nl dst_cnt dst_dsp wthn_cn wthn_ds cn_1000 cnt1000 cnt_400 cntr400) (nl13_density elevation wmean_nl1 dist_control dist_disputed within_control within_disputed dist_control_breaks_1000 control_break_fe_1000 dist_control_breaks_400 control_break_fe_400)

*Canton ID
gen canton_id=COD_DEP+COD_MUN+COD_CAN
destring canton_id, replace 

*To kms
replace dist_control=dist_control/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

*-------------------------------------------------------------------------------
* 					Merging the FISDL data 
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:m canton_id using `FISDL', keep(1 3)

*Fixing vars
replace n=0 if n==.
replace educ=0 if educ==.
replace water=0 if water==.
replace electricity=0 if electricity==.
replace roads=0 if roads==.

gen fisdl_all=(n>0)
gen fisdl_educ=(educ>0)
gen fisdl_water=(water>0)
gen fisdl_electricity=(electricity>0)
gen fisdl_roads=(roads>0)


* Fill in the panel data:

 replace post`yearthresh'=0 if post`yearthresh'==. // avoids conflict with tssfill. Innocous assumption.
 xtset canton_id post`yearthresh'
 tsfill, full

 gen negmodate=-post`yearthresh'
 
 foreach usefulvar in control_break_fe_400 within_control z_run_cntrl { 
 	bysort canton_id (post`yearthresh'): carryforward `usefulvar', replace
	bysort canton_id (negmodate): carryforward `usefulvar', gen(aux)
	replace `usefulvar'=aux if `usefulvar'==.
	drop aux
 }
 
 replace fisdl_all=0 if n==.
clonevar within_control`yearthresh'=within_control
label var within_control`yearthresh' "`yearthresh'"
*-------------------------------------------------------------------------------
* 				   Preparing the set-up
*
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl y "fisdl_all"
gl breakfe="control_break_fe_400"
*gl controls "within_control`yearthresh' i.within_control`yearthresh'#c.z_run_cntrl z_run_cntrl"
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

save "${plots}/test_`yearthresh'", replace
restore
}
*-------------------------------------------------------------------------------
* 				       FISDL results (Table)
*-------------------------------------------------------------------------------

mat coef=J(3,30,.)
local c=1

*Tables
foreach yearthresh in 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 {
use "${plots}/test_`yearthresh'.dta", clear 
gl controls "within_control`yearthresh' i.within_control`yearthresh'#c.z_run_cntrl z_run_cntrl"


foreach var of global y {
	foreach year in 1 {
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if} & post`yearthresh'==`year' , vce(r) a(i.${breakfe}) 
	lincom within_control`yearthresh' 	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local ++c	

	}

}
cap erase "${plots}/test_`yearthresh'.dta"
}

*Labeling coef matrix rows according to each bw
mat coln coef= 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09
	
*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(small) angle(45)) l2title("Effect on Night Light (Arcsine) ") b2title("Year") ylabel(-.25(.05)0) graphregion(color(white)) ysc(r(-.25 .25)) ylabel(-.25 -.1 0 .1 .25)
gr export "${plots}/rdd_publicgoods_time_allpools", as(pdf) replace 

********************************************************************************
*							SCHOOLS
********************************************************************************

* DMS to Degrees

use "${data}/escuelas/escuelas99_18.dta", clear

gen y = latitud_grados + (latitud_minutos/60) + (latitud_segundos/3600)
gen x =-(longitud_grados + (longitud_minutos/60) + (longitud_segundos/3600))
drop if x==. | y==.
save "${data}/SchoolsCoords", replace

* Run Mapping Schools.R

import delimited "${data}/Schools&Segms.csv", clear 
gen schools=1 

collapse (sum) schools, by (year seg_id)

rename seg_id segm_id
reshape wide schools, i(segm_id) j(year)
save "${data}/Schools_segm_lvl", replace

use "${data}/night_light_13_segm_lvl_onu_91_nowater", clear
merge 1:1 segm_id using "${data}/Schools_segm_lvl", nogen

forvalues j=1999/2018 {
	replace schools`j'=0 if schools`j'==.
	gen schools`j'pp=schools`j'*100000/total_pop
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

cls 
gl hh1 "schools1999pp schools2000pp schools2001pp schools2002pp schools2003pp schools2004pp schools2005pp schools2006pp schools2007pp schools2008pp schools2009pp schools2010pp schools2011pp schools2012pp schools2013pp schools2014pp schools2015pp schools2016pp schools2017pp schools2018pp"

*Creating matrix to export estimates
mat coef=J(3,20,.)

local c=1

*Tables
foreach var of global hh1{
	
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) keepsingleton
		lincom within_control	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local ++c	
	*summ `var' if e(sample)==1 & within_control==0, d
	*gl mean_y=round(r(mean), .01)
	
	*outreg2 using "${tables}\rdd_public_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}



*Labeling coef matrix rows according to each bw
mat coln coef= 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18
	
*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(small) angle(45)) l2title("Effect on Elementary Schools" "per 100k Population") b2title("Year") graphregion(color(white))
gr export "${plots}/rdplot_all_schools.png", as(png) replace 


