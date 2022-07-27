/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Collapsing 2007 census to the segment level 
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


use "${data}/ehpm\ehpm_2000_2017_mjsp.dta", clear 

drop if department==.

tostring department, replace

replace department="0"+department if length(department)==1
replace canton="0"+canton if length(canton)==1

gen canton_id=department+municipio+canton

*Keeping the latest year
bys canton_id: egen max_year=max(year)
keep if year==max_year

*Calculating interquartile range within segments
gen ln_ipcf_ppp11=ln(ipcf_ppp11+1)

gen gini_ephm = .
gen iqr_ephm = .
gen ipr_ephm = .
gen ilr_ephm = .

program gini_more_ephm
	qui ineqdeco ipcf_ppp11
	replace gini_ephm = r(gini)
	replace iqr_ephm = r(p75p25)
	replace ipr_ephm = r(p90p10)
	replace ilr_ephm = r(p90p50)
end

runby gini_more_ephm, by(canton_id) verbose		// Somehow deletes segments with error claculations. 

*Collapsing at the segment level 
collapse (mean) ln_ipcf_ppp11 ipcf_ppp11 gini_ephm iqr_ephm ipr_ephm ilr_ephm, by(canton_id)

destring canton_id, replace 

tempfile Gini0
save `Gini0', replace 


*-------------------------------------------------------------------------------
* 					     	Acommodation and Household conditions 
*	
*-------------------------------------------------------------------------------
use "${data}/censo2007\data\poblacion.dta", clear 

*Keeping head of household only 
keep if S06P01==1

*Has always lived in the same place 
tab S06P08A1 
recode S06P08A1 (2 3=0), gen(always)  

keep DEPID MUNID SEGID VIVID HOGID always

tempfile pop
save `pop', replace 

use "${data}/censo2007\data\vivienda.dta", clear 

*Merging household conditions 
merge 1:m DEPID MUNID SEGID VIVID using "${data}/censo2007\data\hogar.dta", keep(2 3) nogen
merge 1:1 DEPID MUNID SEGID VIVID HOGID using `pop', keep(2 3) nogen

*Creating the segment identifier 
gen segm_id=DEPID+MUNID+SEGID
gen canton_id=DEPID+MUNID+CANID

*Wall materials
gen good_wall=(S02P02==1)
gen bad_wall=(S02P02==6 | S02P02==7)

recode S02P02 (4 6 = 2)
tab S02P02, g(wall_)
recode S02P02 (8=.) (2 3 5 6 7 = 0), gen(good_wall2)

*Roof materials
*gen good_roof=(S02P03==1 | S02P03==2)
gen good_roof=(S02P03==1)
gen bad_roof=(S02P02==6 | S02P02==7 )

recode S02P03 (8=.) (2 3 4= 1) (5 6 7 = 0), gen(good_roof2)
tab S02P03, g(roof_)
*recode S02P03 (2 3 4 5 = 1) (6 7 8 = 0), gen(good_roof)

*Floor materials 
recode S02P05 (-2 = .)
*gen good_floor=(S02P03==1 | S02P03==2)
gen good_floor=(S02P03==1)
gen bad_floor=(S02P02==5 | S02P02==6)

recode S02P05 (6 = 5)
tab S02P05, g(floor_)
recode S02P05 (7=.) (2 3 4 = 1) (4 5 = 0), gen(good_floor2)

*Nuumber of households
recode S02P08 (-2 = .)
tab S02P08

*Total of people within the household 
ren POBTOT pobtot

*Sleeping rooms
tab S03P02
recode S03P02 (0=1)

*Members per sleeping room
gen m_p_room =pobtot/S03P02

*Home ownership 
recode S03P04 (2 3 4 = 1) (5 6 7 = 0)

*Sanitary type 
recode S03P05 (2 = 1) (4 = 3)
tab S03P05, g(sanitary_)

*Exclusive sanitary service 
recode S03P06 (-2 = .) (2 = 0) 

*Dirty water disposal 
tab S03P07, g(dirty_water_)

*Type of water access 
recode S03P08 (2 3 = 1) (6 = 5) (9 = 8)
tab S03P08, g(water_type_)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Cook fuel 
gen electric_cook=(S03P10==1)
recode S03P10 (4 5 6 7 = 8)
tab S03P10, g(fuel_cook_)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Garbage disposal 
recode S03P12 (2 = 1) (3 4 5 6 7 8 = 0)

*Assets characteristics 
recode S03P13A - S03P13M  (-1 -2 = .) (2=0)
gen car_bike= (S03P13J==1 | S03P13K==1)

*Farming or livestock  activity 
recode S03P15A S03P15B (-1 -2 = .) (2=0)

*Land of activity 
recode S03P16 (2 3 = 0)

*Urban area 
ren AREAID urban 
recode urban (2 = 0)

*Total households
gen total_household=1

*Sanitary service 
recode S03P05 (2 3 4 5 = 0)

*Sewerage service 
recode S03P07 (2 3 4 5 6 =0)

*Water pipes 
recode S03P08 (2 3 = 1) (4 5 6 7 8 9 10 = 0)

*Daily water 
recode S03P09 (-2 = .) (2 = 1) (3 4 5 6 = 0)

*Electricity service 
recode S03P11 (2 3 4 5 6 = 0)

*Creating the wealth index 
gl wealthindex "wall_* roof_* floor_* pobtot m_p_room S03P04 sanitary_* S03P06 dirty_water_* water_type_* fuel_cook_* S03P11 S03P12 S03P13A - S03P13M S03P15A S03P15B S03P16 urban"
factor ${wealthindex}, pcf factors(1)
predict z_wi

*summ z_wi, d
*replace z_wi=. if z_wi>`r(p90)' | z_wi<`r(p10)'

