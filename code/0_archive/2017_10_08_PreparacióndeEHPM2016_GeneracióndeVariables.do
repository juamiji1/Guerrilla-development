clear all
clear results

/* Análisis de datos - Familia e infancia
Fuente de datos: EHPM 2016 (El Salvador)

Análisis a los hogares en edad reproductiva - Mujeres de 0 a 44 años (según 
definición de la OMS)

En cd DEFINIR EN QUÉ CARPETA ESTÁ LA BASE DE DATOS DE LA EHPM 2016
*/
cd "C:\Users\...\Datos\EHPM2016-STATA"
use "EHPM 2016.dta", clear

svyset correlativo [pw=fac00], strata (estratoarea)

*******************************************************************************
*******************************************************************************
/* 
I. Dinámicas de las Familias en El Salvador
Tipos de hogares
Unipersonal: Jefe de hogar solo
Pareja sin hijos: Jefe de hogar y cónyuge
Nuclear: Jefe de hogar, cónyuge e hijos 
Extensa con hijos: Jefe de hogar, cónyuge, hijos, otros familiares y/u  otras personas
Extensa sin hijos: jefe de hogar, cónyuge, otros familiares y/u otras personas
Monoparental: Jefe de hogar e hijos
Monoparental extensa con hijos: Jefe de hogar, hijos y otros familiares y/u otras personas
Monoparental extensa sin hijos: Jefe de hogar, otros familiares y otras personas y/u otras personas
*/ 
*******************************************************************************
*******************************************************************************
*Primero genero dummies en un wide set con respecto al jefe de hogar, es decir
*por cada jefe de hogar cuál es el parentesco con cada miembro 
codebook r103
label list r103
tab r103, generate (r103)

gen sexo=r104
replace sexo=0 if sexo==1
replace sexo=1 if sexo==2
label define sexo 0 "hombre" 1 "mujer"
label values sexo sexo
tab sexo

*Luego, obtengo número de hijos por hogar, lo cual corresponde a la nueva variable
*creada "r1033"
bys idboleta: egen numdehijos=sum(r1033)

*Luego genero la suma por "tipo" de miembro en el hogar cosiderando todos aquellos que 
*no son jefe, pareja o hijo*
bys idboleta: egen miemr1034=sum(r1034)
bys idboleta: egen miemr1035=sum(r1035)
bys idboleta: egen miemr1036=sum(r1036)
bys idboleta: egen miemr1037=sum(r1037)
bys idboleta: egen miemr1038=sum(r1038)
bys idboleta: egen miemr1039=sum(r1039)
bys idboleta: egen miemr10310=sum(r10310)
bys idboleta: egen miemr10311=sum(r10311)

*Hogar unipersonal*
gen unipersonal=0 
replace unipersonal=1 if r1031==1 & miemh==1

*Pareja sin hijos*
bys idboleta: egen conpareja=max(r1032)
gen parejasinhij=0
replace parejasinhij=1 if r1031==1 & conpareja==1 & numdehijos==0 & miemh==2


*Nuclear*
*Tomando las vriables "miemr#", puedo generar la variable nuclear*
gen nuclear=0
replace nuclear=1 if r1031==1 & conpareja==1 & numdehijos!=0 & (miemr1034==0 & ///
miemr1035==0 & miemr1036==0 & miemr1037==0 & miemr1038==0 & miemr1039==0 & ///
miemr10310==0 & miemr10311==0)
 
*Sólo familias extensas*
gen extensa=0
replace extensa=1 if r1031==1 & conpareja==1 & numdehijos>=0 & (miemr1034!=0 | ///
miemr1035!=0 | miemr1036!=0 | miemr1037!=0 | miemr1038!=0 | miemr1039!=0 | ///
miemr10310!=0 | miemr10311!=0)
tab extensa if r1031==1 


*Extensa con hijos
gen extconhijos=0
replace extconhijos=1 if r1031==1 & conpareja==1 & numdehijos!=0 & (miemr1034!=0 | ///
miemr1035!=0 | miemr1036!=0 | miemr1037!=0 | miemr1038!=0 | miemr1039!=0 | ///
miemr10310!=0 | miemr10311!=0)

*Extensa sin hijos*
gen extsinhijos=0
replace extsinhijos=1 if r1031==1 & conpareja==1 & numdehijos==0 & (miemr1034!=0 | ///
miemr1035!=0 | miemr1036!=0 | miemr1037!=0 | miemr1038!=0 | miemr1039!=0 | ///
miemr10310!=0 | miemr10311!=0)

*Monoparental*
gen monop=0
replace monop=1 if r1031==1 & conpareja==0 & numdehijos!=0 & (miemr1034==0 & ///
miemr1035==0 & miemr1036==0 & miemr1037==0 & miemr1038==0 & miemr1039==0 & ///
miemr10310==0 & miemr10311==0)

*Monoparental extensa con hijos*
gen monopextconhijos=0
replace monopextconhijos=1 if r1031==1 & conpareja==0 & numdehijos!=0 & (miemr1034!=0 | ///
miemr1035!=0 | miemr1036!=0 | miemr1037!=0 | miemr1038!=0 | miemr1039!=0 | ///
miemr10310!=0 | miemr10311!=0)

*Monoparental extensa sin hijos*
gen monopextsinhijos=0
replace monopextsinhijos=1 if r1031==1 & conpareja==0 & numdehijos==0 & (miemr1034!=0 | ///
miemr1035!=0 | miemr1036!=0 | miemr1037!=0 | miemr1038!=0 | miemr1039!=0 | ///
miemr10310!=0 | miemr10311!=0)



/*
Estado familiar (i.e. acompañado, casado, viudo, divorciado, separado, soltero)
*/
tab r107 if r1031==1 [w=fac00]
tab r107 sexo if r1031==1 [w=fac00]

/*
Fertilidad (mujeres como jefes o pareja en el hogar)
*/
gen fertil=0
replace fertil=1 if (r106>=15 & r106<=44) & sexo==1 & (r1031==1 | r1032==1)
*Por hogar*
bys idboleta: egen hogfertil=max(fertil)


/*
Hogares fertiles con o sin hijos 
Aquellos hogares que son fertiles (el jefe de hogar o esposa/pareja tiene entre 
15 y 44 años) y ya tienen hijos
*/
*Hogar fertil con hijos*
gen hogfertilhijos=0 
replace hogfertilhijos=1 if (fertil==1 & numdehijos!=0)
bys idboleta: egen hfconhijos= max(hogfertilhijos)

*Hogar fertil sin hijos*
gen hogfertilsinhijos=0 
replace hogfertilsinhijos=1 if (fertil==1 & numdehijos==0)
bys idboleta: egen hfsinhijos= max(hogfertilsinhijos)

*Desagregación dentro de hogares fértiles
*Del total de hogares fertiles cuáles son hogares fertiles con hijos y sin hijos*
tab hogfertil hfsinhijos if r1031==1
tab hogfertil hfconhijos if r1031==1

/*
Hogares con hijos
*/
gen conhijos=0
replace conhijos=1 if numdehijos!=0
bys idboleta: egen hogconhijos= max(conhijos)


