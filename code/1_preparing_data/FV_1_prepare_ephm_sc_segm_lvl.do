*Preparing EHPM outcomes
*r004 depto 
*r005 muni 
*r006 canton 
*segmento 

forval y=11/18{

	import delimited "${data}\ehpm\ehpm`y'.csv", encoding(UTF-8) clear

	tostring r004 r005 r006 segmento, replace
	
	if `y'==15{
		replace r004="0"+r004 if length(r004)==1
		replace r005="0"+r005 if length(r005)==3
		replace r006="0"+r006 if length(r006)==5
		replace segmento="0"+segmento if length(segmento)==3
		replace segmento="00"+segmento if length(segmento)==2
		replace segmento="000"+segmento if length(segmento)==1
		gen segm_id=r005+segmento
	}
	else{
		replace r004="0"+r004 if length(r004)==1
		replace r005="0"+r005 if length(r005)==1
		replace r005=r004+r005 
		replace segmento="0"+segmento if length(segmento)==3
		replace segmento="00"+segmento if length(segmento)==2
		replace segmento="000"+segmento if length(segmento)==1
		gen segm_id=r005+segmento	
	}

	*Credits
	gen credit_friend=(r509=="9") if r509!="NA"
	gen credit_coop=(r509=="6") if r509!="NA"
	gen credit_formal=(r509=="1" | r509=="2" | r509=="3" | r509=="4") if r509!="NA"

	*Part of organization 
	cap gen member_coop=(r445b1=="1") if r445b1!="NA"
	cap gen member_union=(r445b2=="1") if r445b2!="NA"
	cap gen member_gremio=(r445b3=="1") if r445b3!="NA"
	cap gen member_profesion=(r445b4=="1") if r445b4!="NA"

	*Type of relation with land 
	gen land_prop=(r503a=="1") if r503a!="NA"
	gen land_rent=(r503a=="2") if r503a!="NA"
	gen land_colono=(r503a=="3") if r503a!="NA"
	gen land_aparcero=(r503a=="4") if r503a!="NA"
	gen land_ocupante=(r503a=="5") if r503a!="NA"

	gen land_prop_safe=(r5031=="1") if r5031!="NA"
	gen land_prop_claim=(r5033=="3" | r5033otr=="3") if r503a!="NA" & r5033otr!="NA" 
	
	*Medical insurance 
	cap gen noins_health=(r108a=="8") if r108a!="NA"	
	cap gen noins_health=(r108a==8) if r108a!=.	
	
	*Pobreza 
	tab pobreza, g(pobreza_ehpm_)
	
	gen year=20`y'

	cap collapse (mean) credit_* member_* land_* pobreza_ehpm_*, by(segm_id year)
	cap collapse (mean) credit_* land_* pobreza_ehpm_*, by(segm_id year)

	tempfile EHPM20`y'
	save `EHPM20`y''
}

use `EHPM2011', clear
append using `EHPM2012' `EHPM2013' `EHPM2014' `EHPM2015' `EHPM2016' `EHPM2017' `EHPM2018'

duplicates tag segm_id, g(dup)
tab year dup

*keeping unique in 2015 and 2016 for better comparison (less time-gap)
bys segm_id: egen max_y=max(year)
keep if year==max_y
drop year max_y

isid segm_id

*Saving the dataset
save "${data}\ehpm\ehpm_social_cap.dta", replace



import delimited "${data}\ehpm\ehpm17.csv", encoding(UTF-8) clear




*END