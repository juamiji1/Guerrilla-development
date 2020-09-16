/*------------------------------------------------------------------------------
TOPIC:
AUTHOR:
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

gl path "C:\Users\jmjimenez\Dropbox\Mica-projects\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "${path}\4-Results\Salvador\plots"
gl tables "${path}\4-Results\Salvador\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}


*Coverting shape to dta 
shp2dta using "${maps}/guerrilla_map/nl13Shp_pixels_sp", data("${data}/nl13Shp_pixels.dta") coord("${data}/nl13Shp_pixels_coord.dta") genid(pixel_id) genc(coord) replace 