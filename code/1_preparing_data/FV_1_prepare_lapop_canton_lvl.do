set more off

global BDO="${data}/lapop"
global BDI="${BDO}/temp"
global BDF="${BDO}"

// global BDO="1. Bases de datos\1. Original"
// global BDI="C:\Users\Sara\Desktop\Proyecto MicaAnto\2. Intermedio"
// global BDF="C:\Users\Sara\Desktop\Proyecto MicaAnto\3. Final"

*******************************************************************
*BASE DE DATOS PANEL LAPOP 2004-2016
*******************************************************************


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Georeferenciacion 2004-2016
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

*2004
******************************************************
use "$BDO\lapop_04_cl",clear

*verificacion de codigos
rename departamento municipio,upper
replace DEPARTAMENTO="CABAÑAS" if DEPARTAMENTO=="CABANAS"
rename codigo codigo_orig
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", nogen keepusing(codigo) keep(1 3)
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="SANTA TECLA"
gen coincidencia_codigo=1 if codigo==codigo_orig    // coincidencia al 100%
drop codigo_orig coincidencia_codigo

*para georeferenciacion
rename ecaser elscanton
rename esegme elssegmento

decode elscanton, generate(candsc)
replace candsc="AREA URBANA" if candsc=="No aplica"
label val elscanton .
label val elssegmento .
replace elscanton=0 if elscanton==99
replace elssegmento=0 if elssegmento==99

save "$BDI\lapop2004",replace 


 
*2006
******************************************************
use "$BDO\lapop_06_cl",clear

*verificacion de codigos
rename departamento municipio,upper
replace DEPARTAMENTO="CABAÑAS" if DEPARTAMENTO=="CABANAS"
rename codigo codigo_orig
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", nogen keepusing(codigo) keep(1 3)
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="SANTA TECLA"

gen coincidencia_codigo=1 if codigo==codigo_orig    // coincidencia al 100%
tab coincidencia_codigo
drop codigo_orig coincidencia_codigo

*para georeferenciacion
decode elscanton, generate(candsc)
label val elscanton .
label val elssegmento .
save "$BDI\lapop2006",replace  



*2008
******************************************************
use "$BDO\lapop_08_cl",clear

*verificacion de codigos
rename departamento municipio,upper
replace DEPARTAMENTO="CABAÑAS" if DEPARTAMENTO=="CABANAS"
foreach var of varlist DEPARTAMENTO MUNICIPIO{
	replace `var' = subinstr(`var', "á", "A",.)
	replace `var' = subinstr(`var', "é", "E",.)
	replace `var' = subinstr(`var', "í", "I",.)
	replace `var' = subinstr(`var', "ó", "O",.)
	replace `var' = subinstr(`var', "ú", "U",.)
	replace `var' = subinstr(`var', "ñ", "Ñ",.)
}
rename codigo codigo_orig
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", nogen keepusing(codigo) keep(1 3)
replace codigo=619 if DEPARTAMENTO=="SAN SALVADOR" & MUNICIPIO=="CIUDAD DELGADO"
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="NUEVA SAN SALVADOR"
replace codigo=515 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="OPICO"
replace codigo=314 if DEPARTAMENTO=="SONSONATE" & MUNICIPIO=="SANTO DOMINGO"
gen coincidencia_codigo=1 if codigo==codigo_orig    // coincidencia al 100%
drop codigo_orig coincidencia_codigo

*para georeferenciacion
decode elscanton, generate(candsc)
label val elscanton .
label val elssegmento .
save "$BDI\lapop2008",replace     // 213 obs



*2010
******************************************************
use "$BDO\lapop_10_cl",clear

*verificacion de codigos
rename departamento municipio,upper
foreach var of varlist DEPARTAMENTO MUNICIPIO{
	replace `var' = subinstr(`var', "á", "A",.)
	replace `var' = subinstr(`var', "é", "E",.)
	replace `var' = subinstr(`var', "í", "I",.)
	replace `var' = subinstr(`var', "ó", "O",.)
	replace `var' = subinstr(`var', "ú", "U",.)
	replace `var' = subinstr(`var', "ñ", "Ñ",.)
}
replace DEPARTAMENTO=upper(DEPARTAMENTO)
replace MUNICIPIO=upper(MUNICIPIO)
rename codigo codigo_orig
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", nogen keepusing(codigo) keep(1 3)
replace codigo=619 if DEPARTAMENTO=="SAN SALVADOR" & MUNICIPIO=="CIUDAD DELGADO"
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="NUEVA SAN SALVADOR"
replace codigo=515 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="OPICO"
replace codigo=314 if DEPARTAMENTO=="SONSONATE" & MUNICIPIO=="SANTO DOMINGO"
gen coincidencia_codigo=1 if codigo==codigo_orig    // coincidencia al 100%
drop codigo_orig coincidencia_codigo


*para georeferenciacion
decode elscanton, generate(candsc)
label val elscanton .
replace elscanton=0 if missing(elscanton)
label val elssegmento .
save "$BDI\lapop2010",replace     // 213 obs



*2012
******************************************************
use "$BDO\lapop_12_cl",clear

