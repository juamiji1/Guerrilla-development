*Preparing census tracts IDs
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

tempfile SegmID
save `SegmID', replace

*Comercial yields
import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA1S03") firstrow clear

*keeping only vars of interest 
rename _all, low

destring s03p07 s03p02 s03p20 s03p18 portid, replace

gen yield_maize=s03p07/s03p02
gen yield_bean=s03p20/s03p18

keep portid fb1p06a fb1p06b yield_*

tempfile YieldC
save `YieldC', replace

*Comercial yields
import excel "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\CENAGRO.xlsx", sheet("FA2S03") firstrow clear

*keeping only vars of interest 
rename _all, low

destring s03p04 s03p02 s03p15 s03p13 portid, replace

gen yield_maize=s03p04/s03p02
gen yield_bean=s03p15/s03p13

keep portid fb1p06a fb1p06b yield_*

*Appending comercial yields
append using `YieldC'
merge m:1 portid using `SegmID', keep(1 3)



