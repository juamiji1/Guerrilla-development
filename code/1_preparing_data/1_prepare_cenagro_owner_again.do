clear all 

*-------------------------------------------------------------------------------
import delimited "${data}\CensoAgropecuario\01 - Base de Datos MSSQL\FA2.csv", clear

*keeping only vars of interest 
keep portid fb1p06a fb1p06b s01p04
ren s01p04 same_place

tempfile ProdS
save `ProdS', replace

*Comercial Producers
import delimited "${data}\CensoAgropecuario\01 - Base de Datos MSSQL\FA1.csv", clear

*keeping only vars of interest 
keep portid fb1p06a fb1p06b s01p04 s01p05 s01p06
ren s01p04 same_place

tempfile ProdC
save `ProdC', replace


*Preparing census tracts IDs
import delimited "${data}\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

tempfile SegmID
save `SegmID', replace 

import delimited "${data}\CensoAgropecuario\01 - Base de Datos MSSQL\FA2S02.csv", clear

keep portid fb1p06a fb1p06b s02p01 s02p04 s02p05 s02p51
ren (s02p05 s02p51) (s02p06 s02p61)
ren s02p04 s02p05

gen subsistence=1 

merge m:1 portid fb1p06a fb1p06b using `ProdS', keep(1 3) nogen 

tempfile Plot2
save `Plot2', replace

import delimited "${data}\CensoAgropecuario\01 - Base de Datos MSSQL\FA1S02.csv", clear

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



end

 
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

twoway (kdensity sizep_all if subsistence==0) (kdensity sizep_all if subsistence==1)

tab owner_all subsistence, col row
tab rent_all subsistence, col row


