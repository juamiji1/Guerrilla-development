/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Cooperativism using the CENAGRO
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Guerillas_Development"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\GD-draft-slv"
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
*Preparing the data at the producer level 
* 
*-------------------------------------------------------------------------------
*MORE BREAKS
use "${data}/temp\slvShp_segm_brks.dta", clear
ren (SEG_ID cntrl50 cntr100 cntr200) (segm_id control_break_fe_50 control_break_fe_100 control_break_fe_200)
keep segm_id control_break_fe_*

tempfile Bks
save `Bks', replace 

*Preparing census tracts IDs
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

tempfile SegmID
save `SegmID', replace 

import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA2SM.txt", clear 

*Institucion que da asistencia tecnica 
gen s08p02c1= 1 if mid==149 & seccid==8
gen s08p02c2= 1 if mid==150 & seccid==8
gen s08p02c3= 1 if mid==151 & seccid==8
gen s08p02c4= 1 if mid==152 & seccid==8
gen s08p02c5= 1 if mid==153 & seccid==8
gen s08p02c6= 1 if mid==154 & seccid==8
gen s08p02c7= 1 if mid==155 & seccid==8

*Forma de la asistencia tecnica 
gen s08p03c1= 1 if mid==156 & seccid==8
gen s08p03c2= 1 if mid==157 & seccid==8
gen s08p03c3= 1 if mid==158 & seccid==8

*Institucion que da el credito 
gen s09p02c1= 1 if mid==159 & seccid==9
gen s09p02c2= 1 if mid==160 & seccid==9
gen s09p02c3= 1 if mid==161 & seccid==9
gen s09p02c4= 1 if mid==162 & seccid==9
gen s09p02c5= 1 if mid==163 & seccid==9
gen s09p02c6= 1 if mid==164 & seccid==9

*Credito aprobado o no 
gen s09p02r=m01 if seccid==9

*Forma de comercializacion (cooperatives are really few)
gen s11p01c1=1 if m01==1 & seccid==11
gen s11p01c2=1 if m02==1 & seccid==11
gen s11p01c3=1 if m03==1 & seccid==11
gen s11p01c4=1 if m04==1 & seccid==11

collapse s08p02* s09p02* s11p01*, by(portid fb1p06a fb1p06b)

tempfile Secc89
save `Secc89', replace 

*Importing info on subsistence producers
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA2.csv", clear

merge 1:1 portid fb1p06a fb1p06b using `Secc89', nogen 