*Generar quintiles en base al ingreso del hogar por familia, pues incluye TODO*
xtile quintil=ingfa [pw=fac00] if r1031==1, n(5)

*******************************************************************************
*******************************************************************************
/*
II. CARACTERIZACIONES DE LOS HOGARES
Unidades de análisis:
1.	Los hogares en general en El Salvador
2.	Hogares con hijos
3.	Hogares fértiles con hijos
4.	Hogares que viven en pobreza con hijos
Datos para caracterización:
	Jefatura
	Grupos de edad
	Lugar de residencia (desagregaciones a nivel urbano-rural y departamental)
	Escolaridad
	Empleo
	Hábitat y vivienda
	Esparcimiento
	Abandono y migración
	Niveles de pobreza y privaciones multidimensionales
*/
*******************************************************************************
*******************************************************************************
*Edades* 
gen rangosedad=.
replace rangosedad=1 if r106>=15 & r106<25
replace rangosedad=2 if r106>=25 & r106<35
replace rangosedad=3 if r106>=35 & r106<45
replace rangosedad=4 if r106>=45 & r106<55
replace rangosedad=5 if r106>=55 & r106<65
replace rangosedad=6 if r106>=65
label define rangosedad 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65 o más" 
label value rangosedad rangosedad
label variable rangosedad "Rangos de edad"
tab rangosedad if r1031==1

*Esparcimiento*
*Generar una variable para lugar de esparcimiento y si se hace uso de ese lugar*
gen esparcimiento=0
replace esparcimiento=1 if r1116_01==1 | r1116_02==1 | r1116_03==1 ///
| r1116_04==1 | r1116_05==1
label var esparcimiento "Existe en la comunidad algún lugar de esparcimiento"
label define esparcimiento 1 "Si" 0 "No"
label values esparcimiento esparcimiento
tab esparcimiento if r1031==1

gen usoesparc=0
replace usoesparc=1 if r1117_01==1 | r1117_02==1 | r1117_03==1 ///
| r1117_04==1 | r1117_05==1
label var usoesparc "Hace uso de ese lugar de esparcimiento"
label define usoesparc 1 "Si" 0 "No"
label values usoesparc usoesparc
tab usoesparc if r1031==1 & esparcimiento==1

*******************************************************************************
*******************************************************************************
*Empleo

*TRABAJO DECENTE 2016                                

** Para medir el trabajo decente se requiere seguir los siguientes pasos
** 1) Identificar a los subempleados (de los dos tipos a nivel nacional)
** 2) Identificar ocupados plenos
** 3) Identificar remuneraciÃ³n justa (Canasta BÃ¡sica de mercado)
** 4) Identificar si cuenta con un contrato (para los tipos de ocupaciÃ³n que aplique)
** 5) Identificar si se posee afiliaciÃ³n con seguridad social
** 6) AgregaciÃ³n
		** Para que una persona tenga trabajo decente debe cumplir al menos 1 de las siguientes condiciones
			** A) Ser ocupado pleno con remuneraciÃ³n justa
			** B) Ser ocupado pleno con protecciÃ³n social (incluyendo contrato para las categorÃ­as aplicables y seguridad social)

/*SALARIOS MÍNIMOS PARA 2016:
COMERCIO: $251.70
INDUSTRIA: $246.60
MAQUILA: $210.90
AGRÍCOLA $118.20

Fuente:
https://www2.deloitte.com/content/dam/Deloitte/sv/Documents/tax/ELSALVADOR/NotasFiscales/170105-sv-TaxAlert-Incremento-al-salario-minimo.pdf			
http://www.mtps.gob.sv/noticias/conoce-los-decretos-incremento-del-salario-minimo/			
*/			
***********************************************************************
***** PASO 1: SUBEMPLEO                                           *****
***********************************************************************
** IdentificaciÃ³n de los miembros que aplican para el cÃ¡lculo
	gen iden_miem=0
** Aplican todos los miembros del hogar de 16 o mÃ¡s aÃ±os pertenecientes a la PEA a excepciÃ³n de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
	replace iden_miem=1 if r106>=16 & r106!=. & actpr<30 // El subempleo se calcula según la metodología oficial utilizada para estimar la pobreza multidimensional, pero se incluyen a las empleadas domésticas y sus hijos ya que se analiza la situación del empleo a nivel de personas y no de hogares.

** DefiniciÃ³n del salario mÃ­nimo por ocupaciÃ³n para el aÃ±o 2014.
	 recode r416 (111/333=1) (510/1200=2) (1511/4390=2) (5811/5920=2) (1311/1430=3) (4510/5630=4) (6010/9900=4), gen(SECTOR) 
	 gen SALA_MIN=0
		 replace SALA_MIN=251.70 if SECTOR==4 /* Comercio y Servicio */
		 replace SALA_MIN=246.60 if SECTOR==2 /* Trabajadores industriales */
		 replace SALA_MIN=210.90 if SECTOR==3 /* Maquila textil y confecciÃ³n */
		 replace SALA_MIN=118.20 if SECTOR==1 /* Trabajadores agropecuarios */ 

	** Umbrales que identifican a las personas subempleadas
		gen subempleado=0

	** Subempleado por tiempo, si trabaja menos de 40 horas debido a que solo encontrÃ³ trabajo a tiempo parcial, reducciÃ³n de actividades o falta de trabajo.
		replace subempleado=1 if iden_miem==1 & actpr==10 & (r413==2|r413==3) 

	** Subempleado por ingreso, si trabaja mÃ¡s de 40 horas pero su salario es menor al salario mÃ­nimo.
		replace subempleado=1 if iden_miem==1 & actpr==10 & money<SALA_MIN 


***********************************************************************
***** PASO 2: Ocupados plenos                                     *****
***********************************************************************
** CreaciÃ³n de variable que clasifica a los ocupados (Subempleados y ocupados plenos)
	gen tipo_ocupado=.
	replace tipo_ocupado=1 if subempleado==0 & iden_miem==1 & actpr==10	
	replace tipo_ocupado=2 if subempleado==1 & iden_miem==1 & actpr==10
	label define tipo_ocupado 1 "Ocupado pleno" 2 "Subempleado"
	label values tipo_ocupado tipo_ocupado

	
***********************************************************************
***** PASO 3: Identificar la remuneraciÃ³n justa                  *****
***********************************************************************
** CreaciÃ³n de variable que muestra la Canasta BÃ¡sica de Mercado
/*
Canasta básica de mercado para 2016, obtener dato
*/

	gen CBM=.
	replace CBM=840.08 if area==1
	replace CBM=601.32 if area==0


***********************************************************************
***** PASO 4: Identificar si se cuenta con un contrato (si aplica)*****
***********************************************************************
** Este indicador aplica Ãºnicamente para: Asalariado permanente, asalariado temporal, aprendiz, servicio domÃ©stico, otros (R418)
	gen contrato_aplica=.
	replace contrato_aplica=1 if r418>=6 & tipo_ocupado!=.
	replace contrato_aplica=0 if r418<6 & tipo_ocupado!=.
	label variable contrato_aplica "Contrato aplicable para la definiciÃ³n"

	
