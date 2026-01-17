/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating attitudes outcomes but using within sample calculations
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*-------------------------------------------------------------------------------
*Sample of Segments
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

*Conditional for all specifications
keep if abs(z_run_cntrl)<=${h}

gen rdsample=1

keep segm_id z_run_cntrl rdsample 

tempfile RDDSAMPLE
save `RDDSAMPLE', replace 

*-------------------------------------------------------------------------------
*LAPOP
*-------------------------------------------------------------------------------
capture program drop make_index_gr
capture mata: mata drop icwxmata()
program make_index_gr
version 16
    syntax anything [if]
    gettoken newname anything: anything
    gettoken wgt anything: anything
	gettoken sgroup anything: anything
    local Xvars `anything'
	marksample touse
  	mata: icwxmata(("`Xvars'"),"`wgt'","`sgroup'", "index")
	rename index index_`newname'
end

mata:
	mata set matastrict off
	function icwxmata(xvars, wgts, sgroups, indexname)
	{
		st_view(X=0,.,tokens(xvars))
		st_view(wgt=.,.,wgts)
		st_view(sgroup=.,.,sgroups)
		nr = rows(X)
		nc = cols(X)	
		sg_wgt = wgt:*sgroup
		sg_wgtst = sg_wgt/sum(sg_wgt)
		all_wgtst = wgt/sum(wgt)
		sg_wgtstdM = J(1,nc,1) # sg_wgtst
		all_wgtstdM = J(1,nc,1) # all_wgtst
		sg_wgtdmeans = colsum(X:*sg_wgtstdM)
		sgroup2 = sgroup
		sgroupdM = J(1,nc,1) # sgroup2
		sg_meandevs = ((X:*sgroupdM) - (J(nr,1,1) # sg_wgtdmeans):*sgroupdM)
		all_wgtdmeandevs = X - (J(nr,1,1) # sg_wgtdmeans)
		sg_wgtdstds = sqrt(colsum(sg_wgt:*(sg_meandevs:*sg_meandevs)):/(sum(sg_wgt)-1))
		Xs = all_wgtdmeandevs:/(J(nr,1,1) # sg_wgtdstds)
		S = variance(Xs, wgt)
		invS = invsym(S)
		ivec = J(nc,1,1)
		indexout_sc = (invsym(ivec'*invS*ivec)*ivec'*invS*Xs')'
		indexout = indexout_sc/sqrt(variance(indexout_sc, sg_wgt))
		st_addvar("float",indexname)
		st_store(.,indexname,indexout)
	}
end

import excel "/Users/bj6385/Desktop/GD_SLV/Survey Data/In/censo2007/gis_segmentos/ID_census_v2.xls", sheet("ID_census_v2") firstrow clear 
ren _all, low

*Creating the segment id  
gen segid_part=substr(name, 4, 4)
gen segm_id=cod_dpto+cod_mun+segid_part

*Dropping duplicates 
*duplicates drop segm_id, force

keep segm_id id 

tempfile ID
save `ID', replace

import excel "/Users/bj6385/Desktop/GD_SLV/Survey Data/In/censo2007/gis_segmentos/ID_census_v1.xls", sheet("ID_census_v1") firstrow clear 
ren _all, low

ren seg_id segm_id
keep segm_id

merge 1:m segm_id using `ID', keep(3) nogen

ren id ID 
isid ID 

tempfile ID2
save `ID2', replace

*New vars 
use "${data}/lapop/base_nueva/20220401_LAPOP 2004-2016 a nivel de individuo con ID.dta", clear

drop _merge
merge m:1 ID using `ID2', keep(3) nogen

d sitecon reu_relig reu_esc reu_prof reu_com conf_com contrib_c paz_cal paz_sitecon paz_sitpol paz_camb

foreach var in reu_relig reu_esc reu_prof reu_com conf_com{
	gen `var'_high=(`var'==1) if `var'!=.
	gen `var'_low=(`var'==4) if `var'!=.
} 

gen asist_reu_high= (reu_relig==1 | reu_esc==1 | reu_com==1 | reu_prof==1) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.
gen asist_reu_low= (reu_relig==4 | reu_esc==4 | reu_com==4 | reu_prof==4) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.

recode sitecon (2 3 = 1) (4 5 = 0)
recode reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon (2 = 1) (3 4 = 0) 

gen asist_reu= (reu_relig==1 | reu_esc==1 | reu_com==1 | reu_prof==1) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.

*Collapsing at the segment level
collapse sitecon reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon paz_sitpol asist_reu *_high *_low, by(segm_id)

tempfile LAPOP0
save `LAPOP0', replace 

