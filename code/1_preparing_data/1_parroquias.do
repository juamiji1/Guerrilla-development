

import excel "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\Base Final_Censo de Parroquias en El Salvador BM_13-03-2021.xlsx", sheet("Base de Encuestas Efectivas") firstrow clear 

keep P2Cuáleslaordensacerdota P3Enquéañofuefundadaest DireccionDireccióndelaparr DiocesisDiócesisColocarseg ParroquiaParroquiaColocars P2_O

ren (P2Cuáleslaordensacerdota P3Enquéañofuefundadaest DireccionDireccióndelaparr DiocesisDiócesisColocarseg ParroquiaParroquiaColocars P2_O) (orden year_fundacion direccion diocesis parroquia orden2)

replace orden=orden2 if orden2!=""
replace orden="" if orden=="Desconoce"

duplicates drop diocesis parroquia direccion, force

save "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\encuesta_info.dta", replace 


import excel "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\parroquias_geo_total.xlsx", sheet("Sheet1") firstrow clear

ren _all, low
ren (diócesis dirección añoquesefinanció) (diocesis direccion year_financiacion)

duplicates drop diocesis parroquia direccion, force

merge 1:1 diocesis parroquia direccion using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\encuesta_info.dta", keep(1 3) nogen 

drop if longitude==.
drop if latitude==.

export delimited using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\parroquias_coord.csv", replace

preserve
	keep if orden=="Franciscanos"

	export delimited using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\francis_coord.csv", replace
restore

keep if year_fundacion<1981

export delimited using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\parroquias\parr80_coord.csv", replace


*Z por orden 
*Z por decada
*elevtion less than 1000 
*Campamentos en elevacion!!!! quedarnos con las zonas fuera de elevacion. 
*Z de cdistancia a campamentos con distancia a parroquias?


*END