*verificacion de codigos   (hay 23 missings de codigos)
decode prov, generate(DEPARTAMENTO)
decode municipio, generate(MUNICIPIO)
foreach var of varlist DEPARTAMENTO MUNICIPIO{
	replace `var' = subinstr(`var', "á", "A",.)
	replace `var' = subinstr(`var', "é", "E",.)
	replace `var' = subinstr(`var', "í", "I",.)
	replace `var' = subinstr(`var', "ó", "O",.)
	replace `var' = subinstr(`var', "ú", "U",.)
	replace `var' = subinstr(`var', "ñ", "Ñ",.)
}
replace DEPARTAMENTO=upper(DEPARTAMENTO)
replace MUNICIPIO=upper(MUNICIPIO)
replace DEPARTAMENTO="AHUACHAPAN" if DEPARTAMENTO=="AUACHAPAN"
replace MUNICIPIO="AHUACHAPAN" if MUNICIPIO=="AUACHAPAN"
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", keepusing(codigo) keep(1 3)
replace codigo=619 if DEPARTAMENTO=="SAN SALVADOR" & MUNICIPIO=="CIUDAD DELGADO"
replace codigo=903 if DEPARTAMENTO=="CUSCATLAN" & MUNICIPIO=="ILOBASCO"    // error: pertenece a CABAÑAS
replace codigo=702 if DEPARTAMENTO=="CABAÑAS" & MUNICIPIO=="COJUTEPEQUE"   // error: pertenece a CUSCATLAN
replace codigo=708 if DEPARTAMENTO=="CABAÑAS" & MUNICIPIO=="SAN CRISTOBAL"  // error: pertenece a CUSCATLAN
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="SANTA TECLA"
replace codigo=906 if DEPARTAMENTO=="CUSCATLAN" & MUNICIPIO=="SENSUNTEPEQUE"   // error: pertenece a CABAÑAS
replace codigo=. if DEPARTAMENTO=="CABAÑAS" & MUNICIPIO=="EL CARMEN"   // podria pertenecer a CUSCATLAN o LA UNION: no se asigna codigo a 23 obs
drop muni*

save "$BDI\lapop2012",replace    



*2014
******************************************************
use "$BDO\lapop_14_cl",clear

*verificacion de codigos
decode prov, generate(DEPARTAMENTO)
decode municipio, generate(MUNICIPIO)

foreach var of varlist DEPARTAMENTO MUNICIPIO{
	replace `var' = subinstr(`var', "á", "A",.)
	replace `var' = subinstr(`var', "é", "E",.)
	replace `var' = subinstr(`var', "í", "I",.)
	replace `var' = subinstr(`var', "ó", "O",.)
	replace `var' = subinstr(`var', "ú", "U",.)
	replace `var' = subinstr(`var', "ñ", "Ñ",.)
}
replace DEPARTAMENTO=upper(DEPARTAMENTO)
replace MUNICIPIO=upper(MUNICIPIO)
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", keepusing(codigo) keep(1 3)
replace codigo=619 if DEPARTAMENTO=="SAN SALVADOR" & MUNICIPIO=="CIUDAD DELGADO"
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="SANTA TECLA"
replace codigo=1403 if DEPARTAMENTO=="LA UNION" & MUNICIPIO=="CONCEPCION" 

gen year=2014
drop muni*
save "$BDI\lapop2014",replace   



*2016
******************************************************
use "$BDO\lapop_16_cl",clear

*verificacion de codigos
decode prov, generate(DEPARTAMENTO)
decode municipio, generate(MUNICIPIO)
merge m:1 DEPARTAMENTO MUNICIPIO using "$BDF\codigos municipios", nogen keepusing(codigo) keep(1 3)
replace codigo=619 if DEPARTAMENTO=="SAN SALVADOR" & MUNICIPIO=="CIUDAD DELGADO"
replace codigo=511 if DEPARTAMENTO=="LA LIBERTAD" & MUNICIPIO=="SANTA TECLA"

*variables de interes
gen year=2016
drop muni*
save "$BDI\lapop2016",replace    



