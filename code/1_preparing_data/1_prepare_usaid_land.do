*RONDA 1:
use "${data}/usaid\original\PUD-R1\community\v13-Secc_I1_mayo.dta", clear

drop if P003==.

tostring P001 P002 P003, replace
replace P001 = "0"+P001 if length(P001)==1
replace P002 = "0"+P002 if length(P002)==1
replace P003 = "0"+P003 if length(P003)==1

gen codcanton = P001 + P002 + P003

duplicates drop Lote codcanton, force
duplicates drop Lote, force

isid Lote

ren _all, low
ren (p001 p002 p003) (cod_dep cod_mun cod_can)

keep lote cod_dep cod_mun cod_can codcanton

tempfile R1CantonID
save `R1CantonID', replace 

*Q2 Module 
use "${data}/usaid\original\PUD-R1\household\hombre\v13-secc_q2_mayo.dta", clear 
keep if p001==1
keep if p0022==1.01 | p0022==1.02 | p0022==1.03 | p0022==1.04
gen int id=(p0022-1)*100

*Plot ID
replace p0031=p0032 if p0031==.
replace p0031=p0033 if p0031==. 
ren p0031 cdp

keep if cdp!=.

*Converting units 
replace p0041=p0041*2 if p0042==1
replace p0041=p0041/100 if p0042==3
replace p0041=p0041*22.399 if p0042==5
replace p0041=p0041/45.36 if p0042==6
replace p0041=p0041/4 if p0042==8

replace p0041=. if p0042==9 | p0042==12 | p0042==.   		//	<------CHECK!!!!
*replace p0041=p0041*2 if p0042==8

replace p0051=p0051*2 if p0052==1
replace p0051=p0051/100 if p0052==3
replace p0051=p0051*22.399 if p0052==5
replace p0051=p0051/4 if p0052==8
replace p0051=. if p0052==.

replace p0071=p0071*2 if p0072==1
replace p0071=p0071/100 if p0072==3
replace p0071=p0071/75.36 if p0072==6
replace p0071=p0071/7 if p0072==8
replace p0071=. if p0072==.

bys lote folio cdp id: egen prod=total(p0041) 
bys lote folio cdp id: egen sell=total(p0051) 
bys lote folio cdp id: egen consump=total(p0071) 

keep lote folio cdp id prod sell consump 

gen sell_sh=sell/prod
gen consump_sh=consump/prod

duplicates drop lote folio cdp id, force

reshape wide prod sell sell_sh consump consump_sh, i(lote folio cdp) j(id) 

tempfile R1Prod
save `R1Prod', replace 

*AP Module
use "${data}/usaid\original\PUD-R1\household\hombre\v13-secc_ap1_mayo.dta", clear

*Only agricultural producers
keep if p001==1			

*Converting from manzanas to has 
replace p002=p002*0.698896
ren p002 land_size

*Type of raltion with land 
tab p006, nol
gen prop=(p006==1)
gen arr=(p006==2)
gen coop=(p006==4)
gen oth=(p006==3 | p006==5 | p006==6 | p006==9)

keep lote folio cdp land_size prop arr coop oth

*Merging production 
merge 1:1 lote folio cdp using `R1Prod', keep(1 3) nogen 
merge m:1 lote using `R1CantonID', keep(1 3)

*Gen yield for each crop 
forval c=1/4{
	replace prod`c'=prod`c'/22.399 					//		<---- To tons. 
	gen yield`c'=prod`c'/land_size
}

gen ronda=1

tempfile R1Land
save `R1Land', replace


*-------------------------------------------------------------------------------
*RONDA 2:
use "${data}/usaid\original\PUD-R2\community\v13-secc_a1_mayo.dta", clear

drop if P003_1==.

tostring P001_1 P002_1 P003_1, replace
replace P001_1 = "0"+P001_1 if length(P001_1)==1
replace P002_1 = "0"+P002_1 if length(P002_1)==1
replace P003_1 = "0"+P003_1 if length(P003_1)==1

gen codcanton = P001_1 + P002_1 + P003_1

duplicates drop Lote codcanton, force
duplicates drop Lote, force

isid Lote

ren _all, low
ren (p001_1 p002_1 p003_1) (cod_dep cod_mun cod_can)

keep lote cod_dep cod_mun cod_can codcanton

tempfile R2CantonID
save `R2CantonID', replace 

