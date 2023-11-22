

clear all 


use"C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\interim\census_1992_poblacion.dta", clear

gen pobtot=1

collapse (sum) pobtot, by(canton department manzana municipality num_vivienda sector segment zone)

tempfile pop
save `pop', replace 

use"C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\interim\census_1992_vivienda.dta", clear

*Merging number of individuals in the hh 
merge 1:1


*Wall materials
tab v1_paredes, g(wall_)

*Roof materials
tab v2_techo, g(roof_)

*Roof materials
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
tab v7_donde_agua, g(water_source_)
tab v8_tiene_agua, g(has_water_)

*Cook fuel 
gen electric_cook=(v9_combustible==1)
recode v9_combustible (4 5 = 6)
tab v9_combustible, g(fuel_cook_)

*Electric light
recode v10 _alumbrado (2 3 4 5 6 7 = 0)

*Garbage disposal 
recode v14_basura (2 = 1) (3 4 5 = 0)

*Casa propia 
recode v12_tenencia (2 = 1) (3 4 = 0)

*Apliances 
recode v13* (2 = 0)




v11b_dormitorios


*COMMENTS EN ESTE CENSO SI ESTA EL LUGAR DE NACIMIENTO (Internal migration) Also a variable of always lived here. 



use"C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\interim\census_1992_poblacion.dta", clear


gen educ_yrs = p12b_ultimo_ano
replace educ_yrs = educ_yrs + 6 if p12a_nivel_educa==3
replace educ_yrs = educ_yrs + 9 if p12a_nivel_educa==4
replace educ_yrs = educ_yrs + 12 if p12a_nivel_educa==5 | p12a_nivel_educa==6 | p12a_nivel_educa==7

gen educ_yrs_v2=educ_yrs
replace educ_yrs_v2=. if age<18





