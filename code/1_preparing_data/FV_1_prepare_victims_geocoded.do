/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Fixing the victims data

NOTES: 
------------------------------------------------------------------------------*/

import excel "${data}\gis\edh_muertes_guerra_civil\victimas.xlsx", sheet("Victimas-conlatlon") firstrow case(lower) clear

destring latitud longitud, replace force 

replace latitud=latitud/1000000 if latitud>100
replace longitud=longitud/1000000 if longitud<-100

keep if latitud!=. & longitud!=.

export delimited using "${data}\gis\edh_muertes_guerra_civil\victims_XY.csv", replace

 
import excel "${data}\gis\edh_muertes_guerra_civil\eventos.xlsx", sheet("Eventos-conlatlon") firstrow case(lower) clear

destring latitud longitud, replace force 

replace latitud=latitud/1000000 if latitud>100
replace longitud=longitud/1000000 if longitud<-100

keep if latitud!=. & longitud!=.

export delimited using "${data}\edh_muertes_guerra_civil\events_XY.csv", replace