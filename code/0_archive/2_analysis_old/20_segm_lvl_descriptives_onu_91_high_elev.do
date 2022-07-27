/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
TOPIC: Local continuity testing 
DATE: 
AUTHORS: 
RA: JMJR

NOTES: The recommended altitud is 300 masml
------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Descriptives of the elevation distribution
*-------------------------------------------------------------------------------
*Pixel level data 
use "${data}/night_light_13_pxl_lvl_onu_91.dta", clear 

*Checking the elevation distribution 
hist elevation2, freq xtitle("Elevation (mamsl)")
gr export "${plots}\hist_elev_pxl.pdf", as(pdf) replace 

summ elevation2, d
tabstat elevation2, by(within_fmln) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)
tabstat elevation2, by(within_control) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)

*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91.dta", clear 

*Checking the elevation distribution 
hist elevation2, freq xtitle("Elevation (mamsl)")
gr export "${plots}\hist_elev_segm.pdf", as(pdf) replace 

summ elevation2, d
tabstat elevation2, by(within_fmln) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)
tabstat elevation2, by(within_control) s(N mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)

*-------------------------------------------------------------------------------
* Within vs. outside FMLN-dominated zone (high vs low estimates)
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"

*Creating matrices to export estimates
forval i=1/3{
	mat coef`i'=J(3,40,.)
}

local h=0.1
forval c=1/40{
	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h' & elevation2>=200 & river1==0, vce(r) a(i.${breakfe}) 
	lincom within_control
	mat coef1[1,`c']= r(estimate) 
	mat coef1[2,`c']= r(lb)
	mat coef1[3,`c']= r(ub)

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h' & elevation2<200 & river1==0
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h' & elevation2<200 & river1==0, vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef2[1,`c']= r(estimate) 
	mat coef2[2,`c']= r(lb)
	mat coef2[3,`c']= r(ub)

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/`h')) if abs(z_run_cntrl)<=`h' & river1==0
	
	*Estimating elevation results
	reghdfe elevation2 within_control i.within_control#c.z_run_cntrl z_run_cntrl x_coord y_coord [aw=tweights] if abs(z_run_cntrl)<=`h' & river1==0, vce(r) a(i.${breakfe}) 
	lincom within_control	
	mat coef3[1,`c']= r(estimate) 
	mat coef3[2,`c']= r(lb)
	mat coef3[3,`c']= r(ub)
	
	local h=`h'+0.1
}

forval i=1/3{
	mat coln coef`i'= .1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4
}

*Plotting estimates 
coefplot (mat(coef1[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Km)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91_high.pdf", as(pdf) replace 

coefplot (mat(coef2[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Km)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91_low.pdf", as(pdf) replace 

coefplot (mat(coef3[1]), ci((2 3)) label("Within FMLN-dominated zone")), vert recast(line) lwidth(*2) color(gs2%70) ciopts(recast(rarea) lpattern(dash) color(gs6%40)) yline(0) ylabel(,labsize(small)) xlabel(,labsize(tiny)) l2title("Coeficient magnitud") b2title("Bandwidth (Km)")
gr export "${plots}\rdd_dvsnd_elev_bw_robustness_segm_91_all.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Summary stats 
*-------------------------------------------------------------------------------
la var within_control "Segment under guerrilla control"

mat HA=J(1,5,.)
mat HB=J(1,5,.)
mat HC=J(1,5,.)
mat rown HA="Panel A"
mat rown HB="Panel B"
mat rown HC="Panel C"

tabstat within_control z_run_cntrl if elevation2>=200 & river1==0, s(mean sd min max N) save
tabstatmat A
mat A=A'

tabstat nl13_density arcsine_nl13 ln_nl13 wmean_nl1 elevation2 slope rugged hydrography mean_coffee mean_cotton mean_dryrice mean_wetrice mean_bean mean_sugarcane rain_z min_temp_z max_temp_z rail_road dist_coast dist_capital if elevation2>=200 & river1==0, s(mean sd min max N) save
tabstatmat B
mat B=B'

tabstat z_wi sewerage_sh pipes_sh electricity_sh garbage_sh total_hospitals total_schools total_pop female_head sex_sh mean_age had_child_rate mean_educ_years literacy_rate asiste_rate total_migrant war_migrant sex_migrant_sh remittance_rate arrived_war moving_pop moving_sh pea_pet po_pet wage_pet work_hours public_pet private_pet boss_pet independent_pet if elevation2>=200 & river1==0, s(mean sd min max N) save
tabstatmat C
mat C=C'

mat S=HA\A\HB\B\HC\C

tempfile X X1 X2 X3 X4
frmttable using `X', statmat(S) ctitle("", "Mean","SD", "Min", "Max", "Obs") sdec(3,3,3,3,0) multicol(2,1,3;5,1,3;20,1,3) varlabels fragment tex nocenter replace  	
filefilter `X' `X1', from("{tabular}\BS\BS") to("{tabular}") replace
filefilter `X1' `X2', from("multicolumn{3}{c}") to("multicolumn{3}{l}") replace
filefilter `X2' `X3', from("Panel A") to("\BStextit{Panel A: Ceasefire map of 1991}") replace
filefilter `X3' `X4', from("Panel B") to("\BStextit{Panel B: Geographic characteristics}") replace
filefilter `X4' "${tables}/summary_stats.tex", from("Panel C") to("\BStextit{Panel C: Socioeconomic characteristics (2007 census)}") replace

*Fixing label for regressions again
la var within_control "Guerrilla control"

*Histograms 
hist z_run_cntrl if elevation2>=200 & river1==0, freq bcolor(gs7%40) xline(0, lcolor(red) lpattern(dash) lwidth(thick))
gr export "${plots}\hist_z_cntrl1.pdf", as(pdf) replace 
hist z_run_cntrl if abs(z_run_cntrl)<10 & elevation2>=200 & river1==0, freq bcolor(gs7%40) xline(0, lcolor(red) lpattern(dash) lwidth(thick))
gr export "${plots}\hist_z_cntrl2.pdf", as(pdf) replace 
hist z_run_cntrl if abs(z_run_cntrl)<2 & elevation2>=200 & river1==0, freq bcolor(gs7%40) xline(0, lcolor(red) lpattern(dash) lwidth(thick))
gr export "${plots}\hist_z_cntrl3.pdf", as(pdf) replace 




*END


