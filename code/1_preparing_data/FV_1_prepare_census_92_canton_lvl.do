
clear all 


*-------------------------------------------------------------------------------
*Fixing censuses keys 92 & 07
*
*-------------------------------------------------------------------------------
import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\documentation\CatalogoGeografico1992.xlsx", sheet("Table 1") firstrow clear

replace municipality="SAN JUAN OPICO" if municipality=="OPICO"
replace canton="AREA URBANA" if municipality==canton & codcanton==1

replace canton=subinstr(canton,"Ð","Ñ",.)

rename cod* =92

tostring cod*, replace 

replace codepto92="0"+codepto92 if length(codepto92)==1
replace codmuni92="0"+codmuni92 if length(codmuni92)==1
replace codcanton92="0"+codcanton92 if length(codcanton92)==1

gen id92=codepto92+codmuni92+codcanton92
destring id92, replace 

tempfile ID92
save `ID92', replace

import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\documentation\cantonsID2007.xls", sheet("Cantons_From2007CensusSegments.") firstrow clear

ren _all, low
ren (depto cod_dep mpio cod_mun canton cod_can) (department codepto07 municipality codmuni07 canton codcanton07)

gen id07=codepto07+codmuni07+codcanton07
destring id07, replace 

reclink department municipality canton using `ID92', idm(id07) idu(id92) g(fmscore) req(department municipality) _merge(fmerge)

keep if fmscore>=0.9 & fmscore!=.

duplicates tag id07, g(dup)
tab dup
drop dup 

duplicates tag id92, g(dup)
tab dup
drop dup 

bys id92: egen maxfmscore=max(fmscore)
keep if fmscore==maxfmscore

isid id07
isid id92

tempfile keys
save `keys', replace


*-------------------------------------------------------------------------------
*Creating the vars of interest
*
*-------------------------------------------------------------------------------
use"C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\interim\census_1992_poblacion.dta", clear

sort department municipality canton zone sector segment manzana num_vivienda p1_parentesco index
by department municipality canton zone sector segment manzana num_vivienda p1_parentesco: gen hogid=_n

replace hogid=. if p1_parentesco!=0
order department municipality canton zone sector segment manzana num_vivienda index hogid p1_parentesco

sort index
carryforward hogid, replace 

gen pobtot=1

collapse (sum) pobtot, by(department municipality canton zone sector segment manzana num_vivienda hogid)

tempfile pop
save `pop', replace 

use"C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\interim\census_1992_vivienda.dta", clear

destring manzana num_vivienda, replace 
bys department municipality canton zone sector segment manzana num_vivienda: gen hogid=_n
order department municipality canton zone sector segment manzana num_vivienda hogid

*Urban is always de first canton within municipality
gen urban=(canton==1)

*Merging number of individuals in the hh 
merge 1:1 department municipality canton zone sector segment manzana num_vivienda hogid using `pop', keep(1 3)

*Wall materials
recode v1_paredes (4 6 = 2)
tab v1_paredes, g(wall_)

*Roof materials
tab v2_techo, g(roof_)

*Floor materials
recode v4_piso (5 = 4)
tab v4_piso, g(floor_)

*Exclusive sanitary
gen exclu_sanitary=1 if v5_servicio==1 | v5_servicio==3
replace exclu_sanitary=0 if exclu_sanitary==. & v5_servicio!=. 

*Sanitary
recode v5_servicio (2 = 1) (4 = 3)
tab v5_servicio, g(sanitary_)

*Source of water
tab v6_desague, g(dirty_water_)

*Has water 
recode v7_donde_agua  (3 = 2) (5 = 4) (9 = 8)
tab v7_donde_agua, g(water_type_)
tab v8_tiene_agua, g(has_water_)

*Cook fuel 
gen electric_cook=(v9_combustible==1)
recode v9_combustible (4 5 = 6)
tab v9_combustible, g(fuel_cook_)

*Electric light
recode v10_alumbrado (2 3 4 5 6 7 = 0)

*Garbage disposal 
recode v14_basura (2 = 1) (3 4 5 = 0)

*Casa propia 
recode v12_tenencia (2 = 1) (3 4 = 0)

*Apliances 
recode v13* (2 4 6 8= 0) (3 5 7 =1)

*Number of dorms per person
gen m_p_room =pobtot/v11b_dormitorios

*Creating the wealth index 
gl wealthindex "wall_* roof_* floor_* pobtot m_p_room v12_tenencia sanitary_* exclu_sanitary dirty_water_* water_type_* has_water_* fuel_cook_* v10_alumbrado v14_basura v13* urban"
factor ${wealthindex}, pcf factors(1)
predict z_wi

collapse (mean) z_wi92=z_wi, by(department municipality canton)

tempfile Household
save `Household', replace  


