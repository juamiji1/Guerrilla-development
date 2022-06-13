
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\maps_interim\segm_consult\replacement_centroid.csv", clear 
tempfile R 
save `R', replace 

import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\maps_interim\segm_consult\random_centroid.csv", clear
append using `R'

duplicates tag seg_id, g(dup)

drop if dup==1 & replacement==1

tempfile S
save `S', replace 


import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\maps_interim\segm_consult\slv_places_dup_sgmnt_raw.xlsx", sheet("Sheet1") firstrow clear

ren _all, low
merge m:1 seg_id using `S'
keep if _merge==3

duplicates drop id, force

gen caserio = strpos(name, "caserio")
gen gov = (strpos(type, "local_government_office"))

br if gov==1