*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Formato Bases 2004 - 2010
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
local data lapop2004 lapop2006 lapop2008 lapop2010
foreach x of local data {
	use "$BDI//`x'.dta", clear
	rename *,lower
	
	*Renombrar: confianza instituciones
	renvars, presub(b confianza)
	cap rename esb68 confianza68
	cap rename esb48 confianza69	// esb48 se repitiria con confianza48 se le asigna otro número
	
	*Renombrar: bienes y servicios
	cap rename sgl1 bienservicio1
	cap rename lgl2 bienservicio2
	cap rename lgl2a bienservicio3
	cap rename lgl3 bienservicio4
	cap rename sd2 satisfaccion2
	cap rename sd3 satisfaccion3
	cap rename sd6 satisfaccion6
	cap rename r4 disponibilidad1
	cap rename r4a disponibilidad2
	cap rename r12 disponibilidad3
	cap rename r26 disponibilidad4
	
	*Renombrar: pandilaje
	cap rename diso8 percepcion1
	cap rename diso18 percepcion2
	cap rename elsdiso18 percepcion3
	cap rename elsdiso19 percepcion4
	
	*Renombrar: extorsion
	cap rename vic31 extorsion1
	cap rename vic1ext extorsion2
	cap rename vic1exta extorsion2a
	cap rename vic1hogar extorsion4
	cap rename vic46 extorsion5
	
	*Renombrar: otros
	cap rename cp2 culturapolitica1
	cap rename cp4 culturapolitica2 
	cap rename cp4a culturapolitica3
	cap rename cp13 culturapolitica4
	cap rename jc1 intervencion1
	cap rename jc4 intervencion2
	cap rename jc10 intervencion3
	cap rename jc12 intervencion4
	cap rename jc13 intervencion5
	cap rename e5 aprobacion1
	cap rename e8 aprobacion2
	cap rename e11 aprobacion3
	cap rename e15 aprobacion4
	cap rename e14 aprobacion5
	cap rename e2 aprobacion6
	cap rename e3 aprobacion7
	cap rename e16 aprobacion8
	
	*Renombrar
	cap rename idio1 sitecon
	
	*The necxt variable differs for period 2004, 2006/2008/2010/2012 and 2014/2016
	cap rename a4 probgrave
	cap recode probgrave (1=19) (2=18) (3=30) (4=13) (5=9) (6=5) (7=56) (8=3) (9=58) (10=23) (11=32) (12=26) (13=25) (14=11) (15=1) (16=21) (17=24) (18=20) (19=17) (88 98=.) (20=61) (21=2) (22=59) (23=15) (24=10) (25=16) (26=12) (27=14) (28=4) (29=6) (30=22) (32=27) (34=7) (35=60) (36=57) (37=55) (38=70) if year>=2014
	cap recode probgrave (26 1 = 1) (5 31 27 57 = 5) (15 59 = 15) (16 32 = 16) (17 30 33 = 17) (88 98= .) (70 20 55 24 19 18 56 58 23 22 25 60 61 21 = 77) if year>=2006

	***cap rename cp5 contrib
	cap rename cp5a contrib_a
	cap rename cp5b contrib_b
	cap rename cp5c contrib_c
	cap rename cp5d contrib_d
	cap rename cp5e contrib_e
	cap rename cp6 reu_relig
	cap rename cp7 reu_esc
	cap rename cp8 reu_com
	cap rename cp9 reu_prof
	*cap rename cp13 reu_pol
	cap rename ls3 sat_vida
	cap rename it1 conf_com
	cap rename it2 com_proj
	cap rename it3 com_aprov
	cap rename vic1 delinc12m
	cap rename vic1ext delinc12m
	cap rename vic1exta delinc12m_n

	*La siguiente variable cambia a traves de anios
	cap rename vic2 delinc12m_esp
	cap recode delinc12m_esp (88 98 99 888888 988888 999999 = .) (10 11 = 77)
	cap recode delinc12m_esp (1 2 = 1) (3 = 2) (4 = 3) (5 = 4) (6 = 5) (7 = 6) (8 9 = 7) if year>=2010
	
	cap rename aoj11 viol_barr
	cap drop aoj16a
	cap rename aoj16 viol_fam
	cap rename aoj17 viol_maras	
	cap rename wc1 cons_conflarm
	cap rename paz1 paz_cal
	cap rename paz2 paz_exp
	cap rename paz3 paz_camb
	cap rename paz4 paz_sitpol
	cap rename paz5 paz_sitecon
	cap rename eay7 prob_prop
	cap rename elsay7 prob_prop
	cap rename eay8 prob_sspub
	cap rename elsay8 prob_sspub
	cap rename epn3a repr_gobnac
	cap rename elspn3a repr_gobnac
	cap rename epn3b repr_asleg
	cap rename elspn3b repr_asleg
	cap rename epn3c repr_conmun
	cap rename elspn3c repr_conmun
	cap rename evb7 dvoto_alcdip
	cap rename evb8 voto_alc
	cap rename evb9 voto_dip
	cap rename elsvb48 voto_dip
	
	*Razon para no votar (varia para anios 2004 y 2014)
	cap recode evb10 (77 6 2=7), gen(novoto_mot)
	/* 2004																				*2014		 
	(01) No le gustaba ningún partido o candidato 										(04) No le gustó ningún candidato
	(03) No confían en el sistema electoral, porque hay fraude 							(05) No cree en el sistema
	(05) No tenían DUI 																	(06) Falta de DUI
	(04) No tienen el interés suficiente para ir a votar								(03) Falta de interés
	(77) Otro   (06) Problemas personales (02) El sistema para votar es muy complicado	(02) Enfermedad  (11) Incapacidad física o discapacidad (14) Tener el DUI vencido (01) Falta de transporte (07) No se encontró en padrón electoral (08) No tener edad necesaria (09) Llegó tarde a votar y estaba cerrado (10) Tener que trabajar / Falta de tiempo (12) Por temor a violencia electoral (13) Falta de confianza en los partidos (77) Otra razón (88) NS (98) NR
*/

	cap rename evb11 voto_compra
	cap rename clien1na voto_compra
	cap rename elsvb1 voto_compra
	cap rename ros1 opi_dueno
	cap rename ros2 opi_bien
	cap rename ros3 opi_empl
	cap rename ros4 opi_equid
				
	save "$BDI//`x'.dta", replace
}


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Formato Bases 2012 - 2016
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
local data lapop2012 lapop2014 lapop2016
foreach x of local data {
	use "$BDI//`x'.dta", clear
	rename *,lower
	
	*Renombrar:  confianza instituciones
	renvars, presub(b confianza)
	cap rename esb68 confianza68
	cap rename esb48 confianza69   // esb48 se repitiria con confianza48 se le asigna otro número
	cap rename p47a confianza47
	
	*Renombrar:bienes y servicios
	cap rename sgl1 bienservicio1
	cap rename lgl2 bienservicio2
	cap rename lgl2a bienservicio3
	cap rename lgl3 bienservicio4
	cap rename sd2new2 satisfaccion2
	cap rename sd3new2 satisfaccion3
	cap rename sd6new2 satisfaccion6	
	cap rename r4 disponibilidad1
	cap rename r4a disponibilidad2
	cap rename r12 disponibilidad3
	cap rename r26 disponibilidad4
	
	*Renombrar: pandilaje
	cap rename diso8 percepcion1
	cap rename diso18 percepcion2
	cap rename elsdiso18 percepcion3
	cap rename elsdiso19 percepcion4
	
	*Renombrar: extorsion
	cap rename vic31 extorsion1
	cap rename vic1ext extorsion2
	cap rename vic1exta extorsion2a
	cap rename vic1hogar extorsion4
	cap rename vic46 extorsion5
	
	*Renombrar: otros
	cap rename cp2 culturapolitica1
	cap rename cp4 culturapolitica2
	cap rename cp4a culturapolitica3
	cap rename cp13 culturapolitica4
	cap rename jc1 intervencion1
	cap rename jc4 intervencion2
	cap rename jc10 intervencion3
	cap rename jc12 intervencion4
	cap rename jc13 intervencion5
	cap rename e5 aprobacion1
	cap rename e8 aprobacion2
	cap rename e11 aprobacion3
	cap rename e15 aprobacion4
	cap rename e14 aprobacion5
	cap rename e2 aprobacion6
	cap rename e3 aprobacion7
	cap rename e16 aprobacion8

	*Renombrar
	cap rename idio1 sitecon
	
	*The next variable differs for period 2004, 2006/2008/2010/2012 and 2014/2016
	cap rename a4 probgrave
	cap recode probgrave (1=19) (2=18) (3=30) (4=13) (5=9) (6=5) (7=56) (8=3) (9=58) (10=23) (11=32) (12=26) (13=25) (14=11) (15=1) (16=21) (17=24) (18=20) (19=17) (88 98=.) (20=61) (21=2) (22=59) (23=15) (24=10) (25=16) (26=12) (27=14) (28=4) (29=6) (30=22) (32=27) (34=7) (35=60) (36=57) (37=55) (38=70) if year>=2014
	cap recode probgrave (26 1 = 1) (5 31 27 57 = 5) (15 59 = 15) (16 32 = 16) (17 30 33 = 17) (88 98= .) (70 20 55 24 19 18 56 58 23 22 25 60 61 21 = 77) if year>=2006
	
	***cap rename cp5 contrib
	cap rename cp5a contrib_a
	cap rename cp5b contrib_b
	cap rename cp5c contrib_c
	cap rename cp5d contrib_d
	cap rename cp5e contrib_e
	cap rename cp6 reu_relig
	cap rename cp7 reu_esc
	cap rename cp8 reu_com
	cap rename cp9 reu_prof
	*cap rename cp13 reu_pol
	cap rename ls3 sat_vida
	cap rename it1 conf_com
	cap rename it2 com_proj
	cap rename it3 com_aprov
	cap rename vic1 delinc12m
	cap rename vic1ext delinc12m
	cap rename vic1exta delinc12m_n
	
	*La siguiente variable cambia a traves de anios
	cap rename vic2 delinc12m_esp
	cap recode delinc12m_esp (88 98 99 888888 988888 999999 = .) (10 11 = 77)
	cap recode delinc12m_esp (1 2 = 1) (3 = 2) (4 = 3) (5 = 4) (6 = 5) (7 = 6) (8 9 = 7) if year>=2010
	
	cap rename aoj11 viol_barr
	cap rename aoj16 viol_fam
	cap rename aoj17 viol_maras
	cap rename wc1 cons_conflarm
	cap rename paz1 paz_cal
	cap rename paz2 paz_exp
	cap rename paz3 paz_camb
	cap rename paz4 paz_sitpol
	cap rename paz5 paz_sitecon
	cap rename eay7 prob_prop
	cap rename elsay7 prob_prop
	cap rename eay8 prob_sspub
	cap rename elsay8 prob_sspub
	cap rename epn3a repr_gobnac
	cap rename elspn3a repr_gobnac
	cap rename epn3b repr_asleg
	cap rename elspn3b repr_asleg
	cap rename epn3c repr_conmun
	cap rename elspn3c repr_conmun
	cap rename evb7 dvoto_alcdip
	cap rename evb8 voto_alc
	
	*votacion en elecciones pasadas (varia para los anios 2004 vs 2014/2016)
	cap recode evb9 (3=1 "PNC/CN") (1=2 "ARENA") (3=3 "FMLN") (5=4 "CDU/CD") (4=5 "PDC/Partido de la Esperanza") (77 6 7 8 9=77 "Otros") (10=99 "Votó nulo, en blanco") (11 12 88 98=88 "NS/NR, no aplica, no tenia edad para votar, no voto"), gen(voto_dip)
	/*2004								2014/2016
	(01) PCN 							(3) PCN/CN    
	(02) ARENA 							(1) ARENA   
	(03) FMLN 							(2) FMLN  
	(04) CDU							(5) CD   
	(05) PDC 							(4) PDC/Partido de la Esperanza 
	(77) Otros ___________ 				(77) Otros (6) GANA (7) PP (8) PNL (9) Candidatos no partidarios      
	(99)Voto nulo/ Voto en blanco		(10) Votó nulo, en blanco
	(88) NS/NR, no aplica (no votó)		(11) No votó (12) No tenía edad para votar (88) NS   (98) NR*/

	cap rename elsvb48 voto_dip
	cap rename evb10 novoto_mot
	
	*Razon para no votar (varia para anios 2004 y 2014)
	cap recode elsvb100b (4=1 "No le gusto ningun partido/candidato") (5=3 "No cree en el sistema") (6=5 "Falta de DUI") (3=4 "Falta de interes") (2 11 14 1 7 88 09 10 12 13 77 88 98=7 "Otro"), gen(novoto_mot)
	cap rename evb11 voto_compra
	cap rename clien1na voto_compra
	cap rename elsvb1 voto_compra
	cap rename ros1 opi_dueno
	cap rename ros2 opi_bien
	cap rename ros3 opi_empl
	cap rename ros4 opi_equid
	
	save "$BDI//`x'.dta", replace
}

