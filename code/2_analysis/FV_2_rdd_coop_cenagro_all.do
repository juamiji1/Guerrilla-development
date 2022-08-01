/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Cooperativism using the CENAGRO
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
*Preparing the data at the producer level 
* 
*-------------------------------------------------------------------------------
*Preparing census tracts IDs
import delimited "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FB1P.csv", stringcols(2 3 4 5 6) clear

gen segm_id=depid+munid+segid

keep portid depid munid canid segid segm_id

tempfile SegmID
save `SegmID', replace 

*Importing info on subsistence producers
import delimited "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA2.csv", clear

*Fixing the cooperatives values 
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

*Individual belongs to cooperative
gen ind_coop=(s01p05p==31)
gen ind_asoc=(s01p05p>28)

*Subsistence indicator 
gen subsistence=1

*keeping only vars of interest 
keep portid fb1p06a fb1p06b ind_coop ind_asoc subsistence s01p04 s01p04dep s01p04mun s01p04can

tempfile ProdS
save `ProdS', replace

*Importing info on comercial producers
import delimited "C:\Users\jmjimenez\Dropbox\My-Research\Guerillas_Development\2-Data\Salvador\CensoAgropecuario\01 - Base de Datos MSSQL\FA1.csv", clear

*Fixing vars 
replace s01p06=9941 if s01p06==4101
replace s01p06=9941 if s01p06==4102
replace s01p06=9941 if s01p06==4103
replace s01p06=9941 if s01p06==4104
replace s01p06=9941 if s01p06==4105

replace s01p06=s01p06-9900

*Number of cooperatives 
gen cooperative=(s01p06==36) if s01p06!=39

*Individual belongs to ccoperative
gen ind_coop=s01p09
replace ind_coop=. if ind_coop==-2
replace ind_coop=1 if ind_coop>0

*Comercial activity 
gen subsistence=0

*keeping only vars of interest
keep portid fb1p06a fb1p06b cooperative ind_coop subsistence s01p04 s01p04dep s01p04mun s01p04can

*Adding subsitence producers
append using `ProdS'

*Merging the census tracts Ids 
merge m:1 portid using `SegmID', keep(1 3) nogen 

*Creating more vars
gen ind_coop_s=ind_coop if subsistence==1
gen ind_coop_c=ind_coop if subsistence==0
ren s01p04 same_seg

recode s01p04dep s01p04mun s01p04can (-2=.)
destring depid munid canid, replace

*Explotation center same canton 
gen same_can=same_seg 
replace same_can=1 if same_seg==0 & s01p04dep==depid & s01p04mun==munid & s01p04can==canid

*Explotation center same municipality 
gen same_mun=same_seg 
replace same_mun=1 if same_seg==0 & s01p04dep==depid & s01p04mun==munid 

*Explotation center same depto
gen same_dep=same_seg 
replace same_dep=1 if same_seg==0 & s01p04dep==depid

*Collapsing at the segment level 
collapse (sum) n_cooperative=cooperative n_ind_coop=ind_coop n_ind_coop_c=ind_coop_c n_ind_coop_s=ind_coop_s n_ind_asoc=ind_asoc (mean) ind_coop* ind_asoc cooperative same_*, by(segm_id)

*Fixing shares
replace cooperative=0 if cooperative==.
replace ind_coop=0 if ind_coop==.
replace ind_coop_c=0 if ind_coop_c==.  
replace ind_coop_s=0 if ind_coop_s==.
replace ind_asoc=0 if ind_asoc==.

*Labels
la var cooperative "Is a cooperative"
la var ind_coop "Belongs to cooperative" 
la var ind_coop_c "Belongs to cooperative (Comercial)"
la var ind_coop_s "Belongs to cooperative (Subsistence)" 
la var ind_asoc "Belongs to asociation"
la var same_seg "Same place"

la var n_cooperative "Is a cooperative"
la var n_ind_coop "Belongs to cooperative" 
la var n_ind_coop_c "Belongs to cooperative (Comercial)"
la var n_ind_coop_s "Belongs to cooperative (Subsistence)" 
la var n_ind_asoc "Belongs to asociation"

*Saving the tempfile
tempfile ProdAll
save `ProdAll', replace 


*-------------------------------------------------------------------------------
*Preparing the data 
*
*-------------------------------------------------------------------------------
use "${data}/night_light_13_segm_lvl_onu_91_nowater.dta", clear

drop _merge
merge 1:1 segm_id using `ProdAll', keep(1 3) nogen

*Global of border FE for all estimates
gl breakfe="control_break_fe_400"
gl controls "within_control i.within_control#c.z_run_cntrl z_run_cntrl"
gl controls_resid "i.within_control#c.z_run_cntrl z_run_cntrl"

*RDD with break fe and triangular weights 
rdrobust arcsine_nl13 z_run_cntrl, all kernel(triangular)
gl h=e(h_l)
gl b=e(b_l)

*Conditional for all specifications
gl if "if abs(z_run_cntrl)<=${h}"

*Replicating triangular weights
cap drop tweights
gen tweights=(1-abs(z_run_cntrl/${h})) ${if}

*Globals for outcomes
gl coops "cooperative ind_coop ind_coop_c ind_coop_s ind_asoc"
gl ncoops "n_cooperative n_ind_coop n_ind_coop_c n_ind_coop_s n_ind_asoc"
gl sameplace "same_seg same_can same_mun same_dep"

*-------------------------------------------------------------------------------
*RDD results (Tables)
*-------------------------------------------------------------------------------
*Erasing table before exporting
cap erase "${tables}\rdd_cenagrocoops_all_p1.tex"
cap erase "${tables}\rdd_cenagrocoops_all_p1.txt"
cap erase "${tables}\rdd_cenagrocoops_all_p2.tex"
cap erase "${tables}\rdd_cenagrocoops_all_p2.txt"
cap erase "${tables}\rdd_cenagrocoops_all_p3.tex"
cap erase "${tables}\rdd_cenagrocoops_all_p3.txt"

*Tables
foreach var of global coops{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrocoops_all_p1.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global ncoops{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrocoops_all_p2.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}

foreach var of global sameplace{
	*Table
	reghdfe `var' ${controls} [aw=tweights] ${if}, vce(r) a(i.${breakfe}) resid
	summ `var' if e(sample)==1 & within_control==0, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}\rdd_cenagrocoops_all_p3.tex", tex(frag) keep(within_control) addtext("Kernel", "Triangular") addstat("Bandwidth (Km)", ${h},"Polynomial", 1, "Dependent mean", ${mean_y}) label nonote nocons append 
}







*END