*Population outcomes 
use"C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\interim\census_1992_poblacion.dta", clear

*Creating educ years measure
gen educ_yrs_v2 = p12b_ultimo_ano
replace educ_yrs_v2 = educ_yrs_v2 + 6 if p12a_nivel_educa==3
replace educ_yrs_v2 = educ_yrs_v2 + 9 if p12a_nivel_educa==4
replace educ_yrs_v2 = educ_yrs_v2 + 12 if p12a_nivel_educa==5 | p12a_nivel_educa==6 | p12a_nivel_educa==7

gen educ_yrs=educ_yrs_v2
replace educ_yrs=. if age<18

*Creating ISICv3 activity codes
gen isic1_agr92=(p17_produce<1000) & p17_produce!=.
gen isic1_ind92=(p17_produce>=1000 & p17_produce<5000) & p17_produce!=.
gen isic1_serv92=(p17_produce>=5000) & p17_produce!=.
gen agr_azcf92=(p17_produce==111 | p17_produce==113)

collapse (mean) isic1_agr92 isic1_ind92 isic1_serv92 agr_azcf92 mean_educ_years92=educ_yrs mean_educ_years92_v2=educ_yrs_v2, by(department municipality canton)

merge 1:1 department municipality canton using `Household', keep(1 3) nogen 

*Fixing IDs 
ren (department municipality canton) (codepto92 codmuni92 codcanton92)

tostring cod*, replace 

replace codepto92="0"+codepto92 if length(codepto92)==1
replace codmuni92="0"+codmuni92 if length(codmuni92)==1
replace codcanton92="0"+codcanton92 if length(codcanton92)==1

gen id92=codepto92+codmuni92+codcanton92
destring id92, replace 

merge 1:1 id92 using `keys', keep(3) gen(merge_keys)

tempfile info92
save `info92'


*-------------------------------------------------------------------------------
* Merging with canton info of 07 
*
*-------------------------------------------------------------------------------
*shp2dta using "${data}/gis\maps_interim\slvShp_cantons_info_sp", data("${data}/temp\slvShp_cantons_info.dta") coord("${data}/temp\slvShp_cantons_info_coord.dta") genid(pixel_id) genc(coord) replace 

use "${data}/temp\slvShp_cantons_info.dta", clear

ren (nl elev2 nl92 dst_cnt dst_dsp wthn_cn wthn_ds cn_1000 cnt1000 cnt_400 cntr400) (nl13_density elevation nl92_density dist_control dist_disputed within_control within_disputed dist_control_breaks_1000 control_break_fe_1000 dist_control_breaks_400 control_break_fe_400)

*Canton ID
gen id07=COD_DEP+COD_MUN+COD_CAN
destring id07, replace 

*To kms
replace dist_control=dist_control/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))

gen ln_nl92=ln(nl92_density)
gen arcsine_nl92=ln(nl92_density+sqrt(nl92_density^2+1))

*Merging info from 92 census
merge 1:1 id07 using `info92', keep(1 3) nogen

*Saving the data 
save "${data}/temp\census9207_canton_lvl.dta", replace 











*END



*COMMENTS EN ESTE CENSO SI ESTA EL LUGAR DE NACIMIENTO (Internal migration) Also a variable of always lived here. 

