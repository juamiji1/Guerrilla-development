
*-------------------------------------------------------------------------------
* Creating sample data and munic within control data 
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

gen sample_rd=1 if abs(z_run_cntrl)<=${h}
replace sample_rd=0 if sample_rd==.

preserve
	keep if sample_rd==1 
	keep segm_id within_control z_run_cntrl sample_rd
	
	tempfile RDSAMPLE
	save `RDSAMPLE', replace 
restore

*Looking at municipalities 
gen munic=COD_D+COD_M

collapse mean_samplerd=sample_rd mean_within_control=within_control, by(munic)
keep if mean_samplerd>0

summ mean_within_control, d
gen seg_muni_within_cntrl_v1=(mean_within_control>=`r(mean)')
gen seg_muni_within_cntrl_v2=(mean_within_control>=.5)

keep munic seg_muni_within_cntrl_v*

tempfile WMUNIC
save `WMUNIC', replace 


*-------------------------------------------------------------------------------
* Calculating rates if in and out migration at different momments of time
*
*-------------------------------------------------------------------------------
*Using the population census 
use "${data}/censo2007\data\poblacion.dta", clear 

*Creating the identifiers 
gen segm_id=DEPID+MUNID+SEGID

replace S06P08B2="" if S06P08B2=="-2"
replace S06P08B3="" if S06P08B3=="-2"

gen munic=S06P08B3+S06P08B2

*Merging the rd sample
merge m:1 segm_id using `RDSAMPLE', keep(1 3) nogen 
merge m:1 munic using `WMUNIC', keep(1 3) nogen

*-------------------------------------------------------------------------------
*Calculating how many people arrived from guerrilla controlled areas 
*-------------------------------------------------------------------------------
tab seg_muni_within_cntrl_v1 if sample_rd==1 & within_control==0
tab seg_muni_within_cntrl_v2 if sample_rd==1 & within_control==0

gen x1= seg_muni_within_cntrl_v1 if sample_rd==1 & within_control==0
gen x2= seg_muni_within_cntrl_v2 if sample_rd==1 & within_control==0

gen n=1
bys segm_id: egen sum_n=total(n), missing
bys segm_id: egen sum_x1=total(x1), missing
bys segm_id: egen sum_x2=total(x2), missing

*Creating the share of in-migrants 
gen x1_n=sum_x1/sum_n
gen x2_n=sum_x2/sum_n

*For migration in 1980
gen x1_80= seg_muni_within_cntrl_v1 if S06P08A2>=1976 & S06P08A2<1981 & sample_rd==1 & within_control==0
gen x2_80= seg_muni_within_cntrl_v2 if S06P08A2>=1976 & S06P08A2<1981 & sample_rd==1 & within_control==0

bys segm_id: egen sum_x1_80=total(x1_80), missing
bys segm_id: egen sum_x2_80=total(x2_80), missing

gen x1_80_n=sum_x1_80/sum_n
gen x2_80_n=sum_x2_80/sum_n

*For migration in 1985
gen x1_85= seg_muni_within_cntrl_v1 if S06P08A2>=1980 & S06P08A2<1986 & sample_rd==1 & within_control==0
gen x2_85= seg_muni_within_cntrl_v2 if S06P08A2>=1980 & S06P08A2<1986 & sample_rd==1 & within_control==0

bys segm_id: egen sum_x1_85=total(x1_85), missing
bys segm_id: egen sum_x2_85=total(x2_85), missing

gen x1_85_n=sum_x1_85/sum_n
gen x2_85_n=sum_x2_85/sum_n

*-------------------------------------------------------------------------------
*Calculating how many people left from control to guerrilla areas 
*-------------------------------------------------------------------------------
tab seg_muni_within_cntrl_v1 if sample_rd==1 & within_control==1
tab seg_muni_within_cntrl_v2 if sample_rd==1 & within_control==1

gen y1=(seg_muni_within_cntrl_v1==0) if seg_muni_within_cntrl_v1!=. & sample_rd==1 & within_control==1
gen y2=(seg_muni_within_cntrl_v2==0) if seg_muni_within_cntrl_v2!=. & sample_rd==1 & within_control==1

bys segm_id: egen sum_y1=total(y1), missing
bys segm_id: egen sum_y2=total(y2), missing

*Creating the share of out-migrants 
gen y1_n=sum_y1/sum_n
gen y2_n=sum_y2/sum_n

*For migration in 1980
gen y1_80=(seg_muni_within_cntrl_v1==0) if seg_muni_within_cntrl_v1!=. & (S06P08A2>=1976 & S06P08A2<1981) & sample_rd==1 & within_control==1
gen y2_80=(seg_muni_within_cntrl_v2==0) if seg_muni_within_cntrl_v2!=. & (S06P08A2>=1976 & S06P08A2<1981) & sample_rd==1 & within_control==1

bys segm_id: egen sum_y1_80=total(y1_80), missing
bys segm_id: egen sum_y2_80=total(y2_80), missing

*Creating the share of in-migrants 
gen y1_80_n=sum_y1_80/sum_n
gen y2_80_n=sum_y2_80/sum_n

*For migration in 1985
gen y1_85=(seg_muni_within_cntrl_v1==0) if seg_muni_within_cntrl_v1!=. & (S06P08A2>=1980 & S06P08A2<1986) & sample_rd==1 & within_control==1
gen y2_85=(seg_muni_within_cntrl_v2==0) if seg_muni_within_cntrl_v2!=. & (S06P08A2>=1980 & S06P08A2<1986) & sample_rd==1 & within_control==1

bys segm_id: egen sum_y1_85=total(y1_85), missing
bys segm_id: egen sum_y2_85=total(y2_85), missing

*Creating the share of in-migrants 
gen y1_85_n=sum_y1_85/sum_n
gen y2_85_n=sum_y2_85/sum_n

*In-migration percentages
summ x2_n x2_80_n x2_85_n 

*Out-migration percentages
summ y2_n y2_80_n y2_85_n 


*-------------------------------------------------------------------------------
* Calculating the trimmed years of education 
*
*-------------------------------------------------------------------------------
replace S06P11A=. if S06P03A<18

*Trimming for all time migration 
gen edyc=S06P11A if sample_rd==1 & within_control==0
gen edyt=S06P11A if sample_rd==1 & within_control==1

summ x2_n
winsor edyc if sample_rd==1 & within_control==0, p(`r(mean)') gen(edyc_trmm) high
summ y2_n
winsor edyt if sample_rd==1 & within_control==1, p(`r(mean)') gen(edyt_trmm) low

gen educ_years_trimmed=edyc_trmm if sample_rd==1 & within_control==0
replace educ_years_trimmed=edyt_trmm if sample_rd==1 & within_control==1

drop edy*

*Trimming for all 1980 migration 
gen edyc=S06P11A if sample_rd==1 & within_control==0
gen edyt=S06P11A if sample_rd==1 & within_control==1

summ x2_80_n
winsor edyc if sample_rd==1 & within_control==0, p(`r(mean)') gen(edyc_trmm) high
summ y2_80_n
winsor edyt if sample_rd==1 & within_control==1, p(`r(mean)') gen(edyt_trmm) low

gen educ_years_trimmed80=edyc_trmm if sample_rd==1 & within_control==0
replace educ_years_trimmed80=edyt_trmm if sample_rd==1 & within_control==1

drop edy*

*Trimming for all 1985 migration 
gen edyc=S06P11A if sample_rd==1 & within_control==0
gen edyt=S06P11A if sample_rd==1 & within_control==1

summ x2_85_n
winsor edyc if sample_rd==1 & within_control==0, p(`r(mean)') gen(edyc_trmm) high
summ y2_85_n
winsor edyt if sample_rd==1 & within_control==1, p(`r(mean)') gen(edyt_trmm) low

gen educ_years_trimmed85=edyc_trmm if sample_rd==1 & within_control==0
replace educ_years_trimmed85=edyt_trmm if sample_rd==1 & within_control==1

drop edy*

*Collapsing at the segment level 
collapse (mean) educ_years_trimmed* sample_rd, by(segm_id)

tempfile TRIMM 
save `TRIMM', replace 


*-------------------------------------------------------------------------------
* Results with the trimmed data
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

*Merging the data 
merge 1:1 segm_id using `TRIMM', keep(1 3) nogen 

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

*Global of outcomes
gl educ "educ_years_trimmed educ_years_trimmed80 educ_years_trimmed85"

*Erasing table before exporting
cap erase "${tables}\rdd_educ_trimm_all.tex"
cap erase "${tables}\rdd_educ_trimm_all.txt"

*Results
foreach var of global educ{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_educ_trimm_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}









*END 