*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Append bases de datos
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

*2004-2010
use "$BDI//lapop2004.dta",clear
local data lapop2006 lapop2008 lapop2010 
foreach x of local data {
	cap destring clusterdesc, replace force
	append using "$BDI//`x'.dta", force
	erase "$BDI//`x'.dta"
}
ren q2 age
erase "$BDI//lapop2004.dta"

label value voto_dip .
save "$BDI//2004_2010.dta",replace


*2012-2016	
use "$BDI//lapop2012.dta",clear
local data lapop2014 lapop2016
foreach x of local data {
	cap destring clusterdesc, replace force
	append using "$BDI//`x'.dta", force
	erase "$BDI//`x'.dta"
}
ren q2 age
erase "$BDI//lapop2012.dta"
save "$BDI//2012_2016.dta",replace

*append 
use "$BDI//2004_2010.dta", clear
keep codigo year elscanton candsc elssegmento conf* extor*  interv* aprob* cultura* disponib* bien* satisf* opi_* voto_* novoto_mot dvoto_alcdip repr_* prob_* paz_* cons_conflarm viol_* delinc12m* reu_* contrib* sitecon sat_vida conf_com com_proj com_aprov probgrave age
append using "$BDI//2012_2016.dta", force

keep codigo year elscanton candsc elssegmento conf* extor* interv* aprob* cultura* disponib* bien* satisf* opi_* voto_* novoto_mot dvoto_alcdip repr_* prob_* paz_* cons_conflarm viol_* delinc12m* reu_* contrib* sitecon sat_vida conf_com com_proj com_aprov probgrave age
drop confianza3milx	
erase "$BDI//2004_2010.dta"
erase "$BDI//2012_2016.dta"


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Uniformizo + labels
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aorder
order codigo year elscanton elssegmento
sort year codigo
	