*Index vars
use "${data}/lapop/lapop_panel_segmento/LAPOP 2004-2016 a nivel de individuo con ID.dta", clear

drop _merge
merge m:1 ID using `ID2', keep(3) nogen
merge m:1 segm_id using `RDDSAMPLE', keep (1 3) nogen 

d aprobacion2 aprobacion3 aprobacion4 aprobacion7 aprobacion8 bienservicio1 bienservicio4 confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 confianza47a culturapolitica2 culturapolitica3 culturapolitica4 satisfaccion2 satisfaccion3 satisfaccion6

*Recoding 
recode aprobacion3 aprobacion4 aprobacion7 aprobacion8 (1/5 = 0) (6/10 =1)
recode bienservicio1 (1 = 0) (2/4 =1)
recode confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 confianza47a (1/4 = 0) (5/7 =1)
recode culturapolitica4 (4 = 0) (2/3 = 1)
recode satisfaccion2 satisfaccion3 satisfaccion6 (3/4 = 0) (2 = 1)

*Indices (sum)
drop confianza47a confianza50 confianza68 confianza69

gl pp "aprobacion1 aprobacion2 aprobacion3 aprobacion4"
gl ep "culturapolitica2 culturapolitica3 culturapolitica4"
gl ap "aprobacion5 aprobacion6 aprobacion7 aprobacion8 "
gl trst "confianza1 confianza2 confianza4 confianza6 confianza12 confianza13 confianza18 confianza21 confianza31 confianza43 confianza47"

*Political affiliations
egen miss1=rowmiss(${pp})
gen pp_sample=(miss1==0)

egen miss2=rowmiss(${ep})
gen ep_sample=(miss2==0)

egen miss3=rowmiss(${ap})
gen ap_sample=(miss3==0)

egen miss4=rowmiss(${trst})
gen trst_sample=(miss4==0)

*Total summatory 
egen sum_pp=rowtotal(${pp}) if pp_sample==1 & rdsample==1, missing
egen sum_ep=rowtotal(${ep}) if ep_sample==1 & rdsample==1, missing
egen sum_ap=rowtotal(${ap}) if ap_sample==1 & rdsample==1, missing
egen sum_trst=rowtotal(${trst})  if trst_sample==1 & rdsample==1, missing

*Indices (ICW)
gen wgt=1
gen stdgroup=1

make_index_gr pp wgt stdgroup ${pp} if rdsample==1
make_index_gr ep wgt stdgroup ${ep} if rdsample==1
make_index_gr ap wgt stdgroup ${ap} if rdsample==1
make_index_gr trst wgt stdgroup ${trst} if rdsample==1

egen z_index_pp_v2=std(index_pp) if rdsample==1
egen z_index_ep_v2=std(index_ep) if rdsample==1
egen z_index_ap_v2=std(index_ap) if rdsample==1
egen z_index_trst_v2=std(index_trst) if rdsample==1

summ z_index_pp_v2 z_index_ep_v2 z_index_ap_v2 z_index_trst_v2

*Crime perceptions
recode pandillaje (4 3 2 = 0) 
gen delinc_all=1 if delinc==1 | delinc_hog==1
replace delinc_all=0 if delinc==0 & delinc_hog==0

*Collapsing 
collapse (mean) z_index* rdsample, by(segm_id)
*collapse (mean) index* rdsample, by(segm_id)

summ z_index_pp_v2 z_index_ep_v2 z_index_ap_v2 z_index_trst_v2

*egen z_index_pp_v2=std(index_pp) if rdsample==1
*egen z_index_ep_v2=std(index_ep) if rdsample==1
*egen z_index_ap_v2=std(index_ap) if rdsample==1
*egen z_index_trst_v2=std(index_trst) if rdsample==1

*Merging the new vars
merge 1:1 segm_id using `LAPOP0', nogen

*Checking the unique identifier
isid segm_id

*Saving the data 
tempfile LAPOP
save `LAPOP', replace 

*-------------------------------------------------------------------------------
* Preparing the data to have a structure where the unit of observation is the 
* pair of census tracts that are neighbors 
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 
merge 1:1 segm_id using `LAPOP', keep(1 3) nogen 


*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)

gen estsample=1 if abs(z_run_cntrl)<=${h}

keep segm_id arcsine_nl13 nl13_density wmean_nl1 elevation2 within_control z_run_cntrl z_wi mean_educ_years estsample control_break_fe_400 z_index_pp_v2 z_index_ep_v2 z_index_ap_v2 z_index_trst_v2 conf_com_low

tempfile INFO
save `INFO', replace 

