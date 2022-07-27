/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Fixing the School data fo 2007  

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
*	 						1. Preparing the Data
*
*-------------------------------------------------------------------------------
*Importing the data 
import delimited "${data}\censodocente\CENSO2013_DOCENTES__Solicitud_MINED_T2_125.csv", encoding(UTF-8) clear 

*Fixing vars
ren codinf entidad 
gen docentes=1
gen acreditado=d_01_1
gen acreditado_more=d_01_1
replace acreditado_more=0 if acreditado_more==1 & d_02_1==1
gen more_bachiller=(d_02_1==0 & d_03_1==0)

collapse (sum) docentes acreditado acreditado_more more_bachiller, by(entidad)

tempfile Teachers
save `Teachers', replace 

*Importing the data 
import delimited "${data}\gis\mineduc\coorces_2.csv", encoding(UTF-8) clear 

tempfile Coords
save `Coords', replace 

*Import enrollment data
import excel "${data}\gis\mineduc\matricula_2007.xls", sheet("Base de Centros 2007") firstrow clear

*Renaming to lower case 
rename _all, low

*Keeping only obs and vars of interest
drop if entidad==""
keep entidad matricula 

*Merging teachers 
merge 1:1 entidad using `Teachers', keep(1 3) nogen 

*Merging coordinates 
merge 1:1 entidad using `Coords', keep(3) keepus(x y) nogen 

*Exporting data to use in R
export delimited "${data}\gis\mineduc\matricula_coords_2007.csv", replace  






/*END

Important vars of censo docente
d_01_1 

*SI
d_02_2 d_02_3 d_02_4 d_02_5 d_02_6  d_02_8
d_02_7

*NO
d_03_2 d_03_4 d_03_5 d_03_6 d_03_7 d_03_8
d_03_3

