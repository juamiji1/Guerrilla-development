/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Estimating survey outcomes
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Guerillas_Development"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\RESTUD Guerrillas Draft"
	gl do "C:\Github\Guerrilla-development\code"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\2-Data\Salvador"
gl maps "${localpath}\5-Maps\Salvador"
gl tables "${overleafpath}\tables"
gl plots "${overleafpath}\plots"

cd "${data}"

*Setting a pre-scheme for plots
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray
*-------------------------------------------------------------------------------
*	 						   Analysis
*
*-------------------------------------------------------------------------------
use "${data}/survey/SurveyAnalysis", clear

*Globals coming from main regression
gl h="2.266"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"
gl breakfe="control_break_fe_400"

*Getting age of participants 
gen year_birth=2022-p1
gen age_duringcontrol= 1992-year_birth
gen age_duringc_sqr=age_duringcontrol^2

gen sample_age0=1 if age_duringcontrol==0
replace sample_age0=0 if age_duringcontrol>0

gen sample_age5=1 if age_duringcontrol<6
replace sample_age5=0 if age_duringcontrol>=6

gen sample_age10=1 if age_duringcontrol<11
replace sample_age10=0 if age_duringcontrol>=11

gen sample_age15=1 if age_duringcontrol<16
replace sample_age15=0 if age_duringcontrol>=16

gen within_dage10=within_control*sample_age10
gen within_dage0=within_control*sample_age0
gen within_cage=within_control*age_duringcontrol 
gen within_dage5=within_control*sample_age5
gen within_dage15=within_control*sample_age15

la var within_dage10 "Control $\times$ $\mathbb{I}[\text{Age in 1992} \leq 10]$"
la var within_dage0 "Control $\times$ $\mathbb{I}[\text{Age in 1992}=0]$"
la var within_cage "Control $\times$ Age in 1992$"
la var within_dage5 "Control $\times$ $\mathbb{I}[\text{Age in 1992} \leq 5]$"
la var within_dage15 "Control $\times$ $\mathbb{I}[\text{Age in 1992} \leq 15]$"

*-------------------------------------------------------------------------------
* 						      Table 7 corrected
*
*-------------------------------------------------------------------------------
* Table 1 out of 7:
global Dictator "p17a p17b p17c" 
global Community "likert_p20 p37_recode p38_recode p40"

*-------------------------------------------------------------------------------
* 							Estimation with full FEs
*-------------------------------------------------------------------------------
eststo clear 

*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r`i': reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) abs(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	local ++i

}

local i=1
foreach var of global Community {
	*Table
	eststo x`i': reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) abs(i.${breakfe}) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy`i'=round(r(mean), .001)
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 using "${tables}/Table_7_breakfe400.tex", keep(within_control) ///
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

