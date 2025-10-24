use "${data}/survey/SurveyAnalysis", clear

gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

* Table 1 out of 7:
global Dictator p17a p17b p17c 
global Community likert_p20 p37_recode p38_recode p40


local r replace
foreach var of global Community {
	*Table
	reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/Table 6a.tex", nor2 tex(frag) keep(within_control) addstat("Bandwidth (Km)", ${h}, "Dependent mean", ${mean_y}) label nonote nocons `r'
	local r append 
}

preserve 
 insheet using "${tables}/Table 6a.txt", nonames clear
 drop v2

drop in 2
insobs 3, before(1)
replace v3 = "Interaction with" in 1
replace v3 = "Community" in 2
replace v3 = "(Likert Scale)" in 3
replace v4 = "Member of Civil" in 1
replace v4 = "Society Organization" in 2
replace v5 = "Presence of " in 1
replace v5 = "Development Council" in 2
replace v6 = "Attends Development " in 1
replace v6 = "Council Meeting" in 2
replace v1 = "Guerrilla control" in 6
replace v3 = "(4)" in 4
replace v4 = "(5)" in 4
replace v5 = "(6)" in 4
replace v6 = "(7)" in 4

save "${tables}/Table 6a" , replace 

restore 



local r replace
foreach var of global Dictator {
	*Table
	reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) noabs resid keepsing
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}/Table 6.tex", nor2 tex(frag) keep(within_control) addstat( "Dependent mean", ${mean_y}) label nonote nocons `r'
	local r append 
}

preserve

insheet using "${tables}/Table 6.txt", nonames clear

replace v2 = "" in 2
replace v2 = "" in 4
replace v1 = "" in 2
drop in 2
insobs 4, before(1)
replace v1 = "Panel A: Trust Towards In- and Out-groups. Dictator Game" in 1
replace v1 = "Guerrilla control" in 7
replace v3 = "Donation to Family " in 2
replace v3 = "Inside the Community" in 3
replace v3 = "(0 - 1 Scale)" in 4
replace v4 = "(0 - 1 Scale)" in 4
replace v5 = "(0 - 1 Scale)" in 4
replace v4 = "Outside the Community" in 3
replace v5 = "Donation " in 2
replace v5 = "to Yourself" in 3

rename (v2 v3 v4 v5) (v3 v4 v5 v6)

append using "${tables}/Table 6a"
 
insobs 1, before(13)
replace v1 = "Panel B: Community Engagement" in 13
replace v1 = "Guerrilla control" in 19

local Pen=_N-1
gen n=_n 
replace n=90000 in `Pen'
sort n 
drop n
dataout, tex save("${tables}/Dictator_and_Engagement") replace nohead  midborder(3)

restore 


cap erase "${tables}/Table 6a.tex"
cap erase "${tables}/Table 6a.txt"
cap erase "${tables}/Table 6a.dta"