*Merging the census tracts Ids 
merge m:1 portid using `SegmID', keep(1 3) nogen 

*Fixing the cooperatives values 
{
gen s01p05p=s01p05
replace s01p05p=28 if s01p05==9928
replace s01p05p=29 if s01p05==9929
replace s01p05p=30 if s01p05==3001
replace s01p05p=30 if s01p05==3002
replace s01p05p=30 if s01p05==3003
replace s01p05p=30 if s01p05==3004
replace s01p05p=30 if s01p05==3005
replace s01p05p=30 if s01p05==3006
replace s01p05p=30 if s01p05==3007
replace s01p05p=30 if s01p05==3008
replace s01p05p=30 if s01p05==3009
replace s01p05p=30 if s01p05==3010
replace s01p05p=30 if s01p05==3011
replace s01p05p=31 if s01p05==31001
replace s01p05p=31 if s01p05==31005
replace s01p05p=31 if s01p05==31014
replace s01p05p=31 if s01p05==31018
replace s01p05p=31 if s01p05==31019
replace s01p05p=31 if s01p05==31047
replace s01p05p=31 if s01p05==31068
replace s01p05p=31 if s01p05==31069
replace s01p05p=31 if s01p05==31070
replace s01p05p=31 if s01p05==31084
replace s01p05p=31 if s01p05==31105
replace s01p05p=31 if s01p05==31117
replace s01p05p=31 if s01p05==31121
replace s01p05p=31 if s01p05==31122
replace s01p05p=31 if s01p05==31133
replace s01p05p=31 if s01p05==31134
replace s01p05p=31 if s01p05==31140
replace s01p05p=31 if s01p05==31143
replace s01p05p=31 if s01p05==31145
replace s01p05p=31 if s01p05==31153
replace s01p05p=32 if s01p05==32153
replace s01p05p=31 if s01p05==31158
replace s01p05p=31 if s01p05==31180
replace s01p05p=31 if s01p05==31182
replace s01p05p=31 if s01p05==31190
replace s01p05p=31 if s01p05==31194
replace s01p05p=31 if s01p05==31197
replace s01p05p=31 if s01p05==31205
replace s01p05p=31 if s01p05==31211
replace s01p05p=31 if s01p05==31213
replace s01p05p=31 if s01p05==31215
replace s01p05p=31 if s01p05==31220
replace s01p05p=31 if s01p05==31223
replace s01p05p=31 if s01p05==31228
replace s01p05p=31 if s01p05==31236
replace s01p05p=31 if s01p05==31238
replace s01p05p=31 if s01p05==31239
replace s01p05p=31 if s01p05==31240
replace s01p05p=31 if s01p05==31242
replace s01p05p=31 if s01p05==31244
replace s01p05p=31 if s01p05==31245
replace s01p05p=31 if s01p05==31250
replace s01p05p=31 if s01p05==31256
replace s01p05p=31 if s01p05==31260
replace s01p05p=31 if s01p05==31265
replace s01p05p=31 if s01p05==31266
replace s01p05p=31 if s01p05==31267
replace s01p05p=31 if s01p05==31271
replace s01p05p=31 if s01p05==31272
replace s01p05p=31 if s01p05==31275
replace s01p05p=31 if s01p05==31276
replace s01p05p=31 if s01p05==31278
replace s01p05p=31 if s01p05==31281
replace s01p05p=31 if s01p05==31283
replace s01p05p=31 if s01p05==31287
replace s01p05p=31 if s01p05==31297
replace s01p05p=31 if s01p05==31298
replace s01p05p=31 if s01p05==31300
replace s01p05p=31 if s01p05==31303
replace s01p05p=31 if s01p05==31305
replace s01p05p=31 if s01p05==31306
replace s01p05p=31 if s01p05==31308
replace s01p05p=31 if s01p05==31309
replace s01p05p=31 if s01p05==31310
replace s01p05p=31 if s01p05==31314
replace s01p05p=31 if s01p05==31317
replace s01p05p=31 if s01p05==31318
replace s01p05p=31 if s01p05==31319
replace s01p05p=31 if s01p05==31330
replace s01p05p=31 if s01p05==31334
replace s01p05p=31 if s01p05==31339
replace s01p05p=31 if s01p05==31340
replace s01p05p=31 if s01p05==31344
replace s01p05p=31 if s01p05==31347
replace s01p05p=31 if s01p05==31358
replace s01p05p=32 if s01p05==32363
replace s01p05p=31 if s01p05==31365
replace s01p05p=31 if s01p05==31371
replace s01p05p=31 if s01p05==31372
replace s01p05p=31 if s01p05==31373
replace s01p05p=31 if s01p05==31375
replace s01p05p=31 if s01p05==31385
replace s01p05p=31 if s01p05==31389
replace s01p05p=31 if s01p05==31391
replace s01p05p=31 if s01p05==31392
replace s01p05p=31 if s01p05==31396
replace s01p05p=31 if s01p05==31397
replace s01p05p=31 if s01p05==31405
replace s01p05p=31 if s01p05==31412
replace s01p05p=32 if s01p05==32412
replace s01p05p=31 if s01p05==31414
replace s01p05p=31 if s01p05==31418
replace s01p05p=31 if s01p05==31436
replace s01p05p=31 if s01p05==31444
replace s01p05p=31 if s01p05==31445
replace s01p05p=31 if s01p05==31446
replace s01p05p=31 if s01p05==31460
replace s01p05p=31 if s01p05==31464
replace s01p05p=32 if s01p05==32471
replace s01p05p=31 if s01p05==31474
replace s01p05p=31 if s01p05==31475
replace s01p05p=31 if s01p05==31476
replace s01p05p=31 if s01p05==31477
replace s01p05p=32 if s01p05==32478
replace s01p05p=31 if s01p05==31479
replace s01p05p=32 if s01p05==32479
replace s01p05p=31 if s01p05==31480
replace s01p05p=31 if s01p05==31481
replace s01p05p=31 if s01p05==31482
replace s01p05p=31 if s01p05==31483
replace s01p05p=31 if s01p05==31484
replace s01p05p=31 if s01p05==31485
replace s01p05p=31 if s01p05==31486
replace s01p05p=31 if s01p05==31487
replace s01p05p=31 if s01p05==31488
replace s01p05p=31 if s01p05==31489
replace s01p05p=31 if s01p05==31490
replace s01p05p=32 if s01p05==32490
replace s01p05p=32 if s01p05==32491
replace s01p05p=31 if s01p05==31492
replace s01p05p=31 if s01p05==31493
replace s01p05p=32 if s01p05==32494
replace s01p05p=31 if s01p05==31495
replace s01p05p=31 if s01p05==31496
replace s01p05p=31 if s01p05==31497
replace s01p05p=31 if s01p05==31498
replace s01p05p=31 if s01p05==31499
replace s01p05p=31 if s01p05==31500
replace s01p05p=32 if s01p05==32501
replace s01p05p=32 if s01p05==32502
replace s01p05p=32 if s01p05==32503
replace s01p05p=31 if s01p05==31504
replace s01p05p=32 if s01p05==32505
replace s01p05p=31 if s01p05==31506
replace s01p05p=31 if s01p05==31507
replace s01p05p=31 if s01p05==31508
replace s01p05p=31 if s01p05==31509
replace s01p05p=31 if s01p05==31510
replace s01p05p=31 if s01p05==31511
replace s01p05p=31 if s01p05==31512
replace s01p05p=31 if s01p05==31513
replace s01p05p=32 if s01p05==32513
replace s01p05p=31 if s01p05==31514
replace s01p05p=31 if s01p05==31515
replace s01p05p=31 if s01p05==31516
replace s01p05p=31 if s01p05==31517
replace s01p05p=31 if s01p05==31518
replace s01p05p=31 if s01p05==31519
replace s01p05p=31 if s01p05==31520
replace s01p05p=31 if s01p05==31521
replace s01p05p=31 if s01p05==31522
replace s01p05p=31 if s01p05==31523
replace s01p05p=31 if s01p05==31524
replace s01p05p=31 if s01p05==31525
replace s01p05p=31 if s01p05==31526
replace s01p05p=31 if s01p05==31527
replace s01p05p=31 if s01p05==31528
replace s01p05p=31 if s01p05==31529
replace s01p05p=31 if s01p05==31530
replace s01p05p=31 if s01p05==31531
replace s01p05p=31 if s01p05==31532
replace s01p05p=31 if s01p05==31533
replace s01p05p=31 if s01p05==31534
replace s01p05p=31 if s01p05==31535
replace s01p05p=31 if s01p05==31536
replace s01p05p=31 if s01p05==31537
replace s01p05p=31 if s01p05==31538
replace s01p05p=31 if s01p05==31539
replace s01p05p=31 if s01p05==31540
replace s01p05p=31 if s01p05==31541
replace s01p05p=31 if s01p05==31542
replace s01p05p=31 if s01p05==31543
replace s01p05p=31 if s01p05==31544
replace s01p05p=31 if s01p05==31545
replace s01p05p=31 if s01p05==31546
replace s01p05p=31 if s01p05==31547
replace s01p05p=31 if s01p05==31548
replace s01p05p=31 if s01p05==31549
replace s01p05p=31 if s01p05==31550
replace s01p05p=31 if s01p05==31551
replace s01p05p=31 if s01p05==31552
replace s01p05p=31 if s01p05==31553
replace s01p05p=31 if s01p05==31554
replace s01p05p=31 if s01p05==31555
replace s01p05p=31 if s01p05==31556
replace s01p05p=31 if s01p05==31557
replace s01p05p=31 if s01p05==31558
replace s01p05p=31 if s01p05==31559
replace s01p05p=31 if s01p05==31560
replace s01p05p=31 if s01p05==31561
replace s01p05p=31 if s01p05==31562
replace s01p05p=31 if s01p05==31563
replace s01p05p=31 if s01p05==31564
replace s01p05p=31 if s01p05==31565
replace s01p05p=31 if s01p05==31566
replace s01p05p=31 if s01p05==31567
replace s01p05p=31 if s01p05==31568
replace s01p05p=31 if s01p05==31569
replace s01p05p=31 if s01p05==31570
replace s01p05p=31 if s01p05==31571
replace s01p05p=31 if s01p05==31572
replace s01p05p=31 if s01p05==31573
replace s01p05p=32 if s01p05==32573
replace s01p05p=31 if s01p05==31574
replace s01p05p=31 if s01p05==31575
replace s01p05p=31 if s01p05==31576
replace s01p05p=31 if s01p05==31577
replace s01p05p=32 if s01p05==32577
replace s01p05p=31 if s01p05==31578
replace s01p05p=31 if s01p05==31579
replace s01p05p=31 if s01p05==31580
replace s01p05p=31 if s01p05==31581
replace s01p05p=31 if s01p05==31582
replace s01p05p=31 if s01p05==31583
replace s01p05p=31 if s01p05==31584
replace s01p05p=32 if s01p05==32585
replace s01p05p=32 if s01p05==32586
replace s01p05p=32 if s01p05==32587
replace s01p05p=32 if s01p05==32588
replace s01p05p=32 if s01p05==32589
replace s01p05p=32 if s01p05==32590
replace s01p05p=31 if s01p05==31591
replace s01p05p=31 if s01p05==31592
replace s01p05p=31 if s01p05==31593
replace s01p05p=32 if s01p05==32594
replace s01p05p=31 if s01p05==31595
replace s01p05p=31 if s01p05==31596
replace s01p05p=32 if s01p05==32597
replace s01p05p=31 if s01p05==31598
replace s01p05p=31 if s01p05==31599
replace s01p05p=32 if s01p05==32600
replace s01p05p=31 if s01p05==31601
replace s01p05p=32 if s01p05==32602
replace s01p05p=31 if s01p05==31604
replace s01p05p=31 if s01p05==31605
replace s01p05p=31 if s01p05==31606
replace s01p05p=32 if s01p05==32606
replace s01p05p=32 if s01p05==32621
}

*Individual belongs to cooperative
gen ind_coop=(s01p05p==31)
gen ind_asoc=(s01p05p>28)

*Asistencia tecnica 
tab s08p01
gen asist_tec_coop= 1 if s08p02c4==1 & s08p01==1
replace asist_tec_coop=0 if asist_tec_coop==. & s08p01==1

gen asist_tec_asoc= 1 if (s08p02c4==1 | s08p02c5==1) & s08p01==1
replace asist_tec_asoc= 0 if asist_tec_asoc==. & s08p01==1

*Credito 
tab s09p01
gen credit_coop= 1 if s09p02c3==1 & s09p01==1
replace credit_coop=0 if credit_coop==. & s09p01==1

gen credit_loc= 1 if s09p02c6==1 & s09p01==1
replace credit_loc=0 if credit_loc==. & s09p01==1

gen credit_bank= 1 if s09p02c1==1 & s09p01==1
replace credit_bank=0 if credit_bank==. & s09p01==1

*Comercializacion
gen comer_coop= 1 if s11p01c1==1 
replace comer_coop=0 if comer_coop==. & (s11p01c2==1 | s11p01c2==1 | s11p01c3==1 | s11p01c4==1)


*Subsistence indicator 
gen subsistence=1

*keeping only vars of interest 
keep segm_id portid fb1p06a fb1p06b ind_* asist_tec_* credit_* comer_* subsistence

tempfile ProdS
save `ProdS', replace