*HHID Module
use "${data}/usaid\original\PUD-R2\household\v13-geograficos.dta", clear

ren _all, low
merge m:1 lote using `R2CantonID', keep(3)

keep hhid cod_dep cod_mun cod_can codcanton

tempfile R2Hhid
save `R2Hhid', replace 

*Q2 Module 
use "${data}/usaid\original\PUD-R2\household\v13-tblsectionagriq2pg1.dta", clear 
ren _all, low

keep if corpcode1=="Maiz" | corpcode1=="Frijol" | corpcode1=="Ca±a de az·car" | corpcode1=="CafÚ"
gen int id=1 if corpcode1=="Maiz"
replace id=2 if corpcode1=="Frijol"
replace id=3 if corpcode1=="Ca±a de az·car"
replace id=4 if corpcode1=="CafÚ"

*Plot ID
destring q3_2 q3_3, replace
replace q3=q3_2 if q3==.
replace q3=q3_3 if q3==. 
ren q3 plotcode

keep if plotcode!=.

*Converting units 
replace q4=q4*2 if q4_1=="A"
replace q4=q4/100 if q4_1=="C"
replace q4=q4*22.399 if q4_1=="F"
*replace q4=q4/45.36 if q4_1=="H"
replace q4=q4/4 if q4_1=="I"

replace q4=. if q4_1=="H" | q4_1==""		//	<------CHECK!!!!
*replace p0041=p0041*2 if p0042==8

replace q5=q5*2 if q5_1=="A"
replace q5=q5/100 if q5_1=="C"
replace q5=. if q5_1==""

replace q7=q7*2 if q7_1=="A"
replace q7=q7/100 if q7_1=="C"
replace q7=q7/4 if q7_1=="I"
replace q7=. if q7_1==""

bys hhid plotcode id: egen prod=total(q4) 
bys hhid plotcode id: egen sell=total(q5) 
bys hhid plotcode id: egen consump=total(q7) 

keep hhid plotcode id prod sell consump 

gen sell_sh=sell/prod
gen consump_sh=consump/prod

duplicates drop hhid plotcode id, force

reshape wide prod sell sell_sh consump consump_sh, i(hhid plotcode) j(id) 

tempfile R2Prod
save `R2Prod', replace 

*AP Module
use "${data}/usaid\original\PUD-R2\household\v13-tblsectionplots_ap.dta", clear

ren _all, low

*Converting from manzanas to has 
replace q2=q2*0.698896
ren q2 land_size

*Type of relation with land 
tab q6, nol
gen prop=(q6==1)
gen arr=(q6==2)
gen coop=(q6==4)
gen oth=(q6==3 | q6==5 | q6==6 | q6==9)

keep hhid plotcode land_size prop arr coop oth
duplicates drop hhid plotcode, force

*Merging production 
merge 1:1 hhid plotcode using `R2Prod', keep(1 3) nogen 
merge m:1 hhid using `R2Hhid', keep(1 3)

*Gen yield for each crop 
forval c=1/4{
	replace prod`c'=prod`c'/22.399 					//		<---- To tons. 
	gen yield`c'=prod`c'/land_size
}

gen ronda=2

tempfile R2Land
save `R2Land', replace


*---------------------------------------------------------------------------------
*RONDA 3:
use "${data}/usaid\original\PUD-R3\community\v13-seccion_a.dta", clear

drop if P003_A==.

tostring P001_A P002_A P003_A, replace
replace P001_A = "0"+P001_A if length(P001_A)==1
replace P002_A = "0"+P002_A if length(P002_A)==1
replace P003_A = "0"+P003_A if length(P003_A)==1

gen codcanton = P001_A + P002_A + P003_A

duplicates drop lote codcanton, force
duplicates drop lote, force

isid lote

ren _all, low
ren (p001_a p002_a p003_a segmento) (cod_dep cod_mun cod_can segmentoc)

keep lote cod_dep cod_mun cod_can codcanton 

tempfile R3CantonID
save `R3CantonID', replace 