*disponibilidad
foreach var of varlist disponibilidad1- disponibilidad4 {
	recode `var' (1=1 "Tiene") (0=0 "No tiene"), g(`var'_1)
	replace `var'_1=. if (`var'_1!=1 & `var'_1!=0)
	drop `var'
	rename `var'_1 `var'
}


*extorsion
label val extorsion1 .
label var extorsion1 "Numero de veces que fue extorsionado - ult 12 meses"

replace extorsion2=. if year<=2008
recode extorsion2 (2=0)
label var extorsion2 "Dummy si fue victima de algun acto delicuencial - ult 12 meses"
rename extorsion2 delinc
replace delinc=. if delinc==.a | delinc==.b
label var extorsion2a "Numero de veces que fue victima e acto delincuencial"

recode extorsion4 (1=1 "Victima") (2=0 "No victima"), g(extorsion4_1)
replace extorsion4_1=. if (extorsion4_1!=1 & extorsion4_1!=0)
drop extorsion4
rename extorsion4_1 extorsion4
label var extorsion4 "Dummy si su hogar fue victima de algun acto delicuencial - ult 12 meses"
rename extorsion4 delinc_hog

label var extorsion5 "Dummy si cambio de numero telefonico a causa de amenazas"
label val extorsion5 .


*cultura política
foreach var of varlist culturapolitica1 culturapolitica2 culturapolitica3 {
	recode `var' (1=1 "Si") (2=0 "No"), g(`var'_1)
	replace `var'_1=. if (`var'_1!=1 & `var'_1!=0)
	drop `var'
	rename `var'_1 `var'
}

