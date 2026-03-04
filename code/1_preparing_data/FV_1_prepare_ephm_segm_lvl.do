

use "${data}/ehpm\ehpm_2000_2017_mjsp.dta", clear 

*Fixing social assistance 
bys id: egen assistance=max(asistencia)
gen c=(emp_type_p==4)
bys id: egen cooperative=max(c)

*Collapsing at the household level
collapse (max) cooperative assistance ipcf_ppp11 pondera itf_m ilpc_m inlpc_m itranext_m agr_income iasalp_m ictapp_m ip_m wage_m, by(segment_id id year)

*Keeping the latest year
bys segment_id: egen max_year=max(year)
keep if year==max_year

*Calculating interquartile range within segments
gen ln_ipcf_ppp11=ln(ipcf_ppp11+1)

bys segment_id: egen ipcf_ppp11_iqr = iqr(ipcf_ppp11)
bys segment_id: egen ipcf_ppp11_p50 = median(ipcf_ppp11)

bys segment_id: egen ipcf_ppp11_p90 = pctile(ipcf_ppp11), p(90)
bys segment_id: egen ipcf_ppp11_p10 = pctile(ipcf_ppp11), p(10)
bys segment_id: egen ipcf_ppp11_p95 = pctile(ipcf_ppp11), p(95)
bys segment_id: egen ipcf_ppp11_p05 = pctile(ipcf_ppp11), p(5)
bys segment_id: egen ipcf_ppp11_p75 = pctile(ipcf_ppp11), p(75)
bys segment_id: egen ipcf_ppp11_p25 = pctile(ipcf_ppp11), p(25)

gen ipcf_ppp11_iqr2=ipcf_ppp11_p90 - ipcf_ppp11_p10
gen ipcf_ppp11_iqr3=ipcf_ppp11_p95 - ipcf_ppp11_p05

gen ipcf_ppp11_pr9010=ipcf_ppp11_p90/ipcf_ppp11_p10
gen ipcf_ppp11_pr9505=ipcf_ppp11_p95/ipcf_ppp11_p05
gen ipcf_ppp11_pr7525=ipcf_ppp11_p75/ipcf_ppp11_p25

gen hh_p2575=(ipcf_ppp11>=ipcf_ppp11_p25 & ipcf_ppp11<=ipcf_ppp11_p75)
gen hh_p1090=(ipcf_ppp11>=ipcf_ppp11_p10 & ipcf_ppp11<=ipcf_ppp11_p90)
gen hh_p0595=(ipcf_ppp11>=ipcf_ppp11_p05 & ipcf_ppp11<=ipcf_ppp11_p95)

bys segment_id: egen ln_ipcf_ppp11_iqr = iqr(ln_ipcf_ppp11)
bys segment_id: egen ln_ipcf_ppp11_p50 = median(ln_ipcf_ppp11)

*Calculating IQR for additional variables
bys segment_id: egen itf_m_iqr = iqr(itf_m)
bys segment_id: egen ilpc_m_iqr = iqr(ilpc_m)
bys segment_id: egen inlpc_m_iqr = iqr(inlpc_m)
bys segment_id: egen itranext_m_iqr = iqr(itranext_m)
bys segment_id: egen agr_income_iqr = iqr(agr_income)
bys segment_id: egen iasalp_m_iqr = iqr(iasalp_m)
bys segment_id: egen ictapp_m_iqr = iqr(ictapp_m)
bys segment_id: egen ip_m_iqr = iqr(ip_m)
bys segment_id: egen wage_m_iqr = iqr(wage_m)

*Poverty count using pc income per day 
gen ipcf_ppp11_day=ipcf_ppp11/30 
gen poverty25=(ipcf_ppp11_day < 2.5) 
gen poverty4=(ipcf_ppp11_day < 4) 

*Collapsing at the segment lvl 
gen total_hh=1
collapse (sum) total_hh (mean) ln_ipcf_ppp11 ipcf_ppp11 ipcf_ppp11_iqr* ipcf_ppp11_p50 poverty25 poverty4 cooperative assistance ln_ipcf_ppp11_iqr ln_ipcf_ppp11_p50 ipcf_ppp11_pr9010 ipcf_ppp11_pr9505 ipcf_ppp11_pr7525 hh_p2575 hh_p1090 hh_p0595 itf_m_iqr ilpc_m_iqr inlpc_m_iqr itranext_m_iqr agr_income_iqr iasalp_m_iqr ictapp_m_iqr ip_m_iqr wage_m_iqr [aw=pondera], by(segment_id)

*Fixing segment var
ren segment_id segm_id
keep if length(segm_id)==8

save "${data}/temp\ephm_segm_lvl.dta", replace 





/*WEIRD RESULTS
use "${data}/ehpm\ehpm_2000_2017_mjsp.dta", clear 

*Fixing social assistance 
bys id: egen assistance=max(asistencia)
gen c=(emp_type_p==4)
bys id: egen cooperative=max(c)

*Calculating interquartile range within segments
bys segment_id: egen ipcf_ppp11_iqr = iqr(ipcf_ppp11)
bys segment_id: egen ipcf_ppp11_p50 = median(ipcf_ppp11)

*Poverty count using pc income per day 
gen ipcf_ppp11_day=ipcf_ppp11/30 
gen poverty25=(ipcf_ppp11_day < 2.5) 
gen poverty4=(ipcf_ppp11_day < 4) 

gen n=1 

*Collapsing at the household level
collapse (sum) n cooperative assistance poverty25 poverty4 (mean) ipcf_ppp11_iqr ipcf_ppp11_p50, by(segment_id)

gen cooperative_sh=cooperative/n
gen assistance_sh=assistance/n
gen poverty25_sh=poverty25/n
gen poverty4_sh=poverty4/n

*Fixing segment var
ren segment_id segm_id
keep if length(segm_id)==8

save "${data}/temp\ephm_segm_lvl.dta", replace 