*Q2 Module 
use "${data}/usaid\original\PUD-R3\household\v13-q2.dta", clear 
ren _all, low

keep if q1_q2==1
keep if q2_1_q2==1.01 | q2_1_q2==1.02 | q2_1_q2==1.03 | q2_1_q2==1.04
gen int id=(q2_1_q2-1)*100

*Plot ID
recode q3_2_q2 q3_3_q2 (98 = .)
replace q3_1_q2=q3_2_q2 if q3_1_q2==.
replace q3_1_q2=q3_3_q2 if q3_1_q2==. 
ren q3_1_q2 plotcode_ap1

keep if plotcode_ap1!=.

*Converting units 
replace q4_q2=q4_q2*2 if q4_1_q2==1
replace q4_q2=q4_q2/100 if q4_1_q2==3
replace q4_q2=q4_q2*22.046 if q4_1_q2==5
replace q4_q2=q4_q2*22.399 if q4_1_q2==6
replace q4_q2=q4_q2/4 if q4_1_q2==9
replace q4_q2=. if q4_1_q2==116	| q4_q2==9999 | q4_q2==777777					//	<------CHECK!!!!

replace q5_q2=q5_q2*2 if q5_1_q2==1
replace q5_q2=q5_q2/100 if q5_1_q2==3
replace q5_q2=q5_q2*22.046 if q5_1_q2==5
replace q5_q2=q5_q2/4 if q5_1_q2==9
replace q5_q2=. if q5_1_q2==116

replace q7_q2=q7_q2*2 if q7_1_q2==1
replace q7_q2=q7_q2/100 if q7_1_q2==3
replace q7_q2=q7_q2/4 if q7_1_q2==9
replace q7_q2=. if q7_1_q2==116

bys lote hhid plotcode_ap1 id: egen prod=total(q4_q2) 
bys lote hhid plotcode_ap1 id: egen sell=total(q5_q2) 
bys lote hhid plotcode_ap1 id: egen consump=total(q7_q2) 

keep lote hhid plotcode_ap1 id prod sell consump 

gen sell_sh=sell/prod
gen consump_sh=consump/prod

duplicates drop lote hhid plotcode id, force

reshape wide prod sell sell_sh consump consump_sh, i(lote hhid plotcode) j(id) 

tempfile R3Prod
save `R3Prod', replace 

*AP Module
use "${data}/usaid\original\PUD-R3\household\v13-ap1.dta", clear

ren _all, low

*Only agricultural producers
keep if q1_ap1==1			

*Converting from manzanas to has 
replace q2_ap1=q2_ap1*0.698896
ren q2_ap1 land_size

*Type of raltion with land 
tab q6_ap1, nol
gen prop=(q6_ap1==1)
gen arr=(q6_ap1==2)
gen coop=(q6_ap1==4)
gen oth=(q6_ap1==3 | q6_ap1==5 | q6_ap1==6 | q6_ap1==9)

keep lote hhid plotcode_ap1 land_size prop arr coop oth segmento
duplicates drop hhid plotcode, force

*Merging production 
merge 1:1 lote hhid plotcode using `R3Prod', keep(1 3) nogen 
merge m:1 lote using `R3CantonID', keep(1 3)

*Gen yield for each crop 
forval c=1/4{
	replace prod`c'=prod`c'/22.399 					//		<---- To tons. 
	gen yield`c'=prod`c'/land_size
}

gen ronda=3

