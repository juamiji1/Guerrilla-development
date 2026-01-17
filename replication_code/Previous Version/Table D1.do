use "$data/night_light_13_segm_lvl_onu_91_nowater", clear 

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

use "${data}/SurveyAnalysis", clear
recode S1 S2 S3 S4 (10731=1) (10732=0)

gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl if "if abs(z_run_cntrl)<=${h}"

* Table 1 out of 7:
global Educvars educ_years p1
global Dictator p17a p17b p17c 
global Community likert_p20 p37_recode p38_recode p40
global StateIndividual p44_recode p47_recode p46_recode
global LandSelling likert_p710 p83
global Reasons p51cat1 p51cat2 p51cat3 p51cat4 
global Occupation Ocuprin1 Ocuprin2 Ocuprin4 Ocuprin3 Ocuprin5
global Demographics p04 p1 p3 
global Desirability S1 S2 S3 S4



************************************************************************
* Desc stats:

* Table D1. covariates:
cap erase "${tables}\Table D1.tex"
cap erase "${tables}\Table D1.txt"


*Descriptives for the sample chosen 
tabstat $Educvars $Desirability $Dictator $Community $StateIndividual $LandSelling $Reasons $Occupation if within_control==1, s(mean N) save
tabstatmat A
mat A=A'

tabstat $Educvars $Desirability $Dictator $Community $StateIndividual $LandSelling $Occupation if within_control==0, s(mean N) save
tabstatmat B
mat B=B'

mat S=A,B


tempfile X
frmttable using `X', statmat(S) ctitle("", "Mean", "Obs", "Mean", "Obs") sdec(3,0,3,0) varlabels fragment tex nocenter replace  	
filefilter `X' "${tables}/Table D1.tex", from("{tabular}\BS\BS") to("{tabular}") replace
