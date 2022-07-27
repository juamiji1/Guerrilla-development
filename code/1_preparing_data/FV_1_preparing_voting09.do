/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Restricting sample
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*keep if elevation2>=200 & river1==0
keep segm_id elevation2
ren segm_id seg_id
gen altitude_river_sample=1

tempfile R
save `R', replace

*Shape
import excel "${data}\gis\electoral_results\mesas\mesas2014.xls", sheet("mesas2014") firstrow clear

keep mesas2014FID mesas2014Name DIGESTYC_Segmentos2007DEPTO DIGESTYC_Segmentos2007COD_DEP DIGESTYC_Segmentos2007MPIO DIGESTYC_Segmentos2007COD_MUN DIGESTYC_Segmentos2007SEG_ID DIGESTYC_Segmentos2007CANTON
ren (mesas2014FID mesas2014Name DIGESTYC_Segmentos2007DEPTO DIGESTYC_Segmentos2007COD_DEP DIGESTYC_Segmentos2007MPIO DIGESTYC_Segmentos2007COD_MUN DIGESTYC_Segmentos2007SEG_ID DIGESTYC_Segmentos2007CANTON) (FID mesa depto codepto muni codmuni seg_id canton)

duplicates tag mesa codepto codmuni, g(dup)
tab dup
drop dup

gen mesa_shape=mesa 

replace mesa="C. E. DE CASERÍO EL MORRO" if mesa=="KIOSKO COMUNITARIO" & canton=="EL MORRO"
replace mesa="C. E. DE CASERÍO GUACHIPILÍN" if mesa=="KIOSKO COMUNITARIO" & canton=="GUACHIPILIN"

*Fixing the municipio and departamento vars 
foreach var in muni depto mesa{
	replace `var'=upper(`var')
	replace `var'=ustrtrim(`var')
	replace `var'=subinstr(`var',"Á","A",.)
	replace `var'=subinstr(`var',"É","E",.)
	replace `var'=subinstr(`var',"Í","I",.)
	replace `var'=subinstr(`var',"Ó","O",.)
	replace `var'=subinstr(`var',"Ú","U",.)
	replace `var'=subinstr(`var',"Ü","U",.)
	replace `var'=subinstr(`var',"Ñ","N",.)
	replace `var'=subinstr(`var',".","",.)
	replace `var'=subinstr(`var',")","",.)
	replace `var'=subinstr(`var',"(","",.)
	replace `var'=subinstr(`var',char(34),"",.)
}

sort depto muni mesa 
gen id2 =_n 

tempfile S
save `S', replace

*Padron
import excel "${data}\gis\electoral_results\padron\2009.xlsx", sheet("Sheet1") firstrow clear
ren _all, low 
ren (coddep codmun codcen) (codepto_v codmuni_v cod_centro)
keep codepto_v codmuni_v cod_centro electores
drop if codepto_v==. | codmuni_v==.

tempfile P
save `P', replace

*Votes
import excel "${data}\gis\electoral_results\resultados\2009\presidente.xls", sheet("Sheet 1") firstrow clear
rename _all, low
ren (coddep nomdep codmun nommun codcen nomcen votcand1 votcand2 votabs votval vototr) (codepto_v depto codmuni_v muni cod_centro mesa arena fmln abstenciones votos_validos votos_otros)
drop if codepto_v==. | codmuni_v==.

collapse (sum) arena fmln abstenciones votos_validos votos_otros, by(codepto_v depto codmuni_v muni cod_centro mesa)

merge 1:1 codepto_v codmuni_v cod_centro using `P', nogen

*Fixing the municipio and departamento vars 
foreach var in muni depto mesa{
	replace `var'=upper(`var')
	replace `var'=ustrtrim(`var')
	replace `var'=subinstr(`var',"Á","A",.)
	replace `var'=subinstr(`var',"É","E",.)
	replace `var'=subinstr(`var',"Í","I",.)
	replace `var'=subinstr(`var',"Ó","O",.)
	replace `var'=subinstr(`var',"Ú","U",.)
	replace `var'=subinstr(`var',"Ü","U",.)
	replace `var'=subinstr(`var',"Ñ","N",.)
	replace `var'=subinstr(`var',".","",.)
	replace `var'=subinstr(`var',")","",.)
	replace `var'=subinstr(`var',"(","",.)
	replace `var'=subinstr(`var',char(34),"",.)
}

*Fixing names 
replace mesa="ALAMEDA ROOSEVELT 1" if mesa=="ALAMEDA ROOSEVELT 2"
replace mesa="ALAMEDA ROOSEVELT 1" if mesa=="ALAMEDA ROOSEVELT 3"
replace mesa="ALAMEDA ROOSEVELT 1" if mesa=="ALAMEDA ROOSEVELT 4"
replace mesa="ALAMEDA ROOSEVELT 1" if mesa=="ALAMEDA ROOSEVELT 5"
replace mesa="ALAMEDA ROOSEVELT 1" if mesa=="ALAMEDA ROOSEVELT 6"
replace mesa="GIMNASIO NACIONAL ADOLFO PINEDA" if mesa=="GIMNASIO NACIONAL  ADOLFO PINEDA"