tempfile R3Land
save `R3Land', replace


*-------------------------------------------------------------------------------
*RONDA 4:
use "${data}/usaid\original\PUD-R4\community\v13-seccion_a.dta", clear

drop if P003_A==.

tostring P001_A P002_A P003_A, replace
replace P001_A = "0"+P001_A if length(P001_A)==1
replace P002_A = "0"+P002_A if length(P002_A)==1
replace P003_A = "0"+P003_A if length(P003_A)==1

gen codcanton = P001_A + P002_A + P003_A

duplicates drop segmento P001_A P002_A, force

isid segmento P001_A P002_A

ren _all, low
ren (p001_a p002_a p003_a p0011_a p0021_a) (cod_dep cod_mun cod_can nam_dep nam_mun)

keep segmento cod_dep cod_mun cod_can codcanton nam_dep nam_mun 

tempfile R4CantonID
save `R4CantonID', replace 

*HHID Module
use "${data}/usaid\original\PUD-R4\household\v13-caratula_semanas_1_a_11_febrero.dta", clear

ren _all, low
ren (folio departamento municipio)  (hhid nam_dep nam_mun)

keep lote hhid nam_*

tempfile R4Hhid
save `R4Hhid', replace 

*Q2 Module 
use "${data}/usaid\original\PUD-R4\household\v13-q2.dta", clear 
ren _all, low

keep if q1_q2==1
keep if q2_1_q2==1.01 | q2_1_q2==1.02 | q2_1_q2==1.03 | q2_1_q2==1.04
gen int id=(q2_1_q2-1)*100

*Plot ID
recode q3_2_q2 q3_3_q2 (98 = .)
replace q3_1_q2=q3_2_q2 if q3_1_q2==.
replace q3_1_q2=q3_3_q2 if q3_1_q2==. 
ren q3_1_q2 plotcode_ap1

keep if plotcode_ap1!=.

*Converting units 
replace q4_q2=q4_q2*2 if q4_1_q2==1
replace q4_q2=q4_q2/100 if q4_1_q2==3
replace q4_q2=q4_q2*22.046 if q4_1_q2==5
replace q4_q2=q4_q2*22.399 if q4_1_q2==6
replace q4_q2=q4_q2/4 if q4_1_q2==9
replace q4_q2=. if q4_1_q2==116	| q4_1_q2==4									//	<------CHECK!!!!

replace q5_q2=q5_q2*2 if q5_1_q2==1
replace q5_q2=q5_q2/100 if q5_1_q2==3
replace q5_q2=q5_q2*22.046 if q5_1_q2==5
replace q5_q2=q5_q2*22.399 if q5_1_q2==6
replace q5_q2=q5_q2/4 if q5_1_q2==9
replace q5_q2=. if q5_1_q2==116	| q5_1_q2==4									//	<------CHECK!!!!

replace q7_q2=q7_q2*2 if q7_1_q2==1
replace q7_q2=q7_q2/100 if q7_1_q2==3
replace q7_q2=q7_q2/4 if q7_1_q2==9
replace q7_q2=. if q7_1_q2==116 | q7_1_q2==4

bys lote hhid plotcode_ap1 id: egen prod=total(q4_q2) 
bys lote hhid plotcode_ap1 id: egen sell=total(q5_q2) 
bys lote hhid plotcode_ap1 id: egen consump=total(q7_q2) 

keep lote hhid plotcode_ap1 id prod sell consump 

gen sell_sh=sell/prod
gen consump_sh=consump/prod

duplicates drop lote hhid plotcode id, force

reshape wide prod sell sell_sh consump consump_sh, i(lote hhid plotcode) j(id) 

tempfile R4Prod
save `R4Prod', replace 

*AP Module
use "${data}/usaid\original\PUD-R4\household\v13-ap1.dta", clear

ren _all, low

*Only agricultural producers
keep if q1_ap1==1	

*Converting from manzanas to has 
replace q2_ap1=q2_ap1*0.698896
ren q2_ap1 land_size

*Type of raltion with land 
tab q6_ap1, nol
gen prop=(q6_ap1==1)
gen arr=(q6_ap1==2)
gen coop=(q6_ap1==4)
gen oth=(q6_ap1==3 | q6_ap1==5 | q6_ap1==6 | q6_ap1==9)