esttab x1 x2 x3 x4 using "${tables}/Table_7_breakfe400.tex", keep(within_control) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Dependent mean & ${mean_xy1} & ${mean_xy2} & ${mean_xy3} & ${mean_xy4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* 							Estimation with full FEs
*-------------------------------------------------------------------------------
gen breakfe40 = ceil(control_break_fe_400 / 10)

*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r`i': reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) abs(i.breakfe40) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	local ++i

}

local i=1
foreach var of global Community {
	*Table
	eststo x`i': reghdfe `var' ${controls} likert_SD_Index [aw=tweights] ${if}, vce(r) abs(i.breakfe40) 
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy`i'=round(r(mean), .001)
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 using "${tables}/Table_7_breakfe40.tex", keep(within_control) ///
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

esttab x1 x2 x3 x4 using "${tables}/Table_7_breakfe40.tex", keep(within_control) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Dependent mean & ${mean_xy1} & ${mean_xy2} & ${mean_xy3} & ${mean_xy4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')


*-------------------------------------------------------------------------------
* 						      Erosion of norms
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* 						Sample of people younger than 10 
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	lincom within_control+within_dage10
	gl joint_r`i' = string(r(estimate), "%9.4f")
	gl p_r`i'     = string(r(p),        "%9.3f")
	
	eststo s`i':reghdfe `var' within_cage ${controls} likert_SD_Index age_duringcontrol [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_sy`i'=round(r(mean), .001)
	
	local ++i

}

local i=1
foreach var of global Community {
	*Table
	eststo x`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy`i'=round(r(mean), .001)
		
	lincom within_control+within_dage10
	gl joint_x`i' = string(r(estimate), "%9.4f")
	gl p_x`i'     = string(r(p), "%9.3f")
	
	eststo y`i':reghdfe `var' within_cage ${controls} likert_SD_Index age_duringcontrol [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_yy`i'=round(r(mean), .001)
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 using "${tables}/Table_survey_within_dage10.tex", keep(within_control within_dage10) ///
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
    postfoot(`" Combined estimate & ${joint_r1} & ${joint_r2} & ${joint_r3} & \\"' ///
			  `" P-value (combined) & ${p_r1} & ${p_r2} & ${p_r3} & \\"' ///
			  `" Dependent mean & ${mean_ry1} & ${mean_ry2} & ${mean_ry3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"') 

esttab x1 x2 x3 x4 using "${tables}/Table_survey_within_dage10.tex", keep(within_control within_dage10) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_x1} & ${joint_x2} & ${joint_x3} &  ${joint_x4} \\"' ///
			`" P-value (combined) & ${p_x1} & ${p_x2} & ${p_x3} & ${p_x4} \\"' ///
			`" Dependent mean & ${mean_xy1} & ${mean_xy2} & ${mean_xy3} & ${mean_xy4} \\"' ///
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

*-------------------------------------------------------------------------------
* 					Sample of people younger than 5
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r`i': reghdfe `var' within_dage5 ${controls} likert_SD_Index sample_age5 [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	lincom within_control+within_dage5
	gl joint_r`i' = string(r(estimate), "%9.4f")
	gl p_r`i'     = string(r(p),        "%9.3f")

	local ++i
}

local i=1
foreach var of global Community {
	*Table
	eststo x`i': reghdfe `var' within_dage5 ${controls} likert_SD_Index sample_age5 [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy`i'=round(r(mean), .001)
		
	lincom within_control+within_dage5
	gl joint_x`i' = string(r(estimate), "%9.4f")
	gl p_x`i'     = string(r(p), "%9.3f")
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 using "${tables}/Table_survey_within_dage5.tex", keep(within_control within_dage5) ///
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
    postfoot(`" Combined estimate & ${joint_r1} & ${joint_r2} & ${joint_r3} & \\"' ///
			  `" P-value (combined) & ${p_r1} & ${p_r2} & ${p_r3} & \\"' ///
			  `" Dependent mean & ${mean_ry1} & ${mean_ry2} & ${mean_ry3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"') 

esttab x1 x2 x3 x4 using "${tables}/Table_survey_within_dage5.tex", keep(within_control within_dage5) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_x1} & ${joint_x2} & ${joint_x3} &  ${joint_x4} \\"' ///
			`" P-value (combined) & ${p_x1} & ${p_x2} & ${p_x3} & ${p_x4} \\"' ///
			`" Dependent mean & ${mean_xy1} & ${mean_xy2} & ${mean_xy3} & ${mean_xy4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* 					Sample of people younger than 15
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r`i': reghdfe `var' within_dage15 ${controls} likert_SD_Index sample_age15 [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry`i'=round(r(mean), .001)
	
	lincom within_control+within_dage15
	gl joint_r`i' = string(r(estimate), "%9.4f")
	gl p_r`i'     = string(r(p),        "%9.3f")

	local ++i
}

local i=1
foreach var of global Community {
	*Table
	eststo x`i': reghdfe `var' within_dage15 ${controls} likert_SD_Index sample_age15 [aw=tweights] ${if}, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy`i'=round(r(mean), .001)
		
	lincom within_control+within_dage15
	gl joint_x`i' = string(r(estimate), "%9.4f")
	gl p_x`i'     = string(r(p), "%9.3f")
	
	local ++i

}

*Exporting results dummy
esttab r1 r2 r3 using "${tables}/Table_survey_within_dage15.tex", keep(within_control within_dage15) ///
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
    postfoot(`" Combined estimate & ${joint_r1} & ${joint_r2} & ${joint_r3} & \\"' ///
			  `" P-value (combined) & ${p_r1} & ${p_r2} & ${p_r3} & \\"' ///
			  `" Dependent mean & ${mean_ry1} & ${mean_ry2} & ${mean_ry3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"') 

esttab x1 x2 x3 x4 using "${tables}/Table_survey_within_dage15.tex", keep(within_control within_dage15) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_x1} & ${joint_x2} & ${joint_x3} &  ${joint_x4} \\"' ///
			`" P-value (combined) & ${p_x1} & ${p_x2} & ${p_x3} & ${p_x4} \\"' ///
			`" Dependent mean & ${mean_xy1} & ${mean_xy2} & ${mean_xy3} & ${mean_xy4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')




*END


