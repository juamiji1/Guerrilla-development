/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating survey outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

use "${data}/survey/SurveyAnalysis", clear

*Globals coming from main regression
gl h="2.266"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

*Getting age of participants 
gen year_birth=2022-p1
gen age_duringcontrol= 1992-year_birth
gen age_duringc_sqr=age_duringcontrol^2
 
gen sample_age=1 if age_duringcontrol<11
replace sample_age=0 if age_duringcontrol>=11

tab sample_age

gen within_dage=within_control*sample_age
gen within_cage=within_control*age_duringcontrol 

la var within_dage "Control $\times$ $\mathbb{I}[\text{Age in 1992} \leq 10]$"
la var within_cage "Control $\times$ Age in 1992$"

*-------------------------------------------------------------------------------
* 						      Results
*
*-------------------------------------------------------------------------------
* Table 1 out of 7:
global Dictator "p17a p17b p17c" 
global Community "likert_p20 p37_recode p38_recode p40"

*-------------------------------------------------------------------------------
* 							Estimation
*-------------------------------------------------------------------------------
eststo clear 

*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r`i': reghdfe `var' within_dage ${controls} likert_SD_Index sample_age [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	eststo s`i':reghdfe `var' within_cage ${controls} likert_SD_Index age_duringcontrol [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_sy`i'=round(r(mean), .001)
	
	local ++i

}

local i=1
foreach var of global Community {
	*Table
	eststo x`i': reghdfe `var' within_dage ${controls} likert_SD_Index sample_age [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy`i'=round(r(mean), .001)
	
	eststo y`i':reghdfe `var' within_cage ${controls} likert_SD_Index age_duringcontrol [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_yy`i'=round(r(mean), .001)
	
	local ++i

}

*-------------------------------------------------------------------------------
* Table 
*-------------------------------------------------------------------------------
*Exporting results dummy
esttab r1 r2 r3 using "${tables}/Table_survey_within_dage.tex", keep(within_control within_dage) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) replace ///
    prehead(`"\begin{tabular}{@{}l*{4}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `"\multicolumn{5}{l}{\textit{Panel A: Trust Towards In- and Out-groups. Dictator Game}} \\"' ///
            `"\midrule"' ///
            `" & Donation to Family & Donation to Family & Donation & \\"' ///
            `" & Inside the Community & Outside the Community & to Yourself &  \\"' ///
            `" & (0 - 1 Scale) & (0 - 1 Scale) & (0 - 1 Scale) &  \\"' ///
            `" & (1) & (2) & (3) & \\"' ///
            `"\midrule"') ///
    postfoot(`" Dependent mean & ${mean_ry1} & ${mean_ry2} & ${mean_ry3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"') 

esttab x1 x2 x3 x4 using "${tables}/Table_survey_within_dage.tex", keep(within_control within_dage) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Dependent mean & ${mean_xy1} & ${mean_xy2} & ${mean_xy3} & ${mean_xy4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')
			  
*Exporting results continuous
esttab s1 s2 s3 using "${tables}/Table_survey_within_cage.tex", keep(within_control within_cage) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) replace ///
    prehead(`"\begin{tabular}{@{}l*{4}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `"\multicolumn{5}{l}{\textit{Panel A: Trust Towards In- and Out-groups. Dictator Game}} \\"' ///
            `"\midrule"' ///
            `" & Donation to Family & Donation to Family & Donation & \\"' ///
            `" & Inside the Community & Outside the Community & to Yourself &  \\"' ///
            `" & (0 - 1 Scale) & (0 - 1 Scale) & (0 - 1 Scale) &  \\"' ///
            `" & (1) & (2) & (3) & \\"' ///
            `"\midrule"') ///
    postfoot(`" Dependent mean & ${mean_sy1} & ${mean_sy2} & ${mean_sy3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"') 

esttab y1 y2 y3 y4 using "${tables}/Table_survey_within_cage.tex", keep(within_control within_cage) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Dependent mean & ${mean_yy1} & ${mean_yy2} & ${mean_yy3} & ${mean_yy4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')

			    
	

	





*END


