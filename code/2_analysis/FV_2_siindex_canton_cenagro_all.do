clear all 

*-------------------------------------------------------------------------------
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA2.csv", clear

*keeping only vars of interest 
keep portid fb1p06a fb1p06b s01p04
ren s01p04 same_place

tempfile ProdS
save `ProdS', replace

*Comercial Producers
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1.csv", clear

*keeping only vars of interest 
keep portid fb1p06a fb1p06b s01p04
ren s01p04 same_place

tempfile ProdC
save `ProdC', replace


*Preparing census tracts IDs
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid
gen canton_id=depid+munid+canid

keep portid depid munid canid segid segm_id canton_id

tempfile SegmID
save `SegmID', replace 

import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA2S02.csv", clear

keep portid fb1p06a fb1p06b s02p01 s02p04 s02p05 s02p51
ren (s02p05 s02p51) (s02p06 s02p61)
ren s02p04 s02p05

gen subsistence=1 

merge m:1 portid fb1p06a fb1p06b using `ProdS', keep(1 3) nogen 

tempfile Plot2
save `Plot2', replace

import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1S02.csv", clear

keep portid fb1p06a fb1p06b s02p01 s02p05 s02p06 s02p61
gen subsistence=0 

merge m:1 portid fb1p06a fb1p06b using `ProdC', keep(1 3) nogen

append using `Plot2'
merge m:1 portid using `SegmID', keep(1 3)

*Descriptives
summ s02p01 s02p05 s02p06 s02p61, d
summ s02p01 s02p05 s02p06 s02p61 if subsistence==1, d
summ s02p01 s02p05 s02p06 s02p61 if subsistence==0, d

*Size of plot 
gen size_comer=s02p01 if subsistence==0
gen size_subs=s02p01 if subsistence==1

summ size_comer, d 
*replace size_comer=. if size_comer<`r(p5)' | size_comer>`r(p95)'
replace size_comer=size_comer*0.7

summ s02p01 if subsistence==0, d
count if s02p01>180 & subsistence==0  //.01004333 percentage

summ size_subs, d 
*replace size_subs=. if size_subs<`r(p5)' | size_subs>`r(p95)'
replace size_subs=size_subs*0.7

gen size_all= size_comer if subsistence==0
replace size_all= size_subs if subsistence==1
replace size_all=size_all*0.7

*Total land for production 
gen sizet_comer=s02p05 if subsistence==0
gen sizet_subs=s02p05 if subsistence==1

summ sizet_comer, d 
*replace sizet_comer=. if sizet_comer<`r(p5)' | sizet_comer>`r(p95)'
replace sizet_comer=sizet_comer*0.7

summ sizet_subs, d 
*replace sizet_subs=. if sizet_subs<`r(p5)' | sizet_subs>`r(p95)'
replace sizet_subs=sizet_subs*0.7

gen sizet_all= sizet_comer if subsistence==0
replace sizet_all= sizet_subs if subsistence==1
replace sizet_all=sizet_all*0.7

*Cultivated land 
gen sizec_comer=s02p06 if subsistence==0
gen sizec_subs=s02p06 if subsistence==1

summ sizec_comer, d 
*replace sizec_comer=. if sizec_comer<`r(p5)' | sizec_comer>`r(p95)'
replace sizec_comer=sizec_comer*0.7

summ sizec_subs, d 
*replace sizec_subs=. if sizec_subs<`r(p5)' | sizec_subs>`r(p95)'
replace sizec_subs=sizec_subs*0.7

gen sizec_all= sizec_comer if subsistence==0
replace sizec_all= sizec_subs if subsistence==1
replace sizec_all=sizec_all*0.7

*Irrigated land
gen sizei_comer=s02p61 if subsistence==0
gen sizei_subs=s02p61 if subsistence==1

summ sizei_comer, d 
*replace sizei_comer=. if sizei_comer<`r(p5)' | sizei_comer>`r(p95)'
replace sizei_comer=sizei_comer*0.7

summ sizei_subs, d 
*replace sizei_subs=. if sizei_subs<`r(p5)' | sizei_subs>`r(p95)'
replace sizei_subs=sizei_subs*0.7

gen sizei_all= sizei_comer if subsistence==0
replace sizei_all= sizei_subs if subsistence==1
replace sizei_all=sizei_all*0.7

*Share of cultivated land 
gen shc_comer=sizec_comer/size_comer
gen shc_subs=sizec_subs/size_subs
gen shc_all=sizec_all/size_all

*Total of plots
gen n_comer=1 if subsistence==0
gen n_all=1

*Owned plots
gen owned_comer=(size_comer>0) if size_comer!=.
gen owned_subs=(size_subs>0) if size_subs!=.
gen owned_all=(size_all>0) if size_all!=.

*Input for Simpson's Indexs
gen size_comer_sqr=size_comer^2
gen size_subs_sqr=size_subs^2
gen size_all_sqr=size_all^2

*keep if same_place==1

*Collapsing at the segment level
collapse s02p01 s02p05 s02p06 s02p61 subsistence size* shc* owned_comer owned_subs owned_all (sum) sum_size_all=size_all sum_size_comer=size_comer sum_size_subs=size_subs sum_size_all_sqr=size_all_sqr sum_size_comer_sqr=size_comer_sqr sum_size_subs_sqr=size_subs_sqr n_subs=subsistence n_comer n_all, by(canton_id)

destring canton_id, replace

gen si_all_segm= 1- (sum_size_all_sqr/(sum_size_all)^2)
gen si_comer_segm= 1- (sum_size_comer_sqr/(sum_size_comer)^2)
gen si_subs_segm= 1- (sum_size_subs_sqr/(sum_size_subs)^2)

la var size_all "Owned Area"
la var sizet_all "Total Area"
la var sizec_all "Grown Area"
la var shc_all "Grown Share"
la var owned_all "Owned plot"

la var size_comer "Owned Area"
la var sizet_comer "Total Area"
la var sizec_comer "Grown Area"
la var shc_comer "Grown Share"
la var owned_comer "Owned plot"

la var size_subs "Owned Area"
la var sizet_subs "Total Area"
la var sizec_subs "Grown Area"
la var shc_subs "Grown Share"
la var owned_subs "Owned plot"

tempfile Plot
save `Plot', replace 

*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
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

*Merging cenagro data
merge 1:1 canton_id using `Plot', keep(1 3) nogen

end
*-------------------------------------------------------------------------------
* 								Results
*-------------------------------------------------------------------------------
*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust si_all_segm z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Globals
gl si_index "si_all_segm si_comer_segm si_subs_segm"

*Erasing table before exporting
cap erase "${tables}\rdd_cenagrosize_canton_all.tex"
cap erase "${tables}\rdd_cenagrosize_canton_all.txt"

*Tables
foreach var of global si_index{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_canton_all.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

