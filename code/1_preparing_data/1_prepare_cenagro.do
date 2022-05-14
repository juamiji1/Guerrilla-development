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

keep portid depid munid canid segid segm_id

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
replace size_comer=. if size_comer<`r(p5)' | size_comer>`r(p95)'
replace size_comer=size_comer*0.7

summ s02p01 if subsistence==0, d
count if s02p01>180 & subsistence==0  //.01004333 percentage

summ size_subs, d 
replace size_subs=. if size_subs<`r(p5)' | size_subs>`r(p95)'
replace size_subs=size_subs*0.7

gen size_all= size_comer if subsistence==0
replace size_all= size_subs if subsistence==1
replace size_all=size_all*0.7

*Total land for production 
gen sizet_comer=s02p05 if subsistence==0
gen sizet_subs=s02p05 if subsistence==1

summ sizet_comer, d 
replace sizet_comer=. if sizet_comer<`r(p5)' | sizet_comer>`r(p95)'
replace sizet_comer=sizet_comer*0.7

summ sizet_subs, d 
replace sizet_subs=. if sizet_subs<`r(p5)' | sizet_subs>`r(p95)'
replace sizet_subs=sizet_subs*0.7

gen sizet_all= sizet_comer if subsistence==0
replace sizet_all= sizet_subs if subsistence==1
replace sizet_all=sizet_all*0.7

*Cultivated land 
gen sizec_comer=s02p06 if subsistence==0
gen sizec_subs=s02p06 if subsistence==1

summ sizec_comer, d 
replace sizec_comer=. if sizec_comer<`r(p5)' | sizec_comer>`r(p95)'
replace sizec_comer=sizec_comer*0.7

summ sizec_subs, d 
replace sizec_subs=. if sizec_subs<`r(p5)' | sizec_subs>`r(p95)'
replace sizec_subs=sizec_subs*0.7

gen sizec_all= sizec_comer if subsistence==0
replace sizec_all= sizec_subs if subsistence==1
replace sizec_all=sizec_all*0.7

*Irrigated land
gen sizei_comer=s02p61 if subsistence==0
gen sizei_subs=s02p61 if subsistence==1

summ sizei_comer, d 
replace sizei_comer=. if sizei_comer<`r(p5)' | sizei_comer>`r(p95)'
replace sizei_comer=sizei_comer*0.7

summ sizei_subs, d 
replace sizei_subs=. if sizei_subs<`r(p5)' | sizei_subs>`r(p95)'
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
collapse s02p01 s02p05 s02p06 s02p61 subsistence size* shc* owned_comer owned_subs owned_all (sum) sum_size_all=size_all sum_size_comer=size_comer sum_size_subs=size_subs sum_size_all_sqr=size_all_sqr sum_size_comer_sqr=size_comer_sqr sum_size_subs_sqr=size_subs_sqr n_subs=subsistence n_comer n_all, by(segm_id)

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
*At the owner level
*-------------------------------------------------------------------------------
*Preparing census tracts IDs
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

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

*Size of plot 
gen size_comer=s02p01 if subsistence==0
gen size_subs=s02p01 if subsistence==1

summ size_comer, d 
replace size_comer=. if size_comer<`r(p5)' | size_comer>`r(p95)'
replace size_comer=size_comer*0.7

summ s02p01 if subsistence==0, d
count if s02p01>180 & subsistence==0  //.01004333 percentage

summ size_subs, d 
replace size_subs=. if size_subs<`r(p5)' | size_subs>`r(p95)'
replace size_subs=size_subs*0.7

gen size_all= size_comer if subsistence==0
replace size_all= size_subs if subsistence==1

replace size_comer=. if size_comer==0
replace size_subs=. if size_subs==0
replace size_all=. if size_all==0

*Total land for production 
gen sizet_comer=s02p05 if subsistence==0
gen sizet_subs=s02p05 if subsistence==1

summ sizet_comer, d 
replace sizet_comer=. if sizet_comer<`r(p5)' | sizet_comer>`r(p95)'
replace sizet_comer=sizet_comer*0.7

summ sizet_subs, d 
replace sizet_subs=. if sizet_subs<`r(p5)' | sizet_subs>`r(p95)'
replace sizet_subs=sizet_subs*0.7

gen sizet_all= sizet_comer if subsistence==0
replace sizet_all= sizet_subs if subsistence==1
replace sizet_all=sizet_all*0.7

*keep if same_place==1