*collapse (sum) arena fmln abstenciones votos_validos, by(codepto depto codmuni muni cod_centro mesa)
collapse (sum) arena fmln abstenciones votos_validos votos_otros electores, by(depto muni mesa)


sort depto muni mesa
gen id1 =_n 

reclink depto muni mesa using `S', idm(id1) idu(id2) gen(score_link) required(depto muni)

*Picking the one with the highest score
drop if Umesa==""
sort depto muni Umesa score_link
bys depto muni Umesa: egen rank=rank(score_link), f 
keep if rank==1																	// 429 mesas at the end

keep mesa_shape depto muni codepto codmuni seg_id arena fmln abstenciones votos_validos votos_otros electores

tempfile M
save `M', replace

*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/gis\nl_segm_lvl_vars\mesas12_info_sp_onu_91", data("${data}/temp\mesas12_info_sp_onu_91.dta") coord("${data}/temp\mesas12_info_sp_coord_onu_91.dta") genid(pixel_id) genc(coord) replace 

*Loading the data 
use "${data}/temp\mesas14_info_sp_onu_91.dta", clear
keep Name DEPTO COD_DEP MPIO COD_MUN CANTON COD_CAN AREA_ID SEG_ID dst_cnt dst_dsp wthn_cn wthn_ds dst_400 brkf400 cnt_400 cntr400

ren _all, low 
ren (name depto cod_dep mpio cod_mun canton cod_can dst_cnt dst_dsp wthn_cn wthn_ds dst_400 brkf400 cnt_400 cntr400) (mesa_shape depto codepto muni codmuni canton codcanton dist_control dist_disputed within_control within_disputed dist_disputa_breaks_400 disputa_break_fe_400 dist_control_breaks_400 control_break_fe_400)

merge 1:1 codepto codmuni seg_id mesa_shape using `M', nogen 
merge m:1 seg_id using `R', keep(1 3) nogen

*Preparing voting vars 
gen sh_left=fmln/votos_validos									
gen sh_right=arena/votos_validos			
gen turnout=(votos_validos+votos_otros)/electores
gen sh_blanco=abstenciones/votos_validos

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

la var within_control "Guerrilla control"
la var sh_left "Left voting share"
la var sh_right "Right voting share" 
la var turnout "Turnout"
la var sh_blanco "Blank voting share"

*Saving the data 
save "${data}/mesas09_onu_91.dta", replace 

gen win_left=(sh_left>sh_right) if sh_left!=. & sh_right!=.

*Export to csv 
export delimited using "${data}\mesas09_sh.csv", replace


/*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/mesas09_onu_91.dta", clear

*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

gl elec="sh_left sh_right sh_blanco turnout"

*-------------------------------------------------------------------------------
* 						Elections (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_dvsnd_elec09_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_elec09_onu_91.txt"

*RDD with break fe and triangular weights 
rdrobust sh_left z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) 

foreach var of global elec{
	
	*Dependent's var mean
	summ `var' if altitude_river_sample==1, d
	gl mean_y=round(r(mean), .01)
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] if abs(z_run_cntrl)<=${h} & altitude_river_sample==1, vce(r) a(i.${breakfe})
	outreg2 using "${tables}\rdd_dvsnd_elec09_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Resid prediction
	reghdfe `var' ${controls_resid} [aw=tweights] if abs(z_run_cntrl)<=${h} & altitude_river_sample==1, vce(r) a(i.${breakfe}) resid 
	cap drop `var'_r
	predict `var'_r, resid

}

*-------------------------------------------------------------------------------
* 						Elections (Plots)
*-------------------------------------------------------------------------------
*Plot against the distance 
foreach var of global elec{

	preserve

		gen x=round(z_run_cntrl, 0.00001)
		gen n=1

		collapse (mean) `var'_r (sum) n, by(x)
		
		two (scatter `var'_r x if abs(x)<3, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var'_r x [aweight = n] if x<0 & abs(x)<3, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var'_r x [aweight = n] if x>=0 & abs(x)<3, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), xlabel(-3(0.5)3) legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") name(`var'_r, replace)
		gr export "${plots}\rdplot_`var'_r_09.pdf", as(pdf) replace 
		
	restore

}	

*Using different bandwidths
foreach var of global elec{
		
	*Dependent's var mean
	summ `var' if altitude_river_sample==1, d
	gl mean_y=round(r(mean), .01)
	
	*Creating matrix to export estimates
	mat coef=J(3,40,.)
	
	*Estimations
	local h=2
	forval c=1/40{

		*Conditional for all specifications
		gl if "if abs(z_run_cntrl)<=`h' & altitude_river_sample==1"

		*Replicating triangular weights
		cap drop tweights
		gen tweights=(1-abs(z_run_cntrl/`h')) ${if}
		
		*Total Households
		reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
		lincom within_control	
		mat coef[1,`c']= r(estimate) 
		mat coef[2,`c']= r(lb)
		mat coef[3,`c']= r(ub)
		
		local h=`h'+1
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef=2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y}) name(`var', replace)
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness_09.pdf", as(pdf) replace 

}



















