
import excel "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\edh_muertes_guerra_civil\victimas.xlsx", sheet("Victimas-conlatlon") firstrow case(lower) clear

destring latitud longitud, replace force 

replace latitud=latitud/1000000 if latitud>100
replace longitud=longitud/1000000 if longitud<-100

keep if latitud!=. & longitud!=.

export delimited using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\edh_muertes_guerra_civil\victims_XY.csv", replace

 
import excel "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\edh_muertes_guerra_civil\eventos.xlsx", sheet("Eventos-conlatlon") firstrow case(lower) clear

destring latitud longitud, replace force 

replace latitud=latitud/1000000 if latitud>100
replace longitud=longitud/1000000 if longitud<-100

keep if latitud!=. & longitud!=.

export delimited using "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\gis\edh_muertes_guerra_civil\events_XY.csv", replace