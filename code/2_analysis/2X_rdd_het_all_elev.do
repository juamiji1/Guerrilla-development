*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*creating important vars 
summ dist_coast, d
gen p50_dist_coast=(dist_coast>=`r(p50)')
gen wxdcst=within_control*p50_dist_coast

summ dist_city45, d
gen p50_dist_city45=(dist_city45>=`r(p50)')
gen wxdcty=within_control*p50_dist_city45

summ dist_road80, d
gen p50_dist_road80=(dist_road80>=`r(p50)')
gen wxrd80=within_control*p50_dist_road80

summ dist_capital, d
gen p50_dist_capital=(dist_capital>=`r(p50)')
gen wxdcptl=within_control*p50_dist_capital

gen dens_pop_bornbef80=pop_bornbef80_always/AREA_K
summ dens_pop_bornbef80, d
gen p50_pop_dens_80=(dens_pop_bornbef80>=`r(p50)')
gen wxpopd=within_control*p50_pop_dens_80

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl elevation2 c.elevation2#c.z_run_cntrl"

*RDD with break fe and triangular weights 
gen exz=elevation2*z_run_cntrl
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular) covs(elevation2 exz)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Labels for outcomes
la var arcsine_nl13 "Arcsine"
la var ln_nl13 "Logarithm"
la var nl13_density "Level"
la var wmean_nl1 "Weighted"
la var total_schools "Total Schools"
la var total_matricula "Total Enrollment"
la var literacy_rate "Literacy Rate"
la var asiste_rate "Attended School Rate"
la var mean_educ_years "Years of Education"
la var z_wi "Wealth Index"
la var z_wi_iqr "Wealth Index Range (p75-p25)"
la var z_wi_iqr2 "Wealth Index Range (p95-p5)"
la var z_wi_iqr3 "Wealth Index Range (p90-p10)"
la var z_wi_p50 "Median Wealth Index"
la var wxdcst "Controlled $\times$ I(coast)"
la var wxdcty "Controlled $\times$ I(city45)"
la var wxdcptl "Controlled $\times$ I(capital)"
la var wxrd80 "Controlled $\times$ I(roads80)"
la var wxpopd "Controlled $\times$ I(popdens80)"

*-------------------------------------------------------------------------------
* 						Night Light outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes
gl nl "arcsine_nl13 ln_nl13 nl13_density wmean_nl1 z_wi mean_educ_years literacy_rate"
*Out: z_wi_iqr z_wi_iqr2 z_wi_iqr3 z_wi_p50 

*Erasing table before exporting
cap erase "${tables}\rdd_het_all_elev_p1.tex"
cap erase "${tables}\rdd_het_all_elev_p1.txt"
cap erase "${tables}\rdd_het_all_elev_p2.tex"
cap erase "${tables}\rdd_het_all_elev_p2.txt"
cap erase "${tables}\rdd_het_all_elev_p3.tex"
cap erase "${tables}\rdd_het_all_elev_p3.txt"
cap erase "${tables}\rdd_het_all_elev_p4.tex"
cap erase "${tables}\rdd_het_all_elev_p4.txt"
cap erase "${tables}\rdd_het_all_elev_p5.tex"
cap erase "${tables}\rdd_het_all_elev_p5.txt"
cap erase "${tables}\rdd_het_all_elev_p6.tex"
cap erase "${tables}\rdd_het_all_elev_p6.txt"
cap erase "${tables}\rdd_het_all_elev_p7.tex"
cap erase "${tables}\rdd_het_all_elev_p7.txt"
cap erase "${tables}\rdd_het_all_elev_p8.tex"
cap erase "${tables}\rdd_het_all_elev_p8.txt"
cap erase "${tables}\rdd_het_all_elev_p9.tex"
cap erase "${tables}\rdd_het_all_elev_p9.txt"
cap erase "${tables}\rdd_het_all_elev_p10.tex"
cap erase "${tables}\rdd_het_all_elev_p10.txt"

*Heterogeneous analysis results  
foreach var of global nl{
	
	*Table
	reghdfe `var' ${controls} i.within_control#c.dist_coast dist_coast [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)	
	outreg2 using "${tables}\rdd_het_all_elev_p1.tex", tex(frag) keep(within_control 1.within_control#c.dist_coast) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
		
	reghdfe `var' ${controls} wxdcst p50_dist_coast [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p2.tex", tex(frag) keep(within_control wxdcst) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} i.within_control#c.dist_city45 dist_city45 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p3.tex", tex(frag) keep(within_control 1.within_control#c.dist_city45) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
		
	reghdfe `var' ${controls} wxdcty p50_dist_city45 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p4.tex", tex(frag) keep(within_control wxdcty) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} i.within_control#c.dist_capital dist_capital [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p5.tex", tex(frag) keep(within_control 1.within_control#c.dist_capital) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} wxdcptl p50_dist_capital [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p6.tex", tex(frag) keep(within_control wxdcptl) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} i.within_control#c.dist_road80 dist_road80 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p7.tex", tex(frag) keep(within_control 1.within_control#c.dist_road80) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} wxrd80 p50_dist_road80 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p8.tex", tex(frag) keep(within_control wxrd80) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
		
	reghdfe `var' ${controls} i.within_control#c.dens_pop_bornbef80 dens_pop_bornbef80 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p9.tex", tex(frag) keep(within_control 1.within_control#c.dens_pop_bornbef80) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} wxpopd p50_pop_dens_80 [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	outreg2 using "${tables}\rdd_het_all_elev_p10.tex", tex(frag) keep(within_control wxpopd) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}




*END

