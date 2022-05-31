/*-----------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating NL outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
use "${data}/sample_try.dta", clear

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

*Sample indicator
reghdfe arcsine_nl13 ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
gen sample_reg=e(sample)

keep if sample_reg==1 & region==3

preserve
	keep sample_reg within_control region segm_id
	tempfile SAMPLE 
	save `SAMPLE', replace 
restore 

*Rename
ren (COD_D COD_M COD_C) (codepto codmuni codcanton)

preserve
	keep segm_id codepto codmuni codcanton depto_name muni_name canton_name within_control region total_household_survey 
	replace total_household_survey =0 if total_household_survey ==.
	export delimited using "${data}\info_consulting_sample_hh.csv", replace
restore

*Means
tabstat arcsine_nl13 if total_household_survey!=., by(within_control) s(N mean sd) 
tabstat z_index_trst if total_household_survey!=., by(within_control) s(N mean sd) 
tabstat n_trst if total_household_survey!=., by(within_control) s(sum) 
tabstat size_comer if total_household_survey!=., by(within_control) s(N mean sd) 
tabstat n_comer if total_household_survey!=. & n_comer>0, by(within_control) s(sum) 



*-------------------------------------------------------------------------------
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

*Merging regression sample 
merge m:1 segm_id using `SAMPLE', nogen keep(3)
unique segm_id

*ICC estimates 
loneway size_comer segm_id if sample_reg==1
loneway size_comer segm_id if within_control==0
loneway size_comer segm_id if within_control==1
















*-------------------------------------------------------------------------------
* 					     	Acommodation and Household conditions 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007\data\poblacion.dta", clear 

*Keeping head of household only 
keep if S06P01==1

*Has always lived in the same place 
tab S06P08A1 
recode S06P08A1 (2 3=0), gen(always)  

keep DEPID MUNID SEGID VIVID HOGID always S06P03A

tempfile pop
save `pop', replace 

use "${data}/censo2007\data\vivienda.dta", clear 

*Merging household conditions 
merge 1:m DEPID MUNID SEGID VIVID using "${data}/censo2007\data\hogar.dta", keep(2 3) nogen
merge 1:1 DEPID MUNID SEGID VIVID HOGID using `pop', keep(2 3) nogen

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID

*Wall materials
gen good_wall=(S02P02==1)
gen bad_wall=(S02P02==6 | S02P02==7)

recode S02P02 (4 6 = 2)
tab S02P02, g(wall_)
recode S02P02 (8=.) (2 3 5 6 7 = 0), gen(good_wall2)

*Roof materials
*gen good_roof=(S02P03==1 | S02P03==2)
gen good_roof=(S02P03==1)
gen bad_roof=(S02P02==6 | S02P02==7 )

recode S02P03 (8=.) (2 3 4= 1) (5 6 7 = 0), gen(good_roof2)
tab S02P03, g(roof_)
*recode S02P03 (2 3 4 5 = 1) (6 7 8 = 0), gen(good_roof)

*Floor materials 
recode S02P05 (-2 = .)
*gen good_floor=(S02P03==1 | S02P03==2)
gen good_floor=(S02P03==1)
gen bad_floor=(S02P02==5 | S02P02==6)

recode S02P05 (6 = 5)
tab S02P05, g(floor_)
recode S02P05 (7=.) (2 3 4 = 1) (4 5 = 0), gen(good_floor2)

*Nuumber of households
recode S02P08 (-2 = .)
tab S02P08

*Total of people within the household 
ren POBTOT pobtot

*Sleeping rooms
tab S03P02
recode S03P02 (0=1)

*Members per sleeping room
gen m_p_room =pobtot/S03P02

*Home ownership 
recode S03P04 (2 3 4 = 1) (5 6 7 = 0)

*Sanitary type 
recode S03P05 (2 = 1) (4 = 3)
tab S03P05, g(sanitary_)

*Exclusive sanitary service 
recode S03P06 (-2 = .) (2 = 0) 

*Dirty water disposal 
tab S03P07, g(dirty_water_)

*Type of water access 
recode S03P08 (2 3 = 1) (6 = 5) (9 = 8)
tab S03P08, g(water_type_)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Cook fuel 
gen electric_cook=(S03P10==1)
recode S03P10 (4 5 6 7 = 8)
tab S03P10, g(fuel_cook_)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Garbage disposal 
recode S03P12 (2 = 1) (3 4 5 6 7 8 = 0)

*Assets characteristics 
recode S03P13A - S03P13M  (-1 -2 = .) (2=0)
gen car_bike= (S03P13J==1 | S03P13K==1)

*Farming or livestock  activity 
recode S03P15A S03P15B (-1 -2 = .) (2=0)

*Land of activity 
recode S03P16 (2 3 = 0)

*Urban area 
ren AREAID urban 
recode urban (2 = 0)

*Total households
gen total_household=1
gen total_household_survey=1 if S06P03A>29 & S06P03A<71

*Sanitary service 
recode S03P05 (2 3 4 5 = 0)

*Sewerage service 
recode S03P07 (2 3 4 5 6 =0)

*Water pipes 
recode S03P08 (2 3 = 1) (4 5 6 7 8 9 10 = 0)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Creating the wealth index 
gl wealthindex "wall_* roof_* floor_* pobtot m_p_room S03P04 sanitary_* S03P06 dirty_water_* water_type_* fuel_cook_* S03P11 S03P12 S03P13A - S03P13M S03P15A S03P15B S03P16 urban"
factor ${wealthindex}, pcf factors(1)
predict z_wi

merge m:1 segm_id using `SAMPLE', keep(3)

*ICC estimates 
loneway z_wi segm_id if sample_reg==1
loneway z_wi segm_id if within_control==0
loneway z_wi segm_id if within_control==1