*Importing neighbo matrices 
import excel "${data}/nbr_matrix_p3.xls", sheet("nbr_matrix_p3") firstrow clear

tempfile P3
save `P3', replace 

import excel "${data}/nbr_matrix_p2.xls", sheet("nbr_matrix_p2") firstrow clear

tempfile P2
save `P2', replace 

import excel "${data}/nbr_matrix_p1.xls", sheet("nbr_matrix_p1") firstrow clear
append using `P2' `P3'

ren (src_SEG_ID nbr_SEG_ID) (segm_id_cntr segm_id)

drop OBJECTID LENGTH NODE_COUNT

*Merging info of pairs
merge m:1 segm_id using `INFO', keep(3) nogen 
ren (arcsine_nl13 nl13_density wmean_nl1 elevation2 within_control z_run_cntrl z_wi mean_educ_years estsample control_break_fe_400 z_index_pp_v2 z_index_ep_v2 z_index_ap_v2 z_index_trst_v2 conf_com_low) nbr_=
ren segm_id segm_id_nbr 
ren segm_id_cntr segm_id

merge m:1 segm_id using `INFO', keep(3) nogen 

*Calculating the differences 
gen diff_elevation2= elevation2 - nbr_elevation2
gen diff_nl13_density= nl13_density - nbr_nl13_density
gen diff_arcsine_nl13= arcsine_nl13 - nbr_arcsine_nl13
gen diff_wmean_nl1= wmean_nl1-nbr_wmean_nl1
gen diff_z_wi= z_wi - nbr_z_wi
gen diff_mean_educ_years= mean_educ_years - nbr_mean_educ_years

gen diff_pol_part=z_index_pp_v2 - nbr_z_index_pp_v2
gen diff_pol_eng=z_index_ep_v2 - nbr_z_index_ep_v2
gen diff_pol_ap=z_index_ap_v2 - nbr_z_index_ap_v2
gen diff_pol_trst= z_index_trst_v2 - nbr_z_index_trst_v2
gen diff_pol_distrust=conf_com_low-nbr_conf_com_low
*Keeping only the pair of neighbors that have the positive difference in wealth
preserve
cls
keep if diff_z_wi>0

summ diff_z_wi, d

*-------------------------------------------------------------------------------
* Sample of neighbor pairs with a wealth difference between arbitrary numbers.
*-------------------------------------------------------------------------------

gen sample=1 if diff_z_wi>=0 & diff_z_wi<=0.5

foreach t in part eng ap trst distrust { 
cap erase "${tables}/rdd_all_wealth_placebo_`t'.tex"
cap erase "${tables}/rdd_all_wealth_placebo_`t'.txt"

reg diff_pol_`t' if sample==1, r
outreg2 using "${tables}/rdd_all_wealth_placebo_`t'.tex", tex(frag) replace
reg diff_pol_`t' if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_wealth_placebo_`t'.tex", tex(frag) append
reg diff_pol_`t' if diff_z_wi>=.5 & diff_z_wi<=2, r
outreg2 using "${tables}/rdd_all_wealth_placebo_`t'.tex", tex(frag) append
reg diff_pol_`t' if diff_z_wi>=.5 & diff_z_wi<=2 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_wealth_placebo_`t'.tex", tex(frag) append

}
restore 


preserve
keep if diff_arcsine_nl13>0
summ diff_arcsine_nl13, d


cap drop sample
gen sample=1 if diff_arcsine_nl13>=0 & diff_arcsine_nl13<=0.1

foreach t in part eng ap trst distrust { 
cap erase "${tables}/rdd_all_arcsine_placebo_`t'.tex"
cap erase "${tables}/rdd_all_arcsine_placebo_`t'.txt"


reg diff_pol_`t' if sample==1, r
outreg2 using "${tables}/rdd_all_arcsine_placebo_`t'.tex", tex(frag) replace
reg diff_pol_`t' if sample==1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_arcsine_placebo_`t'.tex", tex(frag) append
reg diff_pol_`t' if diff_arcsine_nl13>=0.1 & diff_arcsine_nl13<=1, r
outreg2 using "${tables}/rdd_all_arcsine_placebo_`t'.tex", tex(frag) append
reg diff_pol_`t' if diff_arcsine_nl13>=0.1 & diff_arcsine_nl13<=1 & within_control==0 & nbr_within_control==0, r
outreg2 using "${tables}/rdd_all_arcsine_placebo_`t'.tex", tex(frag) append

}
restore 