keep lote hhid segmento plotcode_ap1 land_size prop arr coop oth
duplicates drop hhid plotcode, force

*Merging production 
merge 1:1 lote hhid plotcode using `R4Prod', keep(1 3) nogen 
merge m:1 hhid using `R4Hhid', keep(1 3) nogen
merge m:1 segmento nam_dep nam_mun using `R4CantonID', keep(1 3)

*Gen yield for each crop 
forval c=1/4{
	replace prod`c'=prod`c'/22.399 					//		<---- To tons. 
	gen yield`c'=prod`c'/land_size
}

gen ronda=4

tempfile R4Land
save `R4Land', replace


*-------------------------------------------------------------------------------
*RONDA 5:
use "${data}/usaid\original\PUD-R5\community\v13-seccion_a.dta", clear

drop if P003_A==.

tostring P001_A P002_A P003_A, replace force
replace P002_A=substr(P002_A, length(P002_A)-1,2)
replace P003_A=substr(P003_A, length(P003_A)-1,2)

replace P001_A = "0"+P001_A if length(P001_A)==1
replace P002_A = "0"+P002_A if length(P002_A)==1
replace P003_A = "0"+P003_A if length(P003_A)==1

gen codcanton = P001_A + P002_A + P003_A

duplicates drop lote codcanton, force
duplicates drop lote, force

isid lote

ren _all, low
ren (p001_a p002_a p003_a seg p0011_a p0021_a) (cod_dep cod_mun cod_can segmentoc nam_dep nam_mun)

keep lote cod_dep cod_mun cod_can codcanton nam_* segmentoc

tempfile R5CantonID
save `R5CantonID', replace 

use "${data}/usaid\original\PUD-R5\household\v13-caratula_semana_s1_a_s11.dta", clear

ren _all, low
ren folio hhid

merge m:1 lote using `R5CantonID', keep(3)

keep lote hhid departamento municipio cod_dep cod_mun cod_can codcanton segmentoc

tempfile R5Hhid
save `R5Hhid', replace 

*Q2 Module 
use "${data}/usaid\original\PUD-R5\household\v13-q2.dta", clear 
ren _all, low

keep if q1_q2==1
keep if q2_1_q2==1.01 | q2_1_q2==1.02 | q2_1_q2==1.03 | q2_1_q2==1.04
gen int id=(q2_1_q2-1)*100

*Plot ID
recode q3_2_q2 q3_3_q2 (98 = .)
replace q3_1_q2=q3_2_q2 if q3_1_q2==.
replace q3_1_q2=q3_3_q2 if q3_1_q2==. 
ren q3_1_q2 plotcode_ap1

keep if plotcode_ap1!=.

*Converting units 
replace q4_q2=q4_q2*2 if q4_1_q2==1
replace q4_q2=q4_q2/100 if q4_1_q2==3
replace q4_q2=q4_q2*22.046 if q4_1_q2==5
replace q4_q2=q4_q2*22.399 if q4_1_q2==6
replace q4_q2=q4_q2/4 if q4_1_q2==9
replace q4_q2=. if q4_1_q2==116	| q4_1_q2==113									//	<------CHECK!!!!

replace q5_q2=q5_q2*2 if q5_1_q2==1
replace q5_q2=q5_q2/100 if q5_1_q2==3
replace q5_q2=q5_q2*22.046 if q5_1_q2==5
replace q5_q2=q5_q2*22.399 if q5_1_q2==6
replace q5_q2=q5_q2/4 if q5_1_q2==9
replace q5_q2=. if q5_1_q2==116	| q5_1_q2==113									//	<------CHECK!!!!

replace q7_q2=q7_q2*2 if q7_1_q2==1
replace q7_q2=q7_q2/100 if q7_1_q2==3
replace q7_q2=q7_q2/4 if q7_1_q2==9
replace q7_q2=. if q7_1_q2==116 | q7_1_q2==113

