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

merge m:1 segm_id using "$data/night_light_13_segm_lvl_onu_91_nowater", keep(1 3) keepus(mean_educ_years z_wi ) nogen 

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

summ mean_educ_years, d
gen d_educ_years=(mean_educ_years>=`r(p50)')
summ z_wi, d
gen d_z_wi=(z_wi>=`r(p50)')

*-------------------------------------------------------------------------------
* 						      Erosion of norms
*
*-------------------------------------------------------------------------------
* Table 1 out of 7:
global Dictator "p17a p17b p17c" 
global Community "likert_p20 p37_recode p38_recode p40"

*-------------------------------------------------------------------------------
* 						Sample of people younger than 10 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* d_z_wi == 1
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r1_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_z_wi==1, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry1_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_r1_`i' = string(r(estimate), "%9.4f")
	gl p_r1_`i'     = string(r(p),        "%9.3f")

	local ++i
}

local i=1
foreach var of global Community {
	*Table
	eststo x1_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_z_wi==1, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy1_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_x1_`i' = string(r(estimate), "%9.4f")
	gl p_x1_`i'     = string(r(p), "%9.3f")

	local ++i
}

*Exporting results: d_z_wi == 1
esttab r1_1 r1_2 r1_3 using "${tables}/Table_survey_within_dage10_wi1.tex", keep(within_control within_dage10) ///
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
    postfoot(`" Combined estimate & ${joint_r1_1} & ${joint_r1_2} & ${joint_r1_3} & \\"' ///
			  `" P-value (combined) & ${p_r1_1} & ${p_r1_2} & ${p_r1_3} & \\"' ///
			  `" Dependent mean & ${mean_ry1_1} & ${mean_ry1_2} & ${mean_ry1_3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"')

esttab x1_1 x1_2 x1_3 x1_4 using "${tables}/Table_survey_within_dage10_wi1.tex", keep(within_control within_dage10) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_x1_1} & ${joint_x1_2} & ${joint_x1_3} &  ${joint_x1_4} \\"' ///
			`" P-value (combined) & ${p_x1_1} & ${p_x1_2} & ${p_x1_3} & ${p_x1_4} \\"' ///
			`" Dependent mean & ${mean_xy1_1} & ${mean_xy1_2} & ${mean_xy1_3} & ${mean_xy1_4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* d_z_wi == 0
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo r0_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_z_wi==0, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_ry0_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_r0_`i' = string(r(estimate), "%9.4f")
	gl p_r0_`i'     = string(r(p),        "%9.3f")

	local ++i
}

local i=1
foreach var of global Community {
	*Table
	eststo x0_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_z_wi==0, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xy0_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_x0_`i' = string(r(estimate), "%9.4f")
	gl p_x0_`i'     = string(r(p), "%9.3f")

	local ++i
}

*Exporting results: d_z_wi == 0
esttab r0_1 r0_2 r0_3 using "${tables}/Table_survey_within_dage10_wi0.tex", keep(within_control within_dage10) ///
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
    postfoot(`" Combined estimate & ${joint_r0_1} & ${joint_r0_2} & ${joint_r0_3} & \\"' ///
			  `" P-value (combined) & ${p_r0_1} & ${p_r0_2} & ${p_r0_3} & \\"' ///
			  `" Dependent mean & ${mean_ry0_1} & ${mean_ry0_2} & ${mean_ry0_3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"')

esttab x0_1 x0_2 x0_3 x0_4 using "${tables}/Table_survey_within_dage10_wi0.tex", keep(within_control within_dage10) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_x0_1} & ${joint_x0_2} & ${joint_x0_3} &  ${joint_x0_4} \\"' ///
			`" P-value (combined) & ${p_x0_1} & ${p_x0_2} & ${p_x0_3} & ${p_x0_4} \\"' ///
			`" Dependent mean & ${mean_xy0_1} & ${mean_xy0_2} & ${mean_xy0_3} & ${mean_xy0_4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* d_educ_years == 1
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo re1_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_educ_years==1, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_rye1_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_re1_`i' = string(r(estimate), "%9.4f")
	gl p_re1_`i'     = string(r(p),        "%9.3f")

	local ++i
}