***********************************************************************
***** PASO 5: Identificar si se cuenta con seguridad social       *****
***********************************************************************
** CreaciÃ³n de variable de afiliaciÃ³n al sistema de seguridad social
	gen seguridad_social=.
	replace seguridad_social=1 if (r422a==2 | r422b==2 | r422c==2 | r422d==2 | r422e==2 | r422f==2 | r422g==2) & tipo_ocupado!=.


***********************************************************************
***** PASO 6: AgregaciÃ³n                                         *****
***********************************************************************
** Para que una persona tenga trabajo decente debe cumplir al menos 1 de las siguientes condiciones
	** A) Ser ocupado pleno con remuneraciÃ³n justa
		gen trabajo_decente=.
		replace trabajo_decente=1 if tipo_ocupado==1 & money>CBM
		
	** B) Ser ocupado pleno con protecciÃ³n social (incluyendo contrato para las categorÃ­as aplicables y seguridad social)
		** Para las ocupaciones que no requieren contrato
			replace trabajo_decente=1 if tipo_ocupado==1 & seguridad_social==1 & contrato_aplica==0
		** Para las ocupaciones que requieren contrato
			replace trabajo_decente=1 if tipo_ocupado==1 & seguridad_social==1 & contrato_aplica==1 & r419<7

** Identificar a los miembros de la PEA sin trabajo decente
	replace trabajo_decente=0 if iden_miem==1 & trabajo_decente==.
	tab trabajo_decente [w=fac00]

	
***Para grafica.
gen graf=0
replace graf=1 if actpr==30 & r1031==1
replace graf=1 if actpr>=20 & actpr<30 
replace graf=2 if tipo_ocupado==2
replace graf=3 if tipo_ocupado==1 
replace graf=4 if trabajo_decente==1 
label define graf 1 "Aquellos que son desocupados ocultos o inactivos" 2 "Subempleado" 3 "Empleado pleno" 4 "Trabajo decente"
label values graf graf
tab graf if iden_miem==1 & r1031==1 [w=fac00] 
tab actpr if iden_miem==1 & r1031==1 [w=fac00] 

drop iden_miem
drop SECTOR
drop SALA_MIN
*******************************************************************************

************************************************************************************
************************************************************************************
/*
POBREZA MULTIDIMENSIONAL
*/
************************************************************************************
************************************************************************************

**** ESTABLECIMIENTO DE LA INFORMACIÓN MUESTRAL.

*** Al ser la base de datos resultado de una muestra compleja se define las variables que caracterizan la muestra. Donde, los segmentos muéstrales son identificados por la variable "CORRELATIVO", el factor de expansión por la variable "fac00" y el estrato por "ESTRATO_EHPM".

 svyset correlativo [pw=fac00], strata (estratoarea)

**********************************************************************************
*************************** DIMENSIÓN 1: EDUCACIÓN ****************************
**********************************************************************************

**************************************************
***** INDICADOR 1.1: INASISTENCIA ESCOLAR *****
**************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 1.1.
 gen iden_miem=0
  
 * Aplican todos los miembros del hogar entre las edades de 4 a 17 años (incluyendo ambos años) a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
 replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & (r106>=4 & r106<=17)


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 1.1.
 gen ind_1_1_i=0

* Si nunca ha asistido a un centro de enseñanza.
  replace ind_1_1_i=1 if iden_miem==1 & r203==2 & r213==2

* No está estudiando actualmente y si ha asistido alguna vez a un centro de enseñanza, pero no completo ningún nivel.
  replace ind_1_1_i=1 if iden_miem==1 & r203==2 & r213==1 & r215a==8

* No está estudiando actualmente y si ha asistido alguna vez a un centro de enseñanza, pero el nivel máximo de educación alcanzado es menor a bachillerato.
  replace ind_1_1_i=1 if iden_miem==1 & r203==2 & r213==1 & (r215a>=1 & r215a<=3) & r215b<=10


**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 1.1.
  sort idboleta
  by idboleta: egen ind_1_1=max(ind_1_1_i)


**** RESULTADOS DEL INDICADOR 1.1.

*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_1_1 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** Eliminación de las variables creadas.
 drop  iden_miem ind_1_1_i


*********************************************** 
***** INDICADOR 1.2: REZAGO EDUCATIVO *****
***********************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 1.2.
 gen iden_miem=0
  
* Aplican todos los miembros del hogar entre las edades de 10 a 17 años (incluyendo ambos años) a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
 replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & (r106>=10 & r106<=17)
  
 
**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 1.2.
 gen ind_1_2_i=0

 * Si está estudiando y el nivel que está cursando es menor a educación básica.
  replace ind_1_2_i=1 if iden_miem==1 & r203==1 & r204g<2

 * Si está estudiando y el grado que está cursando es menor al optimo según el Ministerio de Educación, para ello se construyó la formula (r106-R205>=9).
  replace ind_1_2_i=1 if iden_miem==1 & r203==1 & r204==2 & (r106-r204g>=9) & (r106-r204g!=.)
  
  
**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 1.2.
  sort idboleta
  by idboleta: egen ind_1_2=max(ind_1_2_i)


**** RESULTADOS DEL INDICADOR 1.2.

*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_1_2 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop iden_miem ind_1_2_i


********************************************************** 
***** INDICADOR 1.3: CUIDO TEMPRANO INADECUADO *****
**********************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 1.3.
 gen iden_miem=0
  
* Aplican todos los miembros del hogar entre las edades de 1 a 3 años (incluyendo ambos años) a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
  replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & r106>=1 & r106<=3

  
**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 1.3.
 gen ind_1_3_i=0

 * Niño de 1 a 3 años no asisten a educación inicial.
  replace ind_1_3_i=1 if iden_miem==1 & r201a==2


**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 1.3.
  sort idboleta
  by idboleta: egen ind_1_3=max(ind_1_3_i)


**** RESULTADOS DEL INDICADOR 1.3.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_1_3 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop iden_miem ind_1_3_i


*********************************************************
***** INDICADOR 1.4: BAJA EDUCACIÓN DE ADULTOS *****
*********************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 1.4.
 gen iden_miem=0
  
 * Aplican todos los miembros del hogar de 18 o más años a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
  replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & r106>=18 & r106!=.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 1.4.
 gen ind_1_4_i=0

 * Si la edad es mayor de 64 años y no está estudiando ni nunca ha asistido a la escuela.
 replace ind_1_4_i=1 if iden_miem==1 & r106>64 & r106!=. & r203==2 & r213==2

 * Si la edad es mayor de 64 años y no está estudiando y el grado máximo alcanzado es menor a sexto grado.
 replace ind_1_4_i=1 if iden_miem==1 & r106>64 & r106!=. & r203==2 & r213==1 & (r215a<3 | r215a==8) & (r215b<6 | r215b==.)
  
 * Si la edad es mayor de 64 años y si está estudiando y el grado que está estudiando es menor a sexto grado.
 replace ind_1_4_i=1 if iden_miem==1 & r106>64 & r106!=. & r203==1 & r204<3 & r204g<6

 * Si la edad es menor o igual a 64 años y no está estudiando ni nunca ha asistido a la escuela.
 replace ind_1_4_i=1 if iden_miem==1 & r106<=64 & r203==2 & r213==2

 * Si la edad es menor o igual a 64 años y no está estudiando y el grado máximo alcanzado es menor a bachillerato
 replace ind_1_4_i=1 if iden_miem==1 & r106<=64 & r203==2 & r213==1 & (r215a<=3 | r215a==8) & (r217==1 | r217==.)
  
 * Si la edad es menor o igual a 64 años y si está estudiando y el grado que está estudiando es menor a segundo año de bachillerato.
 replace ind_1_4_i=1 if iden_miem==1 & r106<=64 & r203==1 & r204<=3 & r204g<=10


