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


keep segm_id z_run_cntrl rdsample within_control

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

 
*Crime perceptions
recode pandillaje (4 3 2 = 0) 
gen delinc_all=1 if delinc==1 | delinc_hog==1
replace delinc_all=0 if delinc==0 & delinc_hog==0

*Collapsing 
collapse (mean) rdsample index* (first) within_control, by(segm_id)

  foreach y in index_pp index_ep index_ap index_trst {
  	sum `y' if rdsample==1 & within_control==0
  	gen z_`y'=((`y'-r(mean))/r(sd)) if rdsample==1
 }


*Merging the new vars
merge 1:1 segm_id using `LAPOP0', nogen

*Checking the unique identifier
isid segm_id

*Saving the data 
tempfile LAPOP
save `LAPOP', replace 


*-------------------------------------------------------------------------------
* 						Spatial RDD Results
*
*-------------------------------------------------------------------------------
*Census segment level data 
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear 
cap drop z_index_pp z_index_ep z_index_ap z_index_trst 

merge 1:1 segm_id using `LAPOP', keep(1 3) nogen 

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

*Labels
la var sum_pp "Political Participation (sum)"
la var sum_ep "Engagement with Politicians (sum)"
la var sum_ap "Non-Democratic Engagement (sum)"
la var sum_trst "Trust in Institutions (sum)"

la var z_index_pp "Political Participation (ICW)"
la var z_index_ep "Engagement with Political (ICW)"
la var z_index_ap "Non-Democratic Engagement (ICW)"
la var z_index_trst "Trust in Institutions (ICW)"

*-------------------------------------------------------------------------------
* 						Attitudes outcomes (Table)
*-------------------------------------------------------------------------------
*Global of outcomes

gl trst2 "z_index_pp z_index_ep z_index_ap z_index_trst"

*Erasing table before exporting

local r replace
foreach var of global trst2 {
	
	*Table
	cap nois reghdfe `var' ${controls} [aw=tweights] if rdsample==1, vce(r) a(i.${breakfe}) resid keepsing // keepsing ensures rdsample= e(sample)
	summ `var' if e(sample)==1 & within_control==0
	gl mean_y=round(r(mean), .001)
	
	outreg2 using "${tables}/rdd_trust_rdsample_all_v2.tex", nor2  tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	local r append

}

preserve 
  insheet using "${tables}/rdd_trust_rdsample_all_v2.txt", nonames clear
 drop v2

replace v1 = "Guerrilla control" in 4
insobs 2, before(1)
drop in 4
replace v3 = "Political" in 1
replace v3 = "Participation" in 2
replace v4 = "Engagement with" in 1
replace v4 = "Politicians" in 2
replace v5 = "Non-Democratic " in 1
replace v5 = "Engagement" in 2
replace v6 = "Trust in " in 1
replace v6 = "Institutions" in 2

dataout, tex save("${tables}/rdd_trust_rdsample_all_v2") replace nohead  midborder(3)
 
restore






*END