import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1SM.txt", clear 

*Institucion que da asistencia tecnica 
gen s17p02c1= 1 if mid==620 & seccid==17
gen s17p02c2= 1 if mid==621 & seccid==17
gen s17p02c3= 1 if mid==622 & seccid==17
gen s17p02c4= 1 if mid==623 & seccid==17
gen s17p02c5= 1 if mid==624 & seccid==17
gen s17p02c6= 1 if mid==625 & seccid==17
gen s17p02c7= 1 if mid==626 & seccid==17

*Institucion que da el credito 
gen s18p02c1= 1 if mid==630 & seccid==18
gen s18p02c2= 1 if mid==631 & seccid==18
gen s18p02c3= 1 if mid==632 & seccid==18
gen s18p02c4= 1 if mid==633 & seccid==18
gen s18p02c5= 1 if mid==634 & seccid==18
gen s18p02c6= 1 if mid==635 & seccid==18

*Credito aprobado o no 
gen s09p02r=m01 if seccid==9

*Forma de comercializacion 
gen s20p01c1=1 if m01==1 & seccid==20
gen s20p01c2=1 if m02==1 & seccid==20
gen s20p01c3=1 if m03==1 & seccid==20
gen s20p01c4=1 if m04==1 & seccid==20
gen s20p01c5=1 if m05==1 & seccid==20

