/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Exploring lapop 
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

/*gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development"
gl path "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

*Setting the working directory 
cd ${data}

*Setting a pre-scheme for plots
set scheme s2color, perm 
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray
*/


*-------------------------------------------------------------------------------
* 					     	Acommodation and Household conditions 
*	
*-------------------------------------------------------------------------------
use "${localpath}\2-Data\Salvador\lapop\lapop2008", clear

tostring prov municipio elssegmento, replace force
replace prov = "0"+prov if length(prov)==1
replace municipio = "0"+municipio if length(municipio)==1
replace elssegmento = "0"+elssegmento if length(elssegmento)==3
replace elssegmento = "00"+elssegmento if length(elssegmento)==2
replace elssegmento = "000"+elssegmento if length(elssegmento)==1

gen segm_id=prov+municipio+elssegmento

keep if elssegmento!="0000"

gen one=1 
collapse (sum) total=one, by(segm_id)

export delimited using "${data}\lapop08_count.csv", replace

tempfile L
save `L', replace



use "${data}/temp\census07_segm_lvl.dta", clear
keep segm_id

merge 1:1 segm_id using `L'

gen l=length(segm_id)