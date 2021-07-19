/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Restricting sample
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear

keep if elevation2>=200 & river1==0
keep segm_id
ren segm_id seg_id
gen altitude_river_sample=1

tempfile R
save `R', replace

*Votes
import excel "${data}\gis\electoral_results\resultados\2014\presidente_a.xlsx", sheet("Sheet 1") firstrow clear
rename _all, low
ren (nom_depto nom_munic nom_centro) (depto muni mesa)

collapse (sum) arena fmln fps psp unidad votos_validos impugnados nulos abstenciones otros_votos vv_mas_otros faltantes sobrantes inutilizadas totales, by(depto muni mesa mesa cod_centro)

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
	replace `var'=subinstr(`var',char(34),"",.)
}

replace mesa="CASA COMUNAL, CANTON SAN ANDRES" if mesa=="CALLE PRINCIPAL, CANTON SAN ANDRES"

tempfile V
save `V', replace

*Padron
import excel "${data}\gis\electoral_results\padron\2014.xlsx", sheet("Sheet1") firstrow clear
ren _all, low 
drop if nom_dep=="" | nom_dep=="Nom_Dep" | nom_dep=="35"
replace electores=f if _n>1564
replace nom_centro=f if nom_centro==""

ren (nom_dep nom_mun nom_centro) (depto muni mesa)
keep depto muni mesa electores
destring electores, replace

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
	replace `var'=subinstr(`var',char(34),"",.)
}

merge 1:1 depto muni mesa using `V', keep(1 3) nogen

sort depto muni mesa
gen id2 =_n 

tempfile P
save `P', replace

*Shape
import excel "${data}\gis\electoral_results\mesas\mesas2014.xls", sheet("mesas2014") firstrow clear

keep mesas2014FID mesas2014Name DIGESTYC_Segmentos2007DEPTO DIGESTYC_Segmentos2007COD_DEP DIGESTYC_Segmentos2007MPIO DIGESTYC_Segmentos2007COD_MUN DIGESTYC_Segmentos2007SEG_ID DIGESTYC_Segmentos2007CANTON
ren (mesas2014FID mesas2014Name DIGESTYC_Segmentos2007DEPTO DIGESTYC_Segmentos2007COD_DEP DIGESTYC_Segmentos2007MPIO DIGESTYC_Segmentos2007COD_MUN DIGESTYC_Segmentos2007SEG_ID DIGESTYC_Segmentos2007CANTON) (FID mesa depto codepto muni codmuni seg_id canton)

duplicates tag mesa codepto codmuni, g(dup)
tab dup

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
	replace `var'=subinstr(`var',char(34),"",.)
}

sort depto muni mesa 
gen id1 =_n 

reclink depto muni mesa using `P', idm(id1) idu(id2) gen(score_link) required(depto muni)
keep mesa_shape depto muni codepto codmuni seg_id electores arena-totales

tempfile M
save `M', replace


*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/gis\nl_segm_lvl_vars\mesas14_info_sp_onu_91", data("${data}/temp\mesas14_info_sp_onu_91.dta") coord("${data}/temp\mesas14_info_sp_coord_onu_91.dta") genid(pixel_id) genc(coord) replace 

*Loading the data 
use "${data}/temp\mesas14_info_sp_onu_91.dta", clear
keep Name DEPTO COD_DEP MPIO COD_MUN CANTON COD_CAN AREA_ID SEG_ID dst_cnt dst_dsp wthn_cn wthn_ds dst_400 brkf400 cnt_400 cntr400

ren _all, low 
ren (name depto cod_dep mpio cod_mun canton cod_can dst_cnt dst_dsp wthn_cn wthn_ds dst_400 brkf400 cnt_400 cntr400) (mesa_shape depto codepto muni codmuni canton codcanton dist_control dist_disputed within_control within_disputed dist_disputa_breaks_400 disputa_break_fe_400 dist_control_breaks_400 control_break_fe_400)

merge 1:1 codepto codmuni seg_id mesa_shape using `M', nogen 
merge m:1 seg_id using `R', keep(1 3) nogen

*Preparing voting vars 
gen sh_left=fmln/votos_validos
*gen sh_right=(arena+fps+unidad)/votos_validos
gen sh_right=(arena)/votos_validos
gen turnout=vv_mas_otros/electores
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
save "${data}/mesas14_onu_91.dta", replace 

gen win_left=(sh_left>sh_right) if sh_left!=. & sh_right!=.

*Export to csv 
export delimited using "${data}\mesas14_sh.csv", replace


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
*Global of border FE for all estimate
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

gl elec="sh_left sh_right sh_blanco turnout"

*-------------------------------------------------------------------------------
* 						Elections (Table)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_dvsnd_elec_onu_91.tex"
cap erase "${tables}\rdd_dvsnd_elec_onu_91.txt"

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
	outreg2 using "${tables}\rdd_dvsnd_elec_onu_91.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
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

		gen x=round(z_run_cntrl, 0.09)
		gen n=1

		collapse (mean) `var'_r (sum) n, by(x)
		
		two (scatter `var'_r x if abs(x)<1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) (lfitci `var'_r x [aweight = n] if x<0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) (lfitci `var'_r x [aweight = n] if x>=0 & abs(x)<1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), xlabel(-1(0.2)1) legend(order(1 "Mean residual per bin" 3 "Linear prediction" 2 "95% CI") cols(3)) l2title("Estimate magnitud", size(medsmall)) b2title("Distance to border (Kms)", size(medsmall)) xtitle("") 
		gr export "${plots}\rdplot_`var'_r.pdf", as(pdf) replace 
		
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
	local h=0.3
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
		
		local h=`h'+0.1	
	}
		
	*Labeling coef matrix rows according to each bw
	mat coln coef=.3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2
	
	*Plotting estimates 
	coefplot (mat(coef[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Kms)") note(Mean of Outcome: ${mean_y}) 
	gr export "${plots}\rdd_dvsnd_`var'_bw_robustness.pdf", as(pdf) replace 

}















*END