collapse s17p02* s18p02* s20p01*, by(portid fb1p06a fb1p06b)

tempfile Secc1720
save `Secc1720', replace 

*Importing info on comercial producers
import delimited "C:\Users\juami\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1.csv", clear

*Merging the census tracts Ids 
merge 1:1 portid fb1p06a fb1p06b using `Secc1720', nogen 
merge m:1 portid using `SegmID', keep(1 3) nogen 

tab s01p06 s01p05

*Fixing vars 
replace s01p06=9941 if s01p06==4101
replace s01p06=9941 if s01p06==4102
replace s01p06=9941 if s01p06==4103
replace s01p06=9941 if s01p06==4104
replace s01p06=9941 if s01p06==4105

replace s01p06=s01p06-9900

tab s01p06 s01p05

*Number of cooperatives 
gen coop=(s01p06==36) if s01p05==35

keep if s01p05==34

*Individual belongs to ccoperative
gen ind_coop=s01p09
replace ind_coop=. if ind_coop==-2
replace ind_coop=1 if ind_coop>0 & ind_coop!=.

tab ind_coop s01p05, m


*Asistencia tecnica 
tab s17p01
gen asist_tec_coop= 1 if s17p02c4==1 & s17p01==1
replace asist_tec_coop=0 if asist_tec_coop==. & s17p01==1

gen asist_tec_asoc= 1 if (s17p02c4==1 | s17p02c5==1) & s17p01==1
replace asist_tec_asoc= 0 if asist_tec_asoc==. & s17p01==1

*Credito 
tab s18p01
gen credit_coop= 1 if s18p02c3==1 & s18p01==1
replace credit_coop=0 if credit_coop==. & s18p01==1

gen credit_loc= 1 if s18p02c6==1 & s18p01==1
replace credit_loc=0 if credit_loc==. & s18p01==1

gen credit_bank= 1 if s18p02c1==1 & s18p01==1
replace credit_bank=0 if credit_bank==. & s18p01==1

*Comercializacion
gen comer_coop= 1 if s20p01c1==1 
replace comer_coop=0 if comer_coop==. & (s20p01c2==1 | s20p01c3==1 | s20p01c4==1 | s20p01c5==1)


*Subsistence indicator 
gen subsistence=0

*keeping only vars of interest 
keep segm_id portid fb1p06a fb1p06b ind_* asist_tec_* credit_* comer_* subsistence

*Adding subsitence producers
append using `ProdS'