local i=1
foreach var of global Community {
	*Table
	eststo xe1_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_educ_years==1, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xye1_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_xe1_`i' = string(r(estimate), "%9.4f")
	gl p_xe1_`i'     = string(r(p), "%9.3f")

	local ++i
}

*Exporting results: d_educ_years == 1
esttab re1_1 re1_2 re1_3 using "${tables}/Table_survey_within_dage10_educ1.tex", keep(within_control within_dage10) ///
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
    postfoot(`" Combined estimate & ${joint_re1_1} & ${joint_re1_2} & ${joint_re1_3} & \\"' ///
			  `" P-value (combined) & ${p_re1_1} & ${p_re1_2} & ${p_re1_3} & \\"' ///
			  `" Dependent mean & ${mean_rye1_1} & ${mean_rye1_2} & ${mean_rye1_3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"')

esttab xe1_1 xe1_2 xe1_3 xe1_4 using "${tables}/Table_survey_within_dage10_educ1.tex", keep(within_control within_dage10) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_xe1_1} & ${joint_xe1_2} & ${joint_xe1_3} &  ${joint_xe1_4} \\"' ///
			`" P-value (combined) & ${p_xe1_1} & ${p_xe1_2} & ${p_xe1_3} & ${p_xe1_4} \\"' ///
			`" Dependent mean & ${mean_xye1_1} & ${mean_xye1_2} & ${mean_xye1_3} & ${mean_xye1_4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* d_educ_years == 0
*-------------------------------------------------------------------------------
*Results
local i=1
foreach var of global Dictator {
	*Table
	eststo re0_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_educ_years==0, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_rye0_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_re0_`i' = string(r(estimate), "%9.4f")
	gl p_re0_`i'     = string(r(p),        "%9.3f")

	local ++i
}

local i=1
foreach var of global Community {
	*Table
	eststo xe0_`i': reghdfe `var' within_dage10 ${controls} likert_SD_Index sample_age10 [aw=tweights] ${if} & d_educ_years==0, vce(r) noabs resid keepsing
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_xye0_`i'=round(r(mean), .001)

	lincom within_control+within_dage10
	gl joint_xe0_`i' = string(r(estimate), "%9.4f")
	gl p_xe0_`i'     = string(r(p), "%9.3f")

	local ++i
}

*Exporting results: d_educ_years == 0
esttab re0_1 re0_2 re0_3 using "${tables}/Table_survey_within_dage10_educ0.tex", keep(within_control within_dage10) ///
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
    postfoot(`" Combined estimate & ${joint_re0_1} & ${joint_re0_2} & ${joint_re0_3} & \\"' ///
			  `" P-value (combined) & ${p_re0_1} & ${p_re0_2} & ${p_re0_3} & \\"' ///
			  `" Dependent mean & ${mean_rye0_1} & ${mean_rye0_2} & ${mean_rye0_3} & \\"' ///
              `"\toprule"' ///
              `"\multicolumn{5}{l}{\textit{Panel B: Community Engagement}} \\"' ///
              `"\midrule"' ///
              `" & Interaction with & Member of Civil & Presence of & Frequency Local \\"' ///
              `" & Community & Society & Local Development & Development Council \\"' ///
              `" & (Likert Scale) & Organization & Council & Meeting \\"' ///
              `" & (4) & (5) & (6) & (7) \\"' ///
              `"\midrule"')

esttab xe0_1 xe0_2 xe0_3 xe0_4 using "${tables}/Table_survey_within_dage10_educ0.tex", keep(within_control within_dage10) ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) ///
    booktabs b(4) append ///
    postfoot(`" Combined estimate & ${joint_xe0_1} & ${joint_xe0_2} & ${joint_xe0_3} &  ${joint_xe0_4} \\"' ///
			`" P-value (combined) & ${p_xe0_1} & ${p_xe0_2} & ${p_xe0_3} & ${p_xe0_4} \\"' ///
			`" Dependent mean & ${mean_xye0_1} & ${mean_xye0_2} & ${mean_xye0_3} & ${mean_xye0_4} \\"' ///
			`"\midrule"' ///
            `"Bandwidth (Km) & ${h} & ${h} & ${h} & ${h} \\"' ///
            `"\bottomrule \end{tabular}"')




