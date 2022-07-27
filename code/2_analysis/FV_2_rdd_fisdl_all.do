
import excel "${data}\fisdl\match_cantones.xlsx", sheet("Sheet1") firstrow clear

tostring dep mun can, replace
replace dep="0"+dep if length(dep)==1
replace mun="0"+mun if length(mun)==1
replace can="0"+can if length(can)==1

gen canton_id=dep+mun+can

duplicates drop canton_id code, force

keep code name departamento municipio canton_id

tempfile CantonId
save `CantonId', replace


import excel "${data}\fisdl\proyectos_fisdl.xlsx", sheet("Hoja1") firstrow clear

ren _all, low
ren (codigodeporyecto nombredelproyecto) (code name)
destring code, replace 

merge m:1 departamento code using `CantonId', nogen

*Fixing vrs
gen n=1 
gen educ=1 if strpos(tipologia, "EDUCACION")>0
gen water=1 if strpos(tipologia, "AGUA")>0 | strpos(tipologia, "SANITARIO")>0 | strpos(tipologia, "LETRINIZACION")>0  
gen electricity=1 if strpos(tipologia, "ELECTRIFICACION")>0
gen roads=1 if strpos(tipologia, "CAMINOS")>0 | strpos(tipologia, "CALLE")>0 | strpos(tipologia, "PUENTE")>0

collapse (mean) montoaprobado aportefisdl (sum) n educ water electricity roads , by(canton_id)

destring canton_id, replace

tempfile FISDL
save `FISDL', replace


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_cantons_info.dta", clear

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
*
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 canton_id using `FISDL', keep(1 3)

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


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
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
* 						(Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_fisdl.tex"
cap erase "${tables}\rdd_fisdl.txt"
cap erase "${tables}\rdd_fisdl_all.tex"
cap erase "${tables}\rdd_fisdl_all.txt"

gl outcomes "n educ water electricity roads fisdl_all fisdl_educ fisdl_water fisdl_electricity fisdl_roads montoaprobado aportefisdl"

foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_fisdl.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

gl outcomes "fisdl_all fisdl_electricity"

foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_fisdl_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}







*END