**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 1.4.
  sort idboleta
  by idboleta: egen ind_1_4=max(ind_1_4_i)


**** RESULTADOS DEL INDICADOR 1.4.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_1_4 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop  iden_miem ind_1_4_i


**********************************************************************************
****************** DIMENSIÓN 2: CONDICIONES DE LA VIVIENDA *******************
**********************************************************************************

****************************************************************
***** INDICADOR 2.1: MATERIALES INADECUADOS DE TECHO *****
****************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 2.1.
  gen ind_2_1=0

  * Si el techo está en mal estado, no importante el material.
  replace ind_2_1=1 if r302b==2

  * Si el techo es de paja o palma, materiales de desecho y otros materiales.
  replace ind_2_1=1 if r302==5 | r302==6 | r302==7

  
**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 2.1.

*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_2_1 if r103==1
 
  
**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** No existen variables que eliminar.


*************************************************************************
***** INDICADOR 2.2: MATERIALES INADECUADOS DE PISO Y PAREDES *****
*************************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 2.2.
 gen ind_2_2=0

  * Si el piso es de tierra u otros materiales.
 replace ind_2_2=1 if r304==5 | r304==6

  * Si las paredes están en mal estado, no importante el material.
 replace ind_2_2=1 if r303b==2

  * Si las paredes son de madera, lámina metálica, paja o palma, material de desecho u otros materiales.
replace ind_2_2=1 if r303>3 & r303!=.

 
**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 2.2.
  
*** Porcentaje de hogares privados a nivel nacional.
 svy: mean ind_2_2 if r103==1
 

**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** No existen variables que eliminar.


******************************************
***** INDICADOR 2.3: HACINAMIENTO *****
******************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 2.3.
gen ind_2_3=0

 * Si el hogar distribuye 3 o más miembros por dormitorio.
replace ind_2_3=1 if (r306/miemh)<0.34


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 2.3.
  
*** Porcentaje de hogares privados a nivel nacional. 
  svy: mean ind_2_3 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** No existen variables que eliminar.



**********************************************************************
***** INDICADOR 2.4: INSEGURIDAD EN LA TENENCIA DEL TERRENO *****
**********************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 2.4.
gen ind_2_4=0

 * Si es propietario de la vivienda en terreno público o privado o es colono o guardián de la vivienda.
replace ind_2_4=1 if r308>=4 & r308<=7


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 2.4.
  
*** Porcentaje de hogares privados a nivel nacional.
 svy: mean ind_2_4 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** No existen variables que eliminar.


**********************************************************************************
****************** DIMENSIÓN 3: TRABAJO Y SEGURIDAD SOCIAL ******************
**********************************************************************************

***********************************************************************
***** INDICADOR 3.1: SUBEMPLEO E INESTABILIDAD EN EL TRABAJO *****
***********************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 3.1.
gen iden_miem=0
  
 * Aplican todos los miembros del hogar de 16 o más años pertenecientes a la PEA a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
 replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & r106>=16 & r106!=. & actpr<30


**** UMBRALES.

*** Definición del salario mínimo por ocupación para el año 2014.
 recode r416 (111/333=1) (510/1200=2) (1511/4390=2) (5811/5920=2) (1311/1430=3) (4510/5630=4) (6010/9900=4), gen(SECTOR)
 gen SALA_MIN=0
 replace SALA_MIN=118.20 if SECTOR==1 /* Trabajadores agropecuarios */
 replace SALA_MIN=246.60 if SECTOR==2 /* Trabajadores industriales */
 replace SALA_MIN=210.90 if SECTOR==3 /* Maquila textil y confección */
 replace SALA_MIN=251.70 if SECTOR==4 /* Comercio y Servicio */
 


*** Umbrales que identifican a los miembros con privación en el indicador 3.1.
 gen ind_3_1_i=0

 * Subempleado por tiempo, si trabaja menos de 40 horas debido a que solo encontró trabajo a tiempo parcial, reducción de actividades o falta de trabajo.
 replace ind_3_1_i=1 if iden_miem==1 & actpr==10 & (r413==2|r413==3)

 * Subempleado por ingreso, si trabaja más de 40 horas pero su salario es menor al salario mínimo.
 replace ind_3_1_i=1 if iden_miem==1 & actpr==10 & r413a!=. & money<SALA_MIN

 * Si no es asalariado permanente dado que no encuentra trabajo de este tipo.
  replace ind_3_1_i=1 if iden_miem==1 & actpr==10 & r418a==1

 * Si no consigue trabajo por el tipo de ocupación por más de un mes al año.
  replace ind_3_1_i=1 if iden_miem==1 & r445c==1 & r445d>2 & r445d!=.


**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 3.1.
  sort idboleta
  by idboleta: egen ind_3_1=max(ind_3_1_i)


**** RESULTADOS DEL INDICADOR 3.1.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_3_1 if r103==1

  
**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop  iden_miem SECTOR SALA_MIN ind_3_1_i 


**************************************
***** INDICADOR 3.2: DESEMPLEO *****
**************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 3.2.
 gen iden_miem=0
  
 * Aplican todos los miembros del hogar de 16 o más años pertenecientes a la PEA a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
 replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & r106>=16 & r106!=. & actpr<30

  
**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 3.2.
 gen ind_3_2_i=0

 * Si esta desempleo según la variable actpr.
 replace ind_3_2_i=1 if iden_miem==1 & (actpr>=20 & actpr<30)

 * Si está ocupado pero ha pasado en los últimos seis meses uno o más meses sin poder trabajar contra su voluntad.
 replace ind_3_2_i=1 if iden_miem==1 & actpr==10 & (r445e==4 | r445e==5)  


**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 3.2.
 sort idboleta
 by idboleta: egen ind_3_2=max(ind_3_2_i)


**** RESULTADOS DEL INDICADOR 3.2.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_3_2 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop  iden_miem ind_3_2_i


******************************************************************
***** INDICADOR 3.3: FALTA DE ACCESO A SEGURIDAD SOCIAL *****
******************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Identificación de los miembros que aplican para el cálculo del indicador 3.3.
 gen iden_miem=0
  
 * Aplican todos los miembros del hogar de 16 o más años ocupados a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
 replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & r106>=16 & r106!=. & actpr==10
  

