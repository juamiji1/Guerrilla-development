/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Ownership of land using the CENAGRO data 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 					  Preparing the CENAGRO data
*
*-------------------------------------------------------------------------------
import delimited "${data}/CensoAgropecuario/01 - Base de Datos MSSQL/FA2.csv", clear

*keeping only vars of interest 
keep portid fb1p06a fb1p06b s01p04
ren s01p04 same_place

tempfile ProdS
save `ProdS', replace

*Comercial Producers
import delimited "${data}/CensoAgropecuario/01 - Base de Datos MSSQL/FA1.csv", clear

*keeping only vars of interest 
keep portid fb1p06a fb1p06b s01p04 s01p05 s01p06
ren s01p04 same_place

tempfile ProdC
save `ProdC', replace

*Preparing census tracts IDs
import delimited "${data}/CensoAgropecuario/01 - Base de Datos MSSQL/FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

tempfile SegmID
save `SegmID', replace 

import delimited "${data}/CensoAgropecuario/01 - Base de Datos MSSQL/FA2S02.csv", clear

keep portid fb1p06a fb1p06b s02p01 s02p04 s02p05 s02p51
ren (s02p05 s02p51) (s02p06 s02p61)
ren s02p04 s02p05

gen subsistence=1 

merge m:1 portid fb1p06a fb1p06b using `ProdS', keep(1 3) nogen 

tempfile Plot2
save `Plot2', replace

import delimited "${data}/CensoAgropecuario/01 - Base de Datos MSSQL/FA1S02.csv", clear

keep portid fb1p06a fb1p06b s02p01 s02p05 s02p06 s02p61
gen subsistence=0 

merge m:1 portid fb1p06a fb1p06b using `ProdC', keep(1 3) nogen

append using `Plot2'
merge m:1 portid using `SegmID', keep(1 3)

*Size of owned land
gen sizep_all=s02p01 
replace sizep_all =sizep_all*0.7

gen sizep_comer=sizep_all if subsistence==0
gen sizep_subs=sizep_all if subsistence==1

*Size of total land
gen sizet_all=s02p05
replace sizet_all =sizet_all*0.7

gen sizet_comer=sizet_all if subsistence==0
gen sizet_subs=sizet_all if subsistence==1

*Size of non-owned land
gen sizenp_all=sizet_all-sizep_all
replace sizenp_all =sizenp_all*0.7

gen sizenp_comer=sizenp_all if subsistence==0
gen sizenp_subs=sizenp_all if subsistence==1

*Creating owner variable 
gen owner_all=(sizep_all>0) if sizep_all!=.
gen owner_comer=owner_all if subsistence==0
gen owner_subs=owner_all if subsistence==1

*Creating renting variable 
gen rent_all=(sizenp_all>0) if sizenp_all!=.
gen rent_comer=rent_all if subsistence==0
gen rent_subs=rent_all if subsistence==1

*replacing zeros 
recode sizep_all sizenp_all sizep_comer sizep_subs sizenp_comer sizenp_subs (0=.)
 
summ sizep_all, d
summ sizep_all if subsistence==0, d
summ sizep_all if subsistence==0 & s01p05==34, d
summ sizep_all if subsistence==1, d 

tabstat sizep_all if subsistence==0, by(s01p06) s(N mean sd min p50 max)

*Dropping non-persons 
drop if subsistence==0 & s01p06!=9939

summ sizep_all, d
summ sizep_all if subsistence==0, d
summ sizep_all if subsistence==1, d 


tab owner_all subsistence, col row
tab rent_all subsistence, col row

*Collapsing at the segment level 
collapse (mean) sizep_all sizenp_all sizep_comer sizep_subs sizenp_comer sizenp_subs sizet_all sizet_comer sizet_subs owner_* rent_* (sum) tot_sizep_all=sizep_all tot_sizenp_all=sizenp_all tot_sizep_comer=sizep_comer tot_sizep_subs=sizep_subs tot_sizenp_comer=sizenp_comer tot_sizenp_subs=sizenp_subs tot_sizet_all=sizet_all tot_sizet_comer=sizet_comer tot_sizet_subs=sizet_subs tot_owner_all=owner_all tot_owner_comer=owner_comer tot_owner_subs=owner_subs  tot_rent_all=rent_all tot_rent_comer=rent_comer tot_rent_subs=rent_subs, by(segm_id)

*Creating shares 
gen sh_landp_all=tot_sizep_all/tot_sizet_all
gen sh_landp_comer=tot_sizep_comer/tot_sizet_comer
gen sh_landp_subs=tot_sizep_subs/tot_sizet_subs
gen sh_land_comer=tot_sizep_comer/tot_sizet_all
gen sh_land_subs=tot_sizep_subs/tot_sizet_all

*More descriptives
summ sizep_comer sizep_subs, d
summ tot_sizep_comer tot_sizep_subs, d 


tempfile Plot 
save `Plot', replace 


*-------------------------------------------------------------------------------
* RDD results
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

drop _merge
merge 1:1 segm_id using `Plot', keep(1 3) nogen

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

gl outcomes "owner_all sizet_all"


*Erasing table before exporting
local r replace
*Tables
foreach var of global outcomes{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/rdd_landownership.tex", tex(frag) keep(within_control)  addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r' nor2
	
	local r append
}

preserve 
  insheet using "${tables}/rdd_landownership.txt", nonames clear
  
drop v2 

drop in 2
insobs 1, before(1)
replace v3 = "Land Ownership Rate" in 1
replace v4 = "Size of Owned Land (Ha)" in 1
replace v1 = "Guerrilla control" in 4

dataout, tex save("${tables}/rdd_landownership") replace nohead midborder(3)
restore 
  

*END