*other variables
foreach var of varlist dvoto_alcdip cons_conflarm delinc12m contrib* com_proj com_aprov voto_compra {
	recode `var'  (2=0)

}
recode novoto_mot  (88=.)


*Etiquetas
label var aprobacion1 "Grado aprobacion: participacion en manifestaciones (escala 1-10)"
label var aprobacion2 "Grado aprobacion: grupos para solucionar problemas de comunidad (escala 1-10)"
label var aprobacion3 "Grado aprobacion: trabajar en campañas electorales (escala 1-10)"
label var aprobacion4 "Grado aprobacion: bloqueo de calles/carreteras (escala 1-10)"
label var aprobacion5 "Grado aprobacion: invasion de propiedades (escala 1-10)"
label var aprobacion6 "Grado aprobacion: ocupacion de edificios (escala 1-10)"
label var aprobacion7 "Grado aprobacion: derrocar violentamente un gobierno (escala 1-10)"
label var aprobacion8 "Grado aprobacion: hacer justicia por su propia mano (escala 1-10)"
recode bienservicio1 (5=0) (4=1) (3=2) (2=3) (1=4)
label val bienservicio1 .
label var bienservicio1 "Grado aprobacion: servicios que da la municipalidad son buenos"

recode bienservicio4 (2=0)
label val bienservicio4 .
label var bienservicio4 "Dummy si cree que vale la pena pagar mas impuestos al municipio"
label var bienservicio3 "Quien debe tener mas responsabilidades sobre servicios publicos"

label var confianza1 "Grado confianza: tribunales de justicia (escala 1-7)"   
label var confianza2 "Grado respeto: instituciones políticas (escala 1-7)"   
label var confianza3 "Grado creencia:  derechos básicos del ciudadano están protegidos (escala 1-7)"  
label var confianza4 "Grado orgullo: vivir bajo sistema polico salvadoreño (escala 1-7)"   
label var confianza6 "Grado en que piensa que debe apoyar a sistema polico salvadoreño (escala 1-7)"  
label var confianza10a "Grado confianza: sistema de justicia (escala 1-7)"   
label var confianza11 "Grado confianza: Tribunal Supremo Electoral (escala 1-7)"  
label var confianza12 "Grado confianza: Fuerza Armada (escala 1-7)"  
label var confianza13 "Grado confianza: Asamblea Legislativa (escala 1-7)"   
label var confianza14 "Grado confianza: Gobierno Nacional (escala 1-7)" 
label var confianza15 "Grado confianza: Fiscalía General de la República (escala 1-7)" 
label var confianza16 "Grado confianza: Procuraduría General de la República (escala 1-7)"  
label var confianza17 "Grado confianza: Procuraduría para la Defensa de los ddhh (escala 1-7)"   
label var confianza18 "Grado confianza: Policía Nacional Civil (escala 1-7)"  
label var confianza19 "Grado confianza: Corte de Cuentas de la República (escala 1-7)"  
label var confianza20 "Grado confianza: Iglesia Católica (escala 1-7)"  
label var confianza20a "Grado confianza: Iglesias Evangélicas (escala 1-7)"  
label var confianza21 "Grado confianza: partidos políticos (escala 1-7)" 
label var confianza21a "Grado confianza: presidente (escala 1-7)"  
label var confianza31 "Grado confianza: Corte Suprema de Justicia (escala 1-7)" 
label var confianza32 "Grado confianza: municipalidad (escala 1-7)"   
label var confianza37 "Grado confianza: medios de comunicación (escala 1-7)"  
label var confianza43 "Grado orgullo: ser salvadoreño (escala 1-7)"   
label var confianza47 "Grado confianza: elecciones (escala 1-7)"
label var confianza47a "Grado confianza: elecciones en este país (escala 1-7)"   
label var confianza48 "Grado confianza: tratados de libre comercio (escala 1-7)" 
label var confianza50 "Grado confianza: Sala de lo Constitucional (escala 1-7)"    
label var confianza68 "Grado confianza: Tribunal de Ética Gubernamental (escala 1-7)" 
label var confianza69 "Grado confianza: Instituto de Acceso a la Información Pública (escala 1-7)"

recode satisfaccion2 (4=1) (3=2) (2=3) (1=4)
recode satisfaccion3 (4=1) (3=2) (2=3) (1=4)
recode satisfaccion6 (4=1) (3=2) (2=3) (1=4)
label var satisfaccion2	"Grado satsifaccion: Estado de las vías, carreteras y autopistas (escala 1-4)"						
label var satisfaccion3	"Grado satsifaccion: Calidad de escuelas públicas (escala 1-4)"						
label var satisfaccion6	"Grado satsifaccion: La calidad de los servicios de salud públicos (escala 1-4)"						
label var disponibilidad1 "Dummy si tiene Teléfono convencional"
label var disponibilidad2 "Dummy si tiene Teléfono celular"
label var disponibilidad3 "Dummy si tiene Agua potable dentro de la casa"
label var disponibilidad4 "Dummy si sshh está conectado a la red de saneamiento/desagüe/drenaje"

label var culturapolitica1 "Dummy si recurrio a diputado de la Asamblea Legislativa para solucionar problemas"
label var culturapolitica2 "Dummy si recurrio a autoridad local para solucionar problemas"
label var culturapolitica3 "Dummy si recurrio a instuticion publica para solucionar problemas"

recode intervencion1 (2=0)
recode intervencion2 (2=0)
recode intervencion3 (2=0)
recode intervencion4 (2=0)
recode intervencion5 (2=0)
label var intervencion1 "Dummy si cree que militar debe tomar poder: desempleo muy alto"
label var intervencion2 "Dummy si cree que militar debe tomar poder: muchas protestas sociales"
label var intervencion3 "Dummy si cree que militar debe tomar poder: mucha delincuencia"
label var intervencion4 "Dummy si cree que militar debe tomar poder: alta inflación"
label var intervencion5 "Dummy si cree que militar debe tomar poder: mucha corrupcion"

label var opi_bien "Opinion: Estado debe asegurar bienestar de la gente (scale 1-7)"
label var opi_dueno "Opinion: Estado deberia ser el dueno de las empresas/industrias importantes (scale 1-7)"
label var opi_empl "Opinion: Estado debe ser principal responsable de crear empleos (scale 1-7)"
label var opi_equid "Opinion: Estado debe implementar politicas para reducir la desigual (scale 1-7)"

label var dvoto_alcdip "Elecciones pasadas: Voto para alcaldes y diputados?"
label var novoto_mot "Elecciones pasadas: Razon por la que la gente no voto"
label var voto_alc "Elecciones pasadas: Voto para alcalde"
label var voto_compra "Elecciones pasadas: Compra de voto presidencial"
label var voto_dip "Elecciones pasadas: Voto para diputado"

label var repr_asleg "Representatividad de los diputados de la Asamblea Legislativa"
label var repr_conmun "Representatividad de la alcaldía de su localidad y el concejo municipal"
label var repr_gobnac "Representatividad del gobierno nacional"

label var prob_prop  "A quién acudiría ante problema con propiedad privada"
label var prob_sspub "A quién acudiría ante problema de suministro de un servicio publico"

label var paz_cal "Acuerdo Paz: calificacion"
label var paz_camb "Acuerdo Paz: produjo cambio en su comunidad"
label var paz_exp "Acuerdo Paz: expectativa"
label var paz_sitecon "Acuerdo Paz: mejoro la situación socioeconómica del país"
label var paz_sitpol "Acuerdo Paz: mejoro la situación política del país"

label var cons_conflarm "Conflicto armado produjo perdida de algun pariente"

label var viol_barr "Violencia en el barrio donde vive"
label var viol_maras "Violencia por parte de los maras en su barrio"
label var viol_fam "Violencia por parte de miembros de su propia familia"

label var delinc12m "Ha sido victima de acto delicuencial en los ult 12 meses"

label var reu_com "Asistencia a reuniones: comité o junta de mejoras para la comunidad"
label var reu_esc "Asistencia a reuniones: asociación de padres de familia de la escuela"
*label var reu_pol "Asistencia a reuniones: partido político"
label var reu_prof "Asistencia a reuniones: asociación de profesionales, comerciantes o productores"
label var reu_relig "Asistencia a reuniones: organización religiosa"

label var contrib_a "Ha donado dinero/materiales para ayudar a solucionar algún problema"
label var contrib_b "Ha contribuido con su propio trabajo o mano de obra"
label var contrib_c "Ha estado asistiendo a reuniones comunitarias sobre algún problema"
label var contrib_d "Ha tratado de organizar un grupo nuevo para resolver algún problema"
label var contrib_e "Ha tratado de organizar un grupo para combatir la delincuencia"

label var com_proj "¿Cree que la mayoría de la gente solo se preocupa por si misma"
label var com_aprov "¿Cree que la mayoría de la gente intentaria aprovecharse de usted"
label var conf_com "La gente de su comunidad es confiable?"
label var sat_vida "Satisfaccion con su vida"
label var sitecon "Nivel de su situación económica"

label var probgrave "Problema más grave que está enfrentando el pais"
label value opi_dueno .
label value opi_bien .
label value opi_empl .
label value opi_equid .

drop bienservicio2
aorder
order codigo year elscanton elssegmento


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Para merge con shapefile LAPOP a nivel de canton y seg
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

*Busqueda codigo de canton (solo para el area rural)
*----------------------------------------
replace candsc="AREA URBANA" if missing(candsc)
replace candsc=upper(candsc)

replace candsc = subinstr(candsc, "Ñ", "N",.)
replace candsc = subinstr(candsc, "ñ", "Ñ",.)
replace candsc = subinstr(candsc, "Á", "A",.)
replace candsc = subinstr(candsc, "É", "E",.)
replace candsc = subinstr(candsc, "Í", "I",.)
replace candsc = subinstr(candsc, "Ó", "O",.)
replace candsc = subinstr(candsc, "Ú", "U",.)
replace candsc = subinstr(candsc, "á", "A",.)
replace candsc = subinstr(candsc, "é", "E",.)
replace candsc = subinstr(candsc, "í", "I",.)
replace candsc = subinstr(candsc, "ó", "O",.)
replace candsc = subinstr(candsc, "ú", "U",.)
replace candsc = subinstr(candsc, "  ", " ",.)
replace candsc=rtrim(candsc)
replace candsc=ltrim(candsc)
replace candsc=strtrim(candsc)

merge m:1 codigo candsc using "${BDI}\CatGeo2007", nogen keep(1 3)

replace can="06" if candsc=="OJO DE AGUA" & codigo==702
replace can="13" if candsc=="EL MOGOTILLO" & codigo==1414
replace can="" if candsc=="COMECAYO" & codigo==210       // en el catalogo geografico no hay ningun canton con ese nombre en el pais
replace can="01" if candsc=="EL BARRILLO" & codigo==522  
replace can="06" if candsc=="LAS LOMAS" & codigo==502    // asumo que es lo mismo que "LOMAS DE ANDALUCIA"
replace can="14" if candsc=="SAN FCO. DEL MONTE" & codigo==903   
replace can="02" if candsc=="CHAMOCO" & codigo==1010
replace can="03" if candsc=="EL PASO DE GUALACHE" & codigo==1122
replace can="28" if candsc=="SAN JUAN BUENAVISTA" & codigo==210
replace can="04" if candsc=="LOS HORCONES" & codigo==1412


*Quito observaciones
drop if codigo==.              // 23 casos eliminados
drop if can=="" & year<=2010   // 32 casos eliminados
replace can="" if year>=2012


*codigo unico para unir con shapefile
*----------------------------------------

preserve
	*Obtengo listado de cantones que hay en lapop 2004 a 2010 (solo esos anios tienen dato de canton)
	keep if year<=2010
	keep codigo elscanton candsc elssegmento can
	duplicates drop
	 * 402 obs
	save "$BDI\cantones de lapop 2004 a 2010",replace
restore

*Creacion variable NAME
tostring elssegm, replace
replace elssegm="" if elssegm=="." 
replace elssegm="0"+elssegm if length(elssegm)==1 & year<=2010 

sort candsc
gen NAME="00-10"+elssegm if can=="00" & year<=2010 

sort year codigo can NAME
order codigo year elscanton candsc elssegmento can NAME
compress

tostring codigo, replace 
replace codigo= "0"+codigo if length(codigo)==3

keep if year<=2010

gen id07=codigo+can
destring id07, replace 

saveold "$BDF//LAPOP0410_individuo.dta",replace

*-------------------------------------------------------------------------------
* ICW Program
*
*-------------------------------------------------------------------------------
capture program drop make_index_gr
capture mata: mata drop icwxmata()
program make_index_gr
version 16
    syntax anything [if]
    gettoken newname anything: anything
    gettoken wgt anything: anything
	gettoken sgroup anything: anything
    local Xvars `anything'
	marksample touse
  	mata: icwxmata(("`Xvars'"),"`wgt'","`sgroup'", "index")
	rename index index_`newname'
end


mata:
	mata set matastrict off
	function icwxmata(xvars, wgts, sgroups, indexname)
	{
		st_view(X=0,.,tokens(xvars))
		st_view(wgt=.,.,wgts)
		st_view(sgroup=.,.,sgroups)
		nr = rows(X)
		nc = cols(X)	
		sg_wgt = wgt:*sgroup
		sg_wgtst = sg_wgt/sum(sg_wgt)
		all_wgtst = wgt/sum(wgt)
		sg_wgtstdM = J(1,nc,1) # sg_wgtst
		all_wgtstdM = J(1,nc,1) # all_wgtst
		sg_wgtdmeans = colsum(X:*sg_wgtstdM)
		sgroup2 = sgroup
		sgroupdM = J(1,nc,1) # sgroup2
		sg_meandevs = ((X:*sgroupdM) - (J(nr,1,1) # sg_wgtdmeans):*sgroupdM)
		all_wgtdmeandevs = X - (J(nr,1,1) # sg_wgtdmeans)
		sg_wgtdstds = sqrt(colsum(sg_wgt:*(sg_meandevs:*sg_meandevs)):/(sum(sg_wgt)-1))
		Xs = all_wgtdmeandevs:/(J(nr,1,1) # sg_wgtdstds)
		S = variance(Xs, wgt)
		invS = invsym(S)
		ivec = J(nc,1,1)
		indexout_sc = (invsym(ivec'*invS*ivec)*ivec'*invS*Xs')'
		indexout = indexout_sc/sqrt(variance(indexout_sc, sg_wgt))
		st_addvar("float",indexname)
		st_store(.,indexname,indexout)
	}
end

*-------------------------------------------------------------------------------
* Preparing vars related to community trust and participation
*-------------------------------------------------------------------------------
use "$BDF//LAPOP0410_individuo.dta", clear

gen agewar= age -(year-1992)

gen sh_agewar_lapop=1 if agewar<1
replace sh_agewar_lapop=0 if agewar>=1 & agewar!=.

d sitecon reu_relig reu_esc reu_prof reu_com conf_com contrib_c paz_cal paz_sitecon paz_sitpol paz_camb

foreach var in reu_relig reu_esc reu_prof reu_com conf_com{
	gen `var'_high=(`var'==1) if `var'!=.
	gen `var'_low=(`var'==4) if `var'!=.
} 

gen asist_reu_high= (reu_relig==1 | reu_esc==1 | reu_com==1 | reu_prof==1) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.
gen asist_reu_low= (reu_relig==4 | reu_esc==4 | reu_com==4 | reu_prof==4) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.

recode sitecon (2 3 = 1) (4 5 = 0)
recode reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon (2 = 1) (3 4 = 0) 

gen asist_reu= (reu_relig==1 | reu_esc==1 | reu_com==1 | reu_prof==1) if reu_relig!=. & reu_esc!=. & reu_com!=. & reu_prof !=.

d aprobacion2 aprobacion3 aprobacion4 aprobacion7 aprobacion8 bienservicio1 bienservicio4 confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 confianza47a culturapolitica2 culturapolitica3 culturapolitica4 satisfaccion2 satisfaccion3 satisfaccion6

*Recoding 
recode aprobacion3 aprobacion4 aprobacion7 aprobacion8 (1/5 = 0) (6/10 =1)
recode bienservicio1 (1 = 0) (2/4 =1)
recode confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 confianza47a (1/4 = 0) (5/7 =1)
recode culturapolitica4 (4 = 0) (2/3 = 1)
recode satisfaccion2 satisfaccion3 satisfaccion6 (3/4 = 0) (2 = 1)

*Indices (sum)
drop confianza47a confianza50 confianza68 confianza69

gl pp "aprobacion1 aprobacion2 aprobacion3 aprobacion4"
gl ep "culturapolitica2 culturapolitica3 culturapolitica4"
gl ap "aprobacion5 aprobacion6 aprobacion7 aprobacion8 "
gl trst "confianza1 confianza2 confianza4 confianza6 confianza12 confianza13 confianza18 confianza21 confianza31 confianza43 confianza47"

*Political affiliations
egen miss1=rowmiss(${pp})
gen pp_sample=(miss1==0)

egen miss2=rowmiss(${ep})
gen ep_sample=(miss2==0)

egen miss3=rowmiss(${ap})
gen ap_sample=(miss3==0)

egen miss4=rowmiss(${trst})
gen trst_sample=(miss4==0)

egen sum_pp=rowtotal(${pp}) if pp_sample==1, missing
egen sum_ep=rowtotal(${ep}) if ep_sample==1, missing
egen sum_ap=rowtotal(${ap}) if ap_sample==1, missing
egen sum_trst=rowtotal(${trst})  if trst_sample==1, missing

*Indices (ICW)
gen wgt=1
gen stdgroup=1

make_index_gr pp wgt stdgroup ${pp}
make_index_gr ep wgt stdgroup ${ep}
make_index_gr ap wgt stdgroup ${ap}
make_index_gr trst wgt stdgroup ${trst}

egen z_index_pp=std(index_pp)
egen z_index_ep=std(index_ep)
egen z_index_ap=std(index_ap)
egen z_index_trst=std(index_trst)

*Crime perceptions
*recode pandillaje (4 3 2 = 0) 
gen delinc_all=1 if delinc==1 | delinc_hog==1
replace delinc_all=0 if delinc==0 & delinc_hog==0

*Count of N 
gen n_trst=1 if z_index_trst!=.

*Property trespassing
summ aprobacion5, d
gen aprobacion5_median=(aprobacion5>`r(p50)') if aprobacion5!=.
gen aprobacion5_p75=(aprobacion5>`r(p75)') if aprobacion5!=.

*Collapsing 
collapse (mean) aprobacion2 aprobacion3 aprobacion4 aprobacion5 aprobacion7 aprobacion8 bienservicio1 bienservicio4 confianza2 confianza3 confianza4 confianza6 confianza12 confianza13 confianza14 confianza18 confianza21 confianza21a confianza43 confianza47 culturapolitica2 culturapolitica3 culturapolitica4 satisfaccion2 satisfaccion3 satisfaccion6 sum_* index_* z_index*  delinc* extorsion* aprobacion5_median aprobacion5_p75 sitecon reu_relig reu_esc reu_com reu_prof conf_com paz_cal paz_sitecon paz_sitpol asist_reu *_high *_low sh_agewar_lapop (sum) n_trst, by(id07)

*Checking the unique identifier
isid id07

*saving the data
save "${data}/temp\lapop_canton_lvl.dta", replace






*END