**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 3.3.
 gen ind_3_3_i=0

 * Si no cotiza o es beneficiario de un seguro medico.
  replace ind_3_3_i=1 if iden_miem==1 & r601==8

 * Si no cotiza al sistema de pensiones.
  replace ind_3_3_i=1 if iden_miem==1 & (r422f==1 | r422f==3) 

**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 3.3.
  sort idboleta
  by idboleta: egen ind_3_3=max(ind_3_3_i)


**** RESULTADOS DEL INDICADOR 3.3.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_3_3 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop  iden_miem ind_3_3_i


********************************************* 
***** INDICADOR 3.4: TRABAJO INFANTIL *****
*********************************************

*** Identificación de los miembros que aplican para el cálculo del indicador 3.4.
 gen iden_miem=0
  
* Aplican todos los miembros del hogar menores a 18 años a excepción de las personas identificadas como empleadas(os) domesticas(os) y sus hijos(as).
  replace iden_miem=1 if ((r103!=10 & r103!=11) | (r103==11 & r103otr!=3)) & r106<18

*** Calculo de variables complementarias para la construcción de trabajo infantil según metodología OIT.

recode r416 (.=.) (100/299=1) (300/399=2) (500/999=3) (1000/3399=4) (3500/3999=5) (4100/4399=6) (4500/4799=7) (5500/5699=7) (4900/5399=8) /*
*/(5900/6399=8) (6400/8299=9) (8400/8439=10) (8500/8599=11) (8600/9699=12) (9700/9899=13), gen(RAMA1)

recode RAMA1 (4=4) (1/3=1) (5/6=14) (7=7) (8/12=14) (13=13) (14 =14), gen(rama2)

recode r106 (5/9=1) (10/13=2) (14/17=3) if (r106>=5 & r106<=17), gen(gedad_nna)

gen ti_rama=1 if ((r106>=5 & r106<=17) & (r416==510 | r416==520 | r416==610 | r416==620 | r416==710 | r416==721 | r416==729 | r416==810 | r416==891 | /*
*/r416==892 | r416==893 | r416==899 | r416==910 | r416==1010 | r416==1910 | r416==1920 | r416==2011 | r416==2012 | r416==2021 | r416==2022 | r416==2029 | /*
*/r416==2310 | r416==2391 | r416==2392 | r416==2393 | r416==2394 | r416==2395 | r416==2396 | r416==2399 | r416==2410 | r416==2420 | r416==2520 | r416==2660 | /*
*/r416==2720 | r416==3520 | r416==3811 | r416==3812 | r416==3821 | r416==3822 | r416==3830 | r416==3900 | r416==4620 | r416==4661 | r416==4690 | r416==4730 | /*
*/r416==4773 | r416==5222 | r416==5224 | r416==5229 | r416==5510 | r416==5590 | r416==5914 | r416==9602 | r416==9609 | r416==9700))

gen ti_ho_sema=r411a if (r106>=5 & r106<=17)

gen ti_dias_sema=d411b if (r106>=5 & r106<=17)

replace ti_ho_sema=r412a if ((r106>=5 & r106<=17) & ti_ho_sema==0)

replace ti_dias_sema=d412b if ((r106>=5 & r106<=17) & ti_dias_sema==0)

gen t1=r411c if ((r106>=5 & r106<=17) & actpr==10)

gen t11=r411f if ((r106>=5 & r106<=17) & actpr==10)

gen t2=r412c if ((r106>=5 & r106<=17) & actpr==10)

gen t22=r412f if ((r106>=5 & r106<=17) & actpr==10)

recode t1 t11 t2 t22 (.=0) if ((r106>=5 & r106<=17) & actpr==10)

gen jornada=(t1*10) + (t11*1) if (r411a>=0 & ti_ho_sema>0 & (r106>=5 & r106<=17)) 

replace jornada=(t1*10) + (t11*1) if (r411a==. & r411d>=1 & ti_ho_sema>0 & (r106>=5 & r106<=17))

replace jornada=(t2*10) + (t22*1) if (r411a==. & r411d==. & ti_ho_sema>0 & (r106>=5 & r106<=17))

recode jornada (1=1) (10/11=1) (2/3=2) (12/33=2), gen(turno)

gen horas_dia=ti_ho_sema/ti_dias_sema

gen ti_rama15=1 if ((r106>=5 & r106<=15) & (r416==510 | r416==520 | r416==610 | r416==620 | r416==710 | r416==721 | r416==729 | r416==810 | r416==891 | /*
*/r416==892 | r416==893 | r416==899 | r416==910 | r416==1010 | r416==1910 | r416==1920 | r416==2011 | r416==2012 | r416==2021 | r416==2022 | r416==2029 | /*
*/r416==2310 | r416==2391 | r416==2392 | r416==2393 | r416==2394 | r416==2395 | r416==2396 | r416==2399 | r416==2410 | r416==2420 | r416==2520 | r416==2660 | /*
*/r416==2720 | r416==3520 | r416==3811 | r416==3812 | r416==3821 | r416==3822 | r416==3830 | r416==3900 | r416==4620 | r416==4661 | r416==4690 | r416==4730 | /*
*/r416==4773 | r416==5222 | r416==5224 | r416==5229 | r416==5510 | r416==5590 | r416==5914 | r416==9602 | r416==9609 | r416==9700))

gen ti_rama16=1 if ((r106==16) & (r416==510 | r416==520 | r416==610 | r416==620 | r416==710 | r416==721 | r416==729 | r416==810 | r416==891 | r416==892 | /*
*/r416==893 | r416==899 | r416==910 | r416==1010 | r416==1910 | r416==1920 | r416==2011 | r416==2012 | r416==2021 | r416==2022 | r416==2029 | r416==2310 | /*
*/r416==2392 | r416==2393 | r416==2394 | r416==2395 | r416==2396 | r416==2399 | r416==2410 | r416==2420 | r416==2520 | r416==2660 | r416==2720 | r416==3520 | /*
*/r416==3811 | r416==3812 | r416==3821 | r416==3822 | r416==3830 | r416==3900 | r416==4620 | r416==4661 | r416==4690 | r416==4730 | r416==4773 | r416==5222 | /*
*/r416==5224 | r416==5229 | r416==5510 | r416==5590 | r416==5914 | r416==9602 | r416==9609 | r416==9700))

gen ti_rama17=1 if ((r106==17) & (r416==510 | r416==520 | r416==610 | r416==620 | r416==710 | r416==721 | r416==729 | r416==810 | r416==891 | r416==892 | /*
*/r416==893 | r416==899 | r416==910 | r416==1010 | r416==1910 | r416==1920 | r416==2011 | r416==2012 | r416==2021 | r416==2022 | r416==2029 | r416==2310 | r416==2392 | /*
*/r416==2393 | r416==2394 | r416==2395 | r416==2396 | r416==2399 | r416==2410 | r416==2420 | r416==2520 | r416==2660 | r416==2720 | r416==3520 | r416==3811 | r416==3812 | /*
*/r416==3821 | r416==3822 | r416==3830 | r416==3900 | r416==4620 | r416==4661 | r416==4690 | r416==4730 | r416==4773 | r416==5222 | r416==5224 | r416==5229 | r416==5510 | /*
*/r416==5590 | r416==5914 | r416==9602 | r416==9609))

