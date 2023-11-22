clear all

import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\documentation\CatalogoGeografico1992.xlsx", sheet("Table 1") firstrow clear

replace municipality="SAN JUAN OPICO" if municipality=="OPICO"
replace canton="AREA URBANA" if municipality==canton & codcanton==1

replace canton=subinstr(canton,"Ð","Ñ",.)

rename cod* =92

tostring cod*, replace 

replace codepto92="0"+codepto92 if length(codepto92)==1
replace codmuni92="0"+codmuni92 if length(codmuni92)==1
replace codcanton92="0"+codcanton92 if length(codcanton92)==1

gen id92=codepto92+codmuni92+codcanton92
destring id92, replace 

tempfile ID92
save `ID92', replace

import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\censo1992\1992pop\1992pop\documentation\cantonsID2007.xls", sheet("Cantons_From2007CensusSegments.") firstrow clear

ren _all, low
ren (depto cod_dep mpio cod_mun canton cod_can) (department codepto07 municipality codmuni07 canton codcanton07)

gen id07=codepto07+codmuni07+codcanton07
destring id07, replace 

reclink department municipality canton using `ID92', idm(id07) idu(id92) g(fmscore) req(department municipality) _merge(fmerge)

keep if fmscore>=0.9 & fmscore!=.

duplicates tag id07, g(dup)
tab dup
drop dup 

duplicates tag id92, g(dup)
tab dup
drop dup 

bys id92: egen maxfmscore=max(fmscore)
keep if fmscore==maxfmscore

isid id07
isid id92


*I loose 88 cantons... there is room to imporve this by hand picking and fixing.



*END