*Size by producer
bys portid fb1p06a fb1p06b: egen size_prod_comer=total(size_comer)
bys portid fb1p06a fb1p06b: egen size_prod_subs=total(size_subs)
bys portid fb1p06a fb1p06b: egen size_prod_all=total(size_all)

bys portid fb1p06a fb1p06b: egen sizet_prod_comer=total(sizet_comer)
bys portid fb1p06a fb1p06b: egen sizet_prod_subs=total(sizet_subs)
bys portid fb1p06a fb1p06b: egen sizet_prod_all=total(sizet_all)

*Input for Simpson's Indexs
gen size_comer_sqr=size_comer^2
gen size_subs_sqr=size_subs^2
gen size_all_sqr=size_all^2

bys portid fb1p06a fb1p06b: egen size_prod_comer_sqr=total(size_comer_sqr)
bys portid fb1p06a fb1p06b: egen size_prod_subs_sqr=total(size_subs_sqr)
bys portid fb1p06a fb1p06b: egen size_prod_all_sqr=total(size_all_sqr)

*Calculating Gini Indexes
collapse (max) subsistence (mean) size_prod_comer size_prod_subs size_prod_all sizet_prod_comer sizet_prod_subs sizet_prod_all size_prod_comer_sqr size_prod_subs_sqr size_prod_all_sqr, by(segm_id portid fb1p06a fb1p06b)

*Owner 
gen sh_prod_own_all=size_prod_comer/sizet_prod_comer
gen sh_prod_own_comer=size_prod_subs/sizet_prod_subs
gen sh_prod_own_subs=size_prod_comer/sizet_prod_comer

gen owner_comer=(size_prod_comer>0) if size_prod_comer!=.
gen owner_subs=(size_prod_subs>0) if size_prod_subs!=.
gen owner_all=(size_prod_all>0) if size_prod_all!=.

gen owner_comer2=(sh_prod_own_comer>0.5) if sh_prod_own_comer!=.
gen owner_subs2=(sh_prod_own_subs>0.5) if sh_prod_own_subs!=.
gen owner_all2=(sh_prod_own_all>0.5) if sh_prod_own_all!=.

*Simpson's Index
gen si_comer=1-(size_prod_comer_sqr/(size_prod_comer)^2)
gen si_subs=1-(size_prod_subs_sqr/(size_prod_subs)^2)
gen si_all=1-(size_prod_all_sqr/(size_prod_all)^2)

gen x= (size_prod_all_sqr/(size_prod_all)^2)
gen x2= 1-x

*Labels
la var owner_comer "Owner"
la var owner_subs "Owner"
la var owner_all "Owner"

*Gini measures
gen gini_comer = .
gen iqr_comer = .
gen gini_subs = .
gen iqr_subs = .
gen gini_all = .
gen iqr_all = .

program mygini_comer
	qui ineqdeco size_prod_comer
	replace gini_comer = r(gini)
	replace iqr_comer = r(p75p25)
end

program mygini_subs
	qui ineqdeco size_prod_subs
	replace gini_subs = r(gini)
	replace iqr_subs = r(p75p25)
end

program mygini_all
	qui ineqdeco size_prod_all
	replace gini_all = r(gini)
	replace iqr_all = r(p75p25)
end

preserve
	gen n_prod_comer=1 if subsistence==0
	runby mygini_comer, by(segm_id) verbose		// Somehow deletes segments with error claculations. 

	*Collapsing at the segment level 
	collapse (sum) n_prod_comer (sd) sd_size_prod_comer=size_prod_comer (iqr) iqr_size_prod_comer=size_prod_comer (mean) size_prod_comer owner_comer gini_comer iqr_comer sh_prod_own_comer owner_comer2 si_comer, by(segm_id)

	tempfile GiniComer
	save `GiniComer', replace 
restore 

preserve
	gen n_prod_subs=1 if subsistence==1
	runby mygini_subs, by(segm_id) verbose
	
	*Collapsing at the segment level 
	collapse (sum) n_prod_subs (sd) sd_size_prod_subs=size_prod_subs (iqr) iqr_size_prod_subs=size_prod_subs (mean) size_prod_subs owner_subs gini_subs iqr_subs sh_prod_own_subs owner_subs2 si_subs, by(segm_id)

	tempfile GiniSubs
	save `GiniSubs', replace 
restore 
	