gen z_wi_always=z_wi if always==1

*Calculating interquartile range within segments
bys segm_id: egen z_wi_iqr = iqr(z_wi)
bys segm_id: egen z_wi_p50 = median(z_wi)

bys segm_id: egen z_wi_p90 = pctile(z_wi), p(90)
bys segm_id: egen z_wi_p10 = pctile(z_wi), p(10)
bys segm_id: egen z_wi_p95 = pctile(z_wi), p(95)
bys segm_id: egen z_wi_p05 = pctile(z_wi), p(5)

gen z_wi_iqr2=z_wi_p90 - z_wi_p10
gen z_wi_iqr3=z_wi_p95 - z_wi_p05

gen gini_zwi = .
gen iqr_zwi = .
gen ipr_zwi = .
gen ilr_zwi = .

program gini_more
	qui ineqdeco z_wi
	replace gini_zwi = r(gini)
	replace iqr_zwi = r(p75p25)
	replace ipr_zwi = r(p90p10)
	replace ilr_zwi = r(p90p50)
end

runby gini_more, by(canton_id) verbose		// Somehow deletes segments with error claculations. 

*Collapsing at the segment level 
collapse (mean) gini_zwi iqr_zwi ipr_zwi ilr_zwi, by(canton_id)

destring canton_id, replace 

tempfile Gini
save `Gini', replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD
*
*-------------------------------------------------------------------------------
*Loading the data 
use "${data}/temp\slvShp_cantons_info.dta", clear

ren (nl elev2 wmen_nl dst_cnt dst_dsp wthn_cn wthn_ds cn_1000 cnt1000 cnt_400 cntr400) (nl13_density elevation wmean_nl1 dist_control dist_disputed within_control within_disputed dist_control_breaks_1000 control_break_fe_1000 dist_control_breaks_400 control_break_fe_400)

*Canton ID
gen canton_id=COD_DEP+COD_MUN+COD_CAN
destring canton_id, replace 

*To kms
replace dist_control=dist_control/1000
replace dist_disputed=dist_disputed/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 

*Different transformations of the night light density var
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)
gen arcsine_nl13=ln(nl13_density+sqrt(nl13_density^2+1))


*-------------------------------------------------------------------------------
* 					Merging the conflict data 
*
*-------------------------------------------------------------------------------
*Merging the census 2007
merge 1:1 canton_id using `Gini', keep(1 3) nogen
merge 1:1 canton_id using `Gini0', keep(1 3) nogen

*REGRESSION

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Globals
gl inc1  "ln_ipcf_ppp11 ipcf_ppp11 gini_ephm iqr_ephm ipr_ephm ilr_ephm"
gl inc2  "gini_zwi iqr_zwi ipr_zwi ilr_zwi"

*Erasing table before exporting
cap erase "${tables}\rdd_ineq_all_canton_p1.tex"
cap erase "${tables}\rdd_ineq_all_canton_p1.txt"
cap erase "${tables}\rdd_ineq_all_canton_p2.tex"
cap erase "${tables}\rdd_ineq_all_canton_p2.txt"


foreach var of global inc1{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_canton_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}

foreach var of global inc2{

	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_ineq_all_canton_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 

}





*END