*-------------------------------------------------------------------------------
* REGRESSIONS AT THE INDIVIDUAL LEVEL
*-------------------------------------------------------------------------------
merge m:1 segm_id using "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", keep(1 3) keepus(control_break_fe_400 within_control z_run_cntrl) gen(wmerge)

gl depvars "ind_asoc credit_coop credit_bank comer_coop"

label var within_control "Guerrilla control"

*Erasing table before exporting
cap erase "${tables}\rdd_main_agro_ind.tex"
cap erase "${tables}\rdd_main_agro_ind.txt"
cap erase "${tables}\rdd_main_agro_ind_cl.tex"
cap erase "${tables}\rdd_main_agro_ind_cl.txt"

*Global of border FE for all estimates
gl breakfe "control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

foreach var of global depvars {

	*RDD with break fe and triangular weights 
	rdrobust `var' z_run_cntrl, all kernel(triangular) 
	gl h=e(h_l)
	gl h=2.271
	gl b=e(b_l)

	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}\rdd_main_agro_ind.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(cl segm_id) a(i.${breakfe}) 
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}\rdd_main_agro_ind_cl.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}

*-------------------------------------------------------------------------------
* REGRESSIONS AT THE SEGMENT LEVEL
*-------------------------------------------------------------------------------
gen n_ind_asoc=1 if ind_asoc!=.
gen n_credit_coop=1 if credit_coop!=.
gen n_credit_bank=1 if credit_bank!=.
gen n_comer_coop=1 if comer_coop!=.

collapse (sum) n_ind_asoc n_credit_coop n_credit_bank n_comer_coop (mean) ind_asoc credit_coop credit_bank comer_coop, by(segm_id)

merge 1:1 segm_id using "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", keep(1 3) keepus(control_break_fe_400 within_control z_run_cntrl) gen(wmerge)

label var within_control "Guerrilla control"

*Erasing table before exporting
cap erase "${tables}\rdd_main_agro.tex"
cap erase "${tables}\rdd_main_agro.txt"
cap erase "${tables}\rdd_main_agro_nweights.tex"
cap erase "${tables}\rdd_main_agro_nweights.txt"

*Global of border FE for all estimates
gl breakfe "control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

gl depvars "ind_asoc credit_coop credit_bank comer_coop"

foreach var of global depvars {

	*RDD with break fe and triangular weights 
	rdrobust `var' z_run_cntrl, all kernel(triangular) 
	gl h=e(h_l)
	gl h=2.271
	gl b=e(b_l)

	*Conditional for all specifications
	gl if "if abs(z_run_cntrl)<=${h}"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_run_cntrl/${h})) ${if}
	
	cap drop ntweights
	gen ntweights=n_`var' * tweights
	
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) 
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}\rdd_main_agro.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
	reghdfe `var' ${controls} [aw=ntweights] ${if}, vce(r) a(i.${breakfe}) 
	qui: summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .001)
	outreg2 using "${tables}\rdd_main_agro_nweights.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
	
}







*END
