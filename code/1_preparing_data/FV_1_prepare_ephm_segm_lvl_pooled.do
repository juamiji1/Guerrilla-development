/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: EHPM income spreads pooled across all rounds (2000-2017)
DATE:

NOTES: Alternative to FV_1_prepare_ephm_segm_lvl.do. Instead of keeping only
       each segment's latest survey round, this version keeps every round and
       computes within-segment-year income spreads, producing a segment-year
       panel (${data}/temp/ephm_segm_year_lvl.dta). Incomes are kept nominal
       (as surveyed); spreads are computed within each segment-round, so no
       observation mixes price levels internally.
       Winsorized versions clip households at the within-year p1/p99.
------------------------------------------------------------------------------*/

use segment_id id year pondera itf_m ilpc_m inlpc_m itranext_m agr_income iasalp_m ictapp_m ip_m wage_m using "${data}/ehpm\ehpm_2000_2017_mjsp.dta", clear

*Collapsing at the household level
collapse (max) pondera itf_m ilpc_m inlpc_m itranext_m agr_income iasalp_m ictapp_m ip_m wage_m, by(segment_id id year)

gl incomeout "itf_m ilpc_m inlpc_m itranext_m agr_income iasalp_m ictapp_m ip_m wage_m"

foreach var of global incomeout{

	*90-10 difference and 90/10 ratio within segment-year
	cap drop x y
	bys segment_id year: egen y = pctile(`var'), p(90)
	bys segment_id year: egen x = pctile(`var'), p(10)
	gen `var'_ipr = y - x
	gen `var'_rat9010 = y/x if x>0 & x!=.

	*Winsorizing households at the within-year p1/p99 before computing spreads
	cap drop p1w p99w
	bys year: egen p1w = pctile(`var'), p(1)
	bys year: egen p99w = pctile(`var'), p(99)
	gen `var'_w = min(max(`var', p1w), p99w) if `var'!=.

	cap drop x y
	bys segment_id year: egen y = pctile(`var'_w), p(90)
	bys segment_id year: egen x = pctile(`var'_w), p(10)
	gen `var'_iprw = y - x

	drop `var'_w p1w p99w
}

*Collapsing at the segment-year lvl
gen n_hh=1
collapse (sum) n_hh (mean) *_ipr *_iprw *_rat9010 [aw=pondera], by(segment_id year)

*Fixing segment var
ren segment_id segm_id
keep if length(segm_id)==8

save "${data}/temp\ephm_segm_year_lvl.dta", replace

*END
