/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Checking the census data
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development"
gl path "C:\Users\jmjimenez\Dropbox\Mica-projects\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\Mica-projects\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\Mica-projects\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}


*-------------------------------------------------------------------------------
*						Exploring the data 
*
*-------------------------------------------------------------------------------
use "${data}/ehpm\ehpm_2000_2017_mjsp.dta", clear 

d
	
tab year						// From 2000 to 2017

distinct department				// 14 deptos 		
distinct municipio				// 34 municipalities
distinct segment_id				// 5471 segments 

isid id indid year				// it seems this is the unique identifier 

gen n=1
tab year n

tabstat sex age casado asiste pric secc supc employment ocupado pea imeds money salary_main abroad abroad_total abroad_money_t if year==2013, s(N mean sd) save
tabstatmat A

mat A=A'
mat rown A="Sex (male=1)" "Age" "Married (yes=1)" "Asist (yes=1)" "Primary complete (yes=1)" "Secondary complete (yes=1)" "Superior complete (yes=1)" "Employed (yes=1)" "Occupied (yes=1)" "EAP (yes=1)" "Monthly income dependent" "Monthly income employment" "Salary (main)" "HH member abroad" "Total HH members abroad" "Total remittance" 

tempfile X
frmttable using `X', s(A) ctitle("Variable", "Obs.", "Mean", "Sd") sdec(0,3,3) tex fragment nocenter replace 
filefilter `X' "${tables}\summary_stats_ehpm.tex", from("r}\BS\BS") to("r}") replace





*END