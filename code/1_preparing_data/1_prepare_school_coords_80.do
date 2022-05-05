import excel "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\mineduc\El Salvados antes del '89.xlsx", sheet("Hoja1") firstrow clear

ren (CÓDIGO AÑO) (entidad year)

destring entidad year, force replace

*Keeping first year of creation
bys entidad: egen min_y=min(year)
keep if year==min_y
drop if year==.
duplicates drop entidad year, force

keep entidad year

tempfile P1
save `P1', replace 

import delimited "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\mineduc\matricula_coords_2007.csv", encoding(ISO-8859-2) clear

merge 1:1 entidad using `P1', keep(1 3) nogen 

keep if year<1981

export delimited using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\mineduc\escuelas_before_80.csv", replace