preserve
	gen n_prod_all=1
	runby mygini_all, by(segm_id) verbose
	
	*Collapsing at the segment level 
	collapse (sum) n_prod_all (sd) sd_size_prod_all=size_prod_all (iqr) iqr_size_prod_all=size_prod_all (mean) size_prod_all owner_all gini_all iqr_all sh_prod_own_all owner_all2 si_all, by(segm_id)

	tempfile GiniAll
	save `GiniAll', replace 
restore 


*-------------------------------------------------------------------------------
*RESULTS
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

drop _merge
merge 1:1 segm_id using `Plot', keep(1 3) nogen
merge 1:1 segm_id using `GiniComer', keep(1 3) nogen
merge 1:1 segm_id using `GiniSubs', keep(1 3) nogen
merge 1:1 segm_id using `GiniAll', keep(1 3) nogen

*Preparing vars
gen sh_prod_subs=n_prod_subs/n_prod_all
gen sh_prod_comer=n_prod_comer/n_prod_all

save "${data}/sample_try.dta", replace

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

*Globals for outcomes
gl all "size_all sizet_all sizec_all sh_prod_own_all owned_all "
gl comer "size_comer sizet_comer sizec_comer sh_prod_own_comer owned_comer"
gl subs "size_subs sizet_subs sizec_subs sh_prod_own_subs owned_subs"
gl gini_all "n_prod_all size_prod_all gini_all iqr_all owner_all owner_all2 "
gl gini_subs "n_prod_subs sh_prod_subs size_prod_subs gini_subs iqr_subs owner_subs owner_subs2 "
gl gini_comer "n_prod_comer sh_prod_comer size_prod_comer gini_comer iqr_comer owner_comer owner_comer2 "

gl more_all "sd_size_prod_all iqr_size_prod_all si_all"
gl more_subs "sd_size_prod_subs iqr_size_prod_subs si_subs"
gl more_comer "sd_size_prod_comer iqr_size_prod_comer si_comer"

gl si_index "si_all_segm si_comer_segm si_subs_segm"

*Erasing table before exporting
cap erase "${tables}\rdd_cenagrosize_all_p1.tex"
cap erase "${tables}\rdd_cenagrosize_all_p1.txt"
cap erase "${tables}\rdd_cenagrosize_all_p2.tex"
cap erase "${tables}\rdd_cenagrosize_all_p2.txt"
cap erase "${tables}\rdd_cenagrosize_all_p3.tex"
cap erase "${tables}\rdd_cenagrosize_all_p3.txt"

cap erase "${tables}\rdd_cenagrosize_all_p4.tex"
cap erase "${tables}\rdd_cenagrosize_all_p4.txt"
cap erase "${tables}\rdd_cenagrosize_all_p5.tex"
cap erase "${tables}\rdd_cenagrosize_all_p5.txt"
cap erase "${tables}\rdd_cenagrosize_all_p6.tex"
cap erase "${tables}\rdd_cenagrosize_all_p6.txt"

cap erase "${tables}\rdd_cenagrosize_all_p7.tex"
cap erase "${tables}\rdd_cenagrosize_all_p7.txt"
cap erase "${tables}\rdd_cenagrosize_all_p8.tex"
cap erase "${tables}\rdd_cenagrosize_all_p8.txt"
cap erase "${tables}\rdd_cenagrosize_all_p9.tex"
cap erase "${tables}\rdd_cenagrosize_all_p9.txt"

cap erase "${tables}\rdd_cenagrosize_all_p10.tex"
cap erase "${tables}\rdd_cenagrosize_all_p10.txt"

*Tables
foreach var of global all{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global comer{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global subs{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global gini_all{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p4.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global gini_subs{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p5.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global gini_comer{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p6.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global more_all{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p7.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global more_subs{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p8.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global more_comer{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p9.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global si_index{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrosize_all_p10.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}







*END


/*br portid depid munid canid s01p04 s01p04dep s01p04mun s01p04can diff_loc


*
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1S02.csv", clear

duplicates tag portid fb1p06a fb1p06b, g(dup)
tab dup 

sort portid fb1p06a fb1p06b depexp munexp

tempfile Size
save `Size', replace 	

*	
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1.csv", clear

merge m:1 portid using `SegmID', keep(1 3) nogen 

tab s01p04
destring depid munid canid, replace 
gen diff_loc=1 if (depid!=s01p04dep | munid!=s01p04mun | canid!=s01p04can) & s01p04==0
replace diff_loc=0 if diff_loc==.

tab diff_loc

keep portid fb1p06a fb1p06b segm_id s01p04 diff_loc

tempfile Main
save `Main', replace 





import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA1") firstrow clear 

export delimited using "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1.csv", replace

import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA1S02") firstrow clear 

export delimited using "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1S02.csv", replace

import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA2S02") firstrow clear 

export delimited using "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA2S02.csv", replace



