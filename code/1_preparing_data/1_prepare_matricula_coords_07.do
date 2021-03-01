/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Fixing the School data fo 2007  
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
*	 						1. Preparing the Data
*
*-------------------------------------------------------------------------------
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

*Merging coordinates 
merge 1:1 entidad using `Coords', keep(3) keepus(x y) nogen 

*Exporting data to use in R
export delimited "${data}\gis\mineduc\matricula_coords_2007.csv", replace  






*END