bys lote hhid plotcode_ap1 id: egen prod=total(q4_q2) 
bys lote hhid plotcode_ap1 id: egen sell=total(q5_q2) 
bys lote hhid plotcode_ap1 id: egen consump=total(q7_q2) 

keep lote hhid plotcode_ap1 id prod sell consump 

gen sell_sh=sell/prod
gen consump_sh=consump/prod

duplicates drop lote hhid plotcode id, force

reshape wide prod sell sell_sh consump consump_sh, i(lote hhid plotcode) j(id) 

tempfile R5Prod
save `R5Prod', replace 

*AP Module
use "${data}/usaid\original\PUD-R5\household\v13-ap1.dta", clear

ren _all, low

*Only agricultural producers
keep if q1_ap1==1	

*Converting from manzanas to has 
replace q2_ap1=q2_ap1*0.698896
ren q2_ap1 land_size

*Type of raltion with land 
tab q6_ap1, nol
gen prop=(q6_ap1==1)
gen arr=(q6_ap1==2)
gen coop=(q6_ap1==4)
gen oth=(q6_ap1==3 | q6_ap1==5 | q6_ap1==6 | q6_ap1==9)

keep lote hhid segmento plotcode_ap1 land_size prop arr coop oth
duplicates drop hhid plotcode, force

*Merging production 
merge 1:1 lote hhid plotcode using `R5Prod', keep(1 3) nogen 
merge m:1 hhid using `R5Hhid', keep(1 3)

*Gen yield for each crop 
forval c=1/4{
	replace prod`c'=prod`c'/22.399 					//		<---- To tons. 
	gen yield`c'=prod`c'/land_size
}

gen ronda=5

tempfile R5Land
save `R5Land', replace


*-------------------------------------------------------------------------------
*APPENDING ALL TOGETHER
use `R1Land', clear

append using `R2Land' `R3Land' `R4Land' `R5Land'

*Collapsing at the canton level
collapse land_size prop arr coop oth prod* sell* consump* yield*, by(codcanton)

drop if codcanton==""
destring codcanton, gen(canton_id)

tempfile Land
save `Land', replace 


*-------------------------------------------------------------------------------
*CANTONS SHAPEFILE
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


merge 1:1 canton_id using `Land', keep(1 3)


*-------------------------------------------------------------------------------
* 						Main outcomes 
*
*-------------------------------------------------------------------------------
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

*-------------------------------------------------------------------------------
* 					(Table)
*-------------------------------------------------------------------------------
cap erase "${tables}\rdd_landsize_canton.tex"
cap erase "${tables}\rdd_landsize_canton.txt"

cap erase "${tables}\rdd_crops_canton_p1.tex"
cap erase "${tables}\rdd_crops_canton_p1.txt"
cap erase "${tables}\rdd_crops_canton_p2.tex"
cap erase "${tables}\rdd_crops_canton_p2.txt"

gl outcomes "land_size prop arr coop oth"
gl prod "prod1 prod2 sell1 sell2 consump1 consump2"
gl yield "yield1 yield2 sell_sh1 sell_sh2 consump_sh1 consump_sh2"

la var land_size "Land size"
la var prop "Owner"
la var arr "Renter"
la var coop "Cooperativist"
la var oth "Other relation"
la var within_control "Guerrilla control"

*Table
foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_landsize_canton.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}


*Table
foreach var of global outcomes{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_landsize_canton.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}


*Table
foreach var of global prod{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_crops_canton_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

foreach var of global yield{
	
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_crops_canton_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}




















*END
/* 
Collapsing at the segment level
use `R3Land', clear

append using `R4Land' `R5Land'

tostring segmento, replace
replace segmento="000"+segmento if length(segmento)==1
replace segmento="00"+segmento if length(segmento)==2
replace segmento="0"+segmento if length(segmento)==3

gen segm_id = cod_dep + cod_mun + segmento

collapse land_size prop arr coop oth, by(segm_id)

tempfile LandS
save `LandS', replace 