recode ti_rama15 ti_rama16 ti_rama17 (.=0) if ((r106>=5 & r106<=17) & actpr==10)

gen SUM_CIIU=ti_rama15 + ti_rama16 + ti_rama17

gen ti_ocupa=1 if ((r106>=5 & r106<=17) & (SUM_CIIU==0) & (r414==110 | r414==3473 | r414==5112 | r414==5122 | r414==5133 | r414==5139 | r414==5143 | r414==5161 | /*
*/r414==5162 | r414==5163 | r414==5169 | r414==6152 | r414==6153 | r414==6154 | r414==7112 | r414==7113 | r414==7121 | r414==7122 | r414==7123 | r414==7124 | r414==7129 | /*
*/r414==7131 | r414==7133 | r414==7134 | r414==7135 | r414==7136 | r414==7137 | r414==7211 | r414==7212 | r414==7213 | r414==7214 | r414==7215 | r414==7216 | r414==7221 | /*
*/r414==7224 | r414==7231 | r414==7232 | r414==7233 | r414==7241 | r414==7242 | r414==7243 | r414==7245 | r414==7322 | r414==7331 | r414==7341 | r414==7342 | r414==7344 | /*
*/r414==7346 | r414==7411 | r414==7412 | r414==7421 | r414==7422 | r414==7423 | r414==7424 | r414==7433 | r414==7434 | r414==7435 | r414==7436 | r414==7437 | r414==7441 | /*
*/r414==7442 | r414==8141 | r414==8162 | r414==8211 | r414==8240 | r414==8265 | r414==8273 | r414==8311 | r414==8312 | r414==8321 | r414==8322 | r414==8323 | r414==8324 | /*
*/r414==8331 | r414==8332 | r414==8333 | r414==8334 | r414==9111 | r414==9112 | r414==9142 | r414==9152 | r414==9161 | r414==9162 | r414==9213 | r414==9311 | r414==9312 | /*
*/r414==9313 | r414==9331 | r414==9332 | r414==9333))

gen ti_riesgo1=1 if ((r106>=5 & r106<=17) & (SUM_CIIU==0) & (r414==3474 | r414==6111 | r414==6112 | r414==6113 | r414==6114 | r414==6130 | r414==6141 | r414==6210 | /*
*/r414==9211 | r414==9212) & (r417a01==1 | r417a02==1 | r417a03==1 | r417a04==1 | r417a10==1))

gen tp1=1 if ((r106>=5 & r106<=15) & (ti_rama15==1 | ti_ocupa==1 | ti_riesgo1==1))

replace tp1=1 if ((r106==16) & (ti_rama16==1 | ti_ocupa==1 | ti_riesgo1==1))

replace tp1=1 if ((r106>16 & r106<=17) & (ti_rama17==1 | ti_ocupa==1 | ti_riesgo1==1))

recode tp1 (.=0) if ((r106>=5 & r106<=17) & actpr==10)

gen jornaexceso=1 if ((tp1==0) & (r106>=5 & r106<=17) & (turno==2))

replace jornaexceso=1 if ((tp1==0) & (r106>=5 & r106<=15) & (horas_dia>6 | ti_ho_sema>34) & (turno==1))

replace jornaexceso=1 if ((tp1==0) & (r106>=16 & r106<=17) & (horas_dia>8 | ti_ho_sema>44) & (turno==1))

recode jornaexceso (.=0) if (tp1>=0)

gen tp_fin=tp1+jornaexceso

gen TRABAJO_INFANTIL=1 if ((r106>=5 & r106<=13) & actpr==10)
replace TRABAJO_INFANTIL=1 if ((r106>=14 & r106<=17) & tp_fin==1)
replace TRABAJO_INFANTIL=0 if ((r106>=14 & r106<=17) & tp_fin==0)
replace TRABAJO_INFANTIL=2 if ((r106>=5 & r106<=17) & actpr>10)

recode TRABAJO_INFANTIL (0=2) (1=1) (2=0)

gen trabajo_fin=1 if ((r106>=5 & r106<=13) & actpr==10 & ((RAMA1>=1 & RAMA1<=12) | RAMA1==14))

replace trabajo_fin=1 if ((r106>=5 & r106<=16) & actpr==10 & RAMA1==13)

replace trabajo_fin=2 if ((r106>=14 & r106<=17) & ((RAMA1>=1 & RAMA1<=12) | RAMA1==14) & tp_fin==1)

replace trabajo_fin=2 if (r106>16 & RAMA1==13 & tp_fin==1)

replace trabajo_fin=0 if ((r106>=14 & r106<=17) & tp_fin==0)

replace trabajo_fin=3 if ((r106>=5 & r106<=17) & actpr>10)

recode trabajo_fin (0=3) (3=0)


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 3.4.
  gen ind_3_4_i=0

 * Si está considerado en situación de trabajo infantil según la metodología OIT.
   replace ind_3_4_i=1 if iden_miem==1 & (trabajo_fin==1 | trabajo_fin==2)

 * Entre 5 y 13 años que dedican 28 o más horas a trabajo doméstico.
  replace ind_3_4_i=1 if iden_miem==1 & r106<14 & (r445fh1 + (r445fm1/60) + r445fh2 + (r445fm2/60) + r445fh3 + (r445fm3/60) + /*
  */r445fh4 + (r445fm4/60) + r445fh5 + (r445fm5/60))>=28 & (r445fh1 + (r445fm1/60) + r445fh2 + (r445fm2/60) + r445fh3 + /*
  */(r445fm3/60) + r445fh4 + (r445fm4/60) + r445fh5 + (r445fm5/60))!=.


**** AGREGACIÓN A NIVEL HOGAR.

*** Agregación de los hogares con al menos un miembro privado en el indicador 3.4.
  sort idboleta
  by idboleta: egen ind_3_4=max(ind_3_4_i)


**** RESULTADOS DEL INDICADOR 3.4.

*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_3_4 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop iden_miem  RAMA1 rama2 gedad_nna ti_rama ti_ho_sema ti_dias_sema t1 t11 t2 t22 jornada turno horas_dia ti_rama15 ti_rama16 ti_rama17 SUM_CIIU /*
 */ti_ocupa ti_riesgo1 tp1 jornaexceso tp_fin TRABAJO_INFANTIL trabajo_fin ind_3_4_i


**********************************************************************************
***** DIMENSIÓN 4: SALUD, SERVICIOS BÁSICOS Y SEGURIDAD ALIMENTARIA ******
**********************************************************************************

*******************************************************************
***** INDICADOR 4.1: FALTA DE ACCESO A SERVICIOS DE SALUD *****
*******************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 4.1.
 gen ind_4_1_i=0

 * Si no consulto a un médico adecuado y no consulto al sistema público por la mala calidad y otras razones.
 replace ind_4_1_i=1 if r602<=9 & r603>=4 & r603!=. & r611>=1 & r611!=. & r611!=6 & r611!=8 & r611!=13 & r611!=14

 * Si no consulto a un centro de salud adecuado y no consulto al sistema público por la mala calidad y otras razones.
 replace ind_4_1_i=1 if r602<=4 & r604>=8 & r604!=. & r604!=12 & r611>=1 & r611!=. & r611!=6 & r611!=8 & r611!=13 & r611!=14

 * Si consulto a una clínica privada y no consulto al sistema público por la mala calidad y otras razones.
 replace ind_4_1_i=1 if r602<=4 & r604==7 & r611>=1 & r611!=. & r611!=6 & r611!=8 & r611!=13 & r611!=14

 * Si nadie en el hogar se enfermó y si algún miembro se enferma no consultara un centro de salud adecuado y no consultara al sistema público por la mala calidad y otras razones.
 sort idboleta
 by idboleta: egen nadie_enfermo=min(r602)
 replace ind_4_1_i=1 if r612>=8 & r612!=. & r612!=12 & r613>=1 & r613!=. & r613!=6 & r613!=8 & r613!=12 & nadie_enfermo==5

 * Si nadie en el hogar se enfermó y si algún miembro se enferma y consultara una clínica privada y no consultara al sistema público por la mala calidad y otras razones.
  replace ind_4_1_i=1 if r612==7 & r613>=1 & r613!=. & r613!=6 & r613!=8 & r613!=12 & nadie_enfermo==5


*** Agregación de los hogares con al menos un miembro privado en el indicador 4.1.
 sort idboleta
 by idboleta: egen ind_4_1=max(ind_4_1_i)


**** RESULTADOS DEL INDICADOR 4.1.
  
*** Porcentaje de hogares privados a nivel nacional.
 svy: mean ind_4_1 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** Eliminación de las variables creadas.
 drop nadie_enfermo ind_4_1_i


**************************************************************
***** INDICADOR 4.2: FALTA DE ACCESO A AGUA POTABLE *****
**************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.
  
*** Umbrales que identifican a los miembros con privación en el indicador 4.2.
gen ind_4_2=0

 * Si no tiene agua potable o tiene pero no le cae por más de un mes.
 replace ind_4_2=1 if r312>=5 & r312!=.


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 4.2.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_4_2 if r103==1
 

**** PREPARACIÓN PARA OTROS CÁLCULOS.
  
*** No existen variables que eliminar.


*************************************************************
***** INDICADOR 4.3: FALTA DE ACCESO A SANEAMIENTO *****
*************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 4.3.
gen ind_4_3=0

 * Si no tiene servicio sanitario o no lo utiliza.
  replace ind_4_3=1 if r315>=3 & r315!=.

 * Si el servicio sanitario utilizado es una letrina.
  replace ind_4_3=1 if r315<3 & r317>=5 & r317!=.


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 4.3.
  
*** Porcentaje de hogares privados a nivel nacional.
 svy: mean ind_4_3 if r103==1
 

**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** No existen variables que eliminar.


******************************************************
***** INDICADOR 4.4: INSEGURIDAD ALIMENTARIA *****
******************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Recodificación de los valores de las variables.
  replace   r1101= 0    if    r1101==2
  replace   r1102= 0    if    r1102==2
  replace   r1103= 0    if    r1103==2
  replace   r1104= 0    if    r1104==2
  replace   r1105= 0    if    r1105==2
  replace   r1106= 0    if    r1106==2
  replace   r1107= 0    if    r1107==2
  replace   r1108= 0    if    r1108==2
  replace   r1109= 0    if    r1109==2
  replace   r1110= 0    if    r1110==2
  replace   r1111= 0    if    r1111==2
  replace   r1112= 0    if    r1112==2
  replace   r1113= 0    if    r1113==2
  replace   r1114= 0    if    r1114==2
  replace   r1115= 0    if    r1115==2
  
*** Identificación de los hogares con un menor de edad.  
  gen menor=0
    replace menor=1 if r106<18
    sort idboleta
    by idboleta: egen menor_h=max(menor)


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 4.4.
 gen privali=0

 * Conteo de preguntas en las que se respondió que sí, dada la existencia de menores de 18 años o no en el hogar.
  replace privali= r1101 + r1102 + r1103 + r1104 + r1105 + r1106 + r1107 + r1108 + r1109 + r1110 + r1111 + r1112 + r1113 + r1114 + r1115 if menor_h==1
  replace privali= r1101 + r1102 + r1103 + r1104 + r1105 + r1106 + r1107 + r1108 if menor_h==0

 * Estimación de las ELCSA.
 gen ELCSA = 1 if privali==0
   replace ELCSA= 2 if privali>=1 & privali<=3 & menor_h==0
   replace ELCSA= 3 if privali>=4 & privali<=6 & menor_h==0
   replace ELCSA= 4 if privali>=7 & privali<=8 & menor_h==0
   replace ELCSA= 2 if privali>=1 & privali<=5 & menor_h==1
   replace ELCSA= 3 if privali>=6 & privali<=10 & menor_h==1
   replace ELCSA= 4 if privali>=11 & privali<=15 & menor_h==1

 * El umbral del indicador si el resultado de la ELCSA es Inseguridad Alimentaria Moderada o Severa.
 gen ind_4_4=0
  replace ind_4_4=1 if ELCSA>=3 & ELCSA!=.


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 4.4.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_4_4 if r103==1
 

**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** Eliminación de las variables creadas.
drop menor menor_h privali ELCSA


**********************************************************************************
********************** DIMENSIÓN 5: CALIDAD DEL HÁBITAT **********************
**********************************************************************************

****************************************************************************
***** INDICADOR 5.1: FALTA DE ESPACIOS PÚBLICOS DE ESPARCIMIENTO *****
****************************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 5.1.
 gen ind_5_1=0

 * Si no existe ninguno de espacio de recreación en la colonia.
  replace ind_5_1=1 if r1116_01==2 & r1116_02==2 & r1116_03==2 & r1116_04==2 & r1116_05==2

 * Si existe cancha pero no la usan los miembros del hogar por estar muy lejos o no haber actividades que puedan realizar.
  gen espar1=0
  replace espar1=1 if r1116_01==1 & r1117_01==2 & (r1118_01==6 | r1118_01==7)

 * Si existe parque o zona verde pero no la usan los miembros del hogar por estar muy lejos o no haber actividades que puedan realizar.
  gen espar2=0
  replace espar2=1 if r1116_02==1 & r1117_02==2 & (r1118_02==6 | r1118_02==7)

 * Si existe área de juegos pero no la usan los miembros del hogar por estar muy lejos o no haber actividades que puedan realizar.
  gen espar3=0
  replace espar3=1 if r1116_03==1 & r1117_03==2 & (r1118_03==6 | r1118_03==7)

 * Si existe casa comunal pero no la usan los miembros del hogar por estar muy lejos o no haber actividades que puedan realizar.
  gen espar4=0
  replace espar4=1 if r1116_04==1 & r1117_04==2 & (r1118_04==6 | r1118_04==7)
  
 * Si existe otro espacio recreativo pero no la usan los miembros del hogar por estar muy lejos o no haber actividades que puedan realizar.
  gen espar5=0
  replace espar5=1 if r1116_05==1 & r1117_05==2 & (r1118_05==6 | r1118_05==7)

 * Privación si no hay acceso a ninguno de los 5 espacios por estar muy lejos o no haber actividades.
  replace ind_5_1=1 if (espar1==1 & espar2==1 & espar3==1 & espar4==1 & espar5==1)


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 5.1.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_5_1 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** Eliminación de las variables creadas.
drop espar1 espar2 espar3 espar4 espar5


************************************************************
***** INDICADOR 5.2: INCIDENCIA DE CRIMEN Y DELITO *****
************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 5.2.
 gen ind_5_2=0

 * Si fue víctima de robo, hurto, destrucción intencional contra su propiedad o estafa.
  replace ind_5_2=1 if r1119_1==1 | r1119_2==1 | r1119_3==1 | r1119_4==1 | r1119_5==1

 * Si fue víctima de golpes, heridas, lesiones, secuestro, abuso sexual, o mataron a un familiar.
  replace ind_5_2=1 if r1119_6==1 | r1119_7==1 | r1119_8==1 | r1119_9==1 | r1119_10==1 | r1119_11==1


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 5.2.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_5_2 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** No existen variables que eliminar.


**********************************************************************
***** INDICADOR 5.3: RESTRICCIONES DEBIDAS A LA INSEGURIDAD *****
**********************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 5.3.
 gen ind_5_3=0

 * La persona percibe que no puede salir de noche, tener un negocio, dejar la casa sola, dejar salir a jugar a los niños.
 replace ind_5_3=1 if r1120_1==2 | r1120_2==2 | r1120_3==2 | r1120_4==2 | r1120_5==2


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 5.3.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_5_3 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** No existen variables que eliminar.


*************************************************************************
***** INDICADOR 5.4: EXPOSICIÓN A DAÑOS Y RIESGOS AMBIENTALES *****
*************************************************************************

**** IDENTIFICACIÓN DE LOS MIEMBROS Y HOGARES.

*** Aplican todos los miembros y hogares de la muestra.


**** UMBRALES.

*** Umbrales que identifican a los miembros con privación en el indicador 5.4.
 gen ind_5_4=0

 * Ha sufrido de una inundación que le ocasiono daños.
  replace ind_5_4=1 if r327==1 & r3281==1

 * Ha sufrido en la vivienda algún derrumbe.
  replace ind_5_4=1 if r329==1

 * Exposición por cercanía a una cárcava o quebrada.
  replace ind_5_4=1 if r330==1


**** AGREGACIÓN A NIVEL HOGAR.

*** Aplican todos los hogares de la muestra.


**** RESULTADOS DEL INDICADOR 5.4.
  
*** Porcentaje de hogares privados a nivel nacional.
  svy: mean ind_5_4 if r103==1


**** PREPARACIÓN PARA OTROS CÁLCULOS.

*** No existen variables que eliminar.




**********************************************************************************
*********************************  AGREGACIÓN  *********************************
**********************************************************************************

**** Se agregan todos los indicadores para el cálculo del IPM.
gen IPMD= (ind_1_1 + ind_1_2 + ind_1_3 + ind_1_4 + ind_2_1 + ind_2_2 + ind_2_3 + ind_2_4 + ind_3_1 + ind_3_2 + ind_3_3 + ind_3_4 + ind_4_1 + ind_4_2 + ind_4_3 + ind_4_4 + ind_5_1 + ind_5_2 + ind_5_3 + ind_5_4)


**** Identificación de los hogares con 7 o más privaciones.  
 gen PMD=0
  replace PMD=1 if IPMD>=7
tab PMD if r103==1 [w=fac00]

**** Conteo de los indicadores censurado.
 gen IPMD_c=0
  replace IPMD_c= (ind_1_1 + ind_1_2 + ind_1_3 + ind_1_4 + ind_2_1 + ind_2_2 + ind_2_3 + ind_2_4 + ind_3_1 + ind_3_2 + ind_3_3 + ind_3_4 + ind_4_1 + ind_4_2 + ind_4_3 + ind_4_4 + ind_5_1 + ind_5_2 + ind_5_3 + ind_5_4) if IPMD>=7


**** Identificación de los hogares con 7 o más privaciones (censurado).  
 gen PMD_c=0
  replace PMD_c=(IPMD_c/20) if IPMD>=7
tab PMD_c if r103==1

**** Tabulados H, A y IPM (Hogares).
  svy: mean PMD if r103==1
  svy: mean PMD_c if r103==1 & IPMD>=7
  svy: mean PMD_c if r103==1


********************************
***** POBREZA POR INGRESOS *****
********************************

tab pobreza if r103==1 [w=fac00]
tab pobreza [w=fac00]



***********************************************************************************
************************************************************************************
/*
NNA

Caracterización de los NNA en los hogares con hijos

- Número por tramo de edad (desagregaciones urbano-rural y departamental)
- Número promedio (desagregaciones urbano-rural y departamental)
- Edad promedio (desagregaciones urbano-rural y departamental)
- Perfil de educación (desagregaciones urbano-rural y departamental)
- Trabajo infantil (desagregaciones urbano-rural y departamental)
- Esparcimiento (desagregaciones urbano-rural y departamental)
- Abandono y migración

*/
************************************************************************************
************************************************************************************


*Número por tramo de edad*
*1. Hijos menores de edad
gen menores=0
replace menores=1 if r106>=0 & r106<=17 & r1033==1
bys idboleta: egen hijosmenores=sum(menores)
*2. Generación de cohortes de edad
gen cohorte1=0
replace cohorte1=1 if r106>=0 & r106<=3 & r1033==1
label var cohorte1 "NNA entre 0 y 3 años"
bys idboleta: egen hijoscohorte1=sum(cohorte1)

gen cohorte2=0
replace cohorte2=1 if r106>=4 & r106<=7 & r1033==1
label var cohorte2 "NNA entre 4 y 7 años"
bys idboleta: egen hijoscohorte2=sum(cohorte2)

gen cohorte3=0
replace cohorte3=1 if r106>=8 & r106<=17 & r1033==1
label var cohorte3 "NNA entre 8 y 17 años"
bys idboleta: egen hijoscohorte3=sum(cohorte3)

recode r106 (0/3=1) (4/7=2) (8/17=3), gen (cohortemenores)
replace cohortemenores=0 if cohortemenores>=18
label define cohortemenores 1 "0-3 años" 2 "4-7 años" 3 "8-17 años" 
label values cohortemenores cohortemenores

*Edades promedio NNA*
gen edadnna=.
replace edadnna=r106 if r106>=0 & r106<=17 & r1033==1 
bys idboleta: egen promedadnna=mean(edadnna)

*Abandono*
gen nnaabandono=0
replace nnaabandono=1 if r06c==2 | r06c==3 | r06c==4
bys idboleta: egen hogabandono=sum(nnaabandono)
tab hogabandono if r1031==1 & hijosmenores!=0

*Migración*
gen nnamigra=0
replace nnamigra=1 if r06b==4 | r06b==2 | r06b==3
bys idboleta: egen hogmigra=sum(nnamigra)
tab hogmigra if r1031==1 & hijosmenores!=0 
