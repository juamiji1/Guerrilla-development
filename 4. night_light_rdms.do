/*------------------------------------------------------------------------------
PROJECT: Guerrillas_Development
AUTHOR: JMJR
TOPIC: Spatial RDD of Night Light Density 
DATE:

NOTES: It seems the rdms command accepts no more than around 160 point coordinates
------------------------------------------------------------------------------*/

clear all 

gl do "C:\Users\jmjimenez\Documents\GitHub\Guerrilla-development"
gl path "C:\Users\jmjimenez\Dropbox\Mica-projects\Guerillas_Development"
gl data "${path}\2-Data\Salvador"
gl plots "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\plots"
gl tables "C:\Users\jmjimenez\Dropbox\Apps\Overleaf\GD-draft-slv\tables"
gl maps "${path}\5-Maps\Salvador"

cd ${data}


*-------------------------------------------------------------------------------
* 					Converting shape to dta
*
*-------------------------------------------------------------------------------
*Coverting shape to dta 
shp2dta using "${data}/gis\fmln_zone_point_sample\control_line_sample", data("${data}/control_line_sample.dta") coord("${data}/control_line_sample_coord.dta") genid(pixel_id) genc(coord) replace 
shp2dta using "${data}/gis\fmln_zone_point_sample\expansion_line_sample", data("${data}/expansion_line_sample.dta") coord("${data}/expansion_line_sample_coord.dta") genid(pixel_id) genc(coord) replace 
shp2dta using "${data}/gis\fmln_zone_point_sample\disputa_line_sample", data("${data}/disputa_line_sample.dta") coord("${data}/disputa_line_sample_coord.dta") genid(pixel_id) genc(coord) replace 


*-------------------------------------------------------------------------------
* 					Preparing the data for the RDD with RDMSE
*
*-------------------------------------------------------------------------------
*Loading the data coordinates of the sampled points
use "control_line_sample_coord", clear

*Renaming variables
ren _all, low 
ren (_id _x _y) (pixel_id pnt_x_cntrl pnt_y_cntrl)

*Saving the data
tempfile X
save `X', replace 

*Loading the data coordinates of the sampled points
use "expansion_line_sample_coord", clear

*Renaming variables
ren _all, low 
ren (_id _x _y) (pixel_id pnt_x_xpsn pnt_y_xpsn)

*Saving the data
tempfile Y
save `Y', replace 

*Loading the data coordinates of the sampled points
use "disputa_line_sample_coord", clear

*Renaming variables
ren _all, low 
ren (_id _x _y) (pixel_id pnt_x_dspt pnt_y_dspt)

*Saving the data
tempfile Z
save `Z', replace 

*Loading the data 
*use "nl13Shp_pixels.dta", clear
use "nl13Shp_pixels_info", clear

*Renaming variables
rename (value wthn_cn wthn_xp wthn_ds dst_cnt dst_xpn dst_dsp mean_lv mean_cc mean_bn lake_nt riv1_nt riv2_nt dst_cn2 dst_xp2 dst_ds2 wthn_c2 wthn_x2 wthn_d2 wthn_c3 wthn_x3 wthn_d3 rail_nt road_nt) (nl13_density within_control within_expansion within_disputed dist_control dist_expansion dist_disputed elevation cacao bean lake river1 river2 dist_control_v2 dist_expansion_v2 dist_disputed_v2 within_control_v2 within_expansion_v2 within_disputed_v2 within_control_v3 within_expansion_v3 within_disputed_v3 rail roads)

*Transforming to logs
gen ln_nl13=ln(nl13_density)
gen ln_nl13_plus=ln(nl13_density+0.01)

*Creating hydrography var
gen hydrography=1 if lake==1 | river1==1 | river2==1
replace hydrography=0 if hydrography==.

*Creating infraestructure var
gen rail_road=1 if rail==1 | road==1
replace rail_road=0 if rail_road==.

*Changing units to Kms
replace dist_control=dist_control/1000
replace dist_expansion=dist_expansion/1000
replace dist_disputed=dist_disputed/1000

replace dist_control_v2=dist_control_v2/1000
replace dist_expansion_v2=dist_expansion_v2/1000
replace dist_disputed_v2=dist_disputed_v2/1000

*Fixing the running variables
gen z_run_cntrl= dist_control 
replace z_run_cntrl= -1*dist_control if within_control==0 				//The rdrobust command is coded to indicate treated=(z>=0).

gen z_run_xpsn= dist_expansion 
replace z_run_xpsn= -1*dist_expansion if within_expansion==0

gen z_run_dsptd= dist_disputed 
replace z_run_dsptd= -1*dist_disputed if within_disputed==0

*Creating vars to do some checking 
gen treat_cntrl=(z_run_cntrl>=0)
tabstat z_run_cntrl, by(treat_cntrl) s(N mean sd min max)

*Fixing the running variables (version 2)
gen z_run_cntrl_v2= dist_control_v2 
replace z_run_cntrl_v2= -1*dist_control_v2 if within_control_v2==0 

gen z_run_xpsn_v2= dist_expansion_v2 
replace z_run_xpsn_v2= -1*dist_expansion_v2 if within_expansion_v2==0

gen z_run_dsptd_v2= dist_disputed_v2 
replace z_run_dsptd_v2= -1*dist_disputed_v2 if within_disputed_v2==0

*Labelling for results 
la var nl13_density "Night light density (2013)"
la var z_run_cntrl "Distance to nearest control zone"
la var z_run_xpsn "Distance to nearest expansion zone"
la var z_run_dsptd "Distance to nearest disputed zone"
la var z_run_cntrl_v2 "Distance to nearest control zone (version 2)"
la var z_run_xpsn_v2 "Distance to nearest expansion zone (version 2)"
la var z_run_dsptd_v2 "Distance to nearest disputed zone (version 2)"

*Merging nl grid and polygons 
merge 1:1 pixel_id using `X', nogen 
merge 1:1 pixel_id using `Y', nogen 
merge 1:1 pixel_id using `Z', nogen 


end

*-------------------------------------------------------------------------------
* 						Estimating the RDMSE
*
*-------------------------------------------------------------------------------
*Between pixels within and outside controlled FMLN zones 
cap drop c1 c2
gen c1= pnt_x_cntrl if _n<101
gen c2= pnt_y_cntrl if _n<101

rdms nl13_density x_coord y_coord within_control, c(c1 c2) xnorm(z_run_cntrl)

*Saving relevant info
mat b=e(b)
mat V=e(V)
mat p=e(pv_rb)
mat bw=e(H)
mat N=e(sampsis)

mat b=b'
mat bw=bw' 
mat N=N'

*Creating the se and stars matrixes
mata: V=st_matrix("V")
mata: p=st_matrix("p")
mata: se=diagonal(V)
mata: stars=((p:<=0.1)+(p:<=0.05)+(p:<=0.01))'
mata: stars=stars,J(101,5,0)
mata: st_matrix("se", se)
mata: st_matrix("stars", stars)

*Col and row names
mat out=b,se,bw,N
mat coln out = "Coeff: Bias-corrected" "SE: Robust" "Bw: Left" "Bw: Right" "N: Left" "N: Right"
local rnames: rown out
local rnames=subinstr("`rnames'", "c", "Point",.)
local rnames=subinstr("`rnames'", "pooled", "Pooled",.)
mat rown out=`rnames'

*Exporting results
tempfile X1 X2
frmttable using `X1', s(out) annotate(stars) asymbol(*,**,***) sdec(3,2,2,2,0,0) tex fragment nocenter replace 
filefilter `X1' `X2', from("Point") to("Point ") replace
filefilter `X2' "${tables}\cntrl_rmds.tex", from("r}\BS\BS") to("r}") replace


*Between pixels within FMLN zones and disputed zones (not including pixels in expansion zones)
rdms nl13_density x_coord y_coord within_control if within_expansion==0 & (within_control==1 | within_disputed==1), c(c1 c2) xnorm(z_run_cntrl)
mat b=e(b)
mat V=e(V)
mat p=e(pv_rb)
mat bw=e(H)
mat N=e(sampsis)

mat b=b'
mat bw=bw' 
mat N=N'

*Creating the se and stars matrixes
mata: V=st_matrix("V")
mata: p=st_matrix("p")
mata: se=diagonal(V)
mata: stars=((p:<=0.1)+(p:<=0.05)+(p:<=0.01))'
mata: stars=stars,J(101,5,0)
mata: st_matrix("se", se)
mata: st_matrix("stars", stars)

*Col and row names
mat out=b,se,bw,N
mat coln out = "Coeff: Bias-corrected" "SE: Robust" "Bw: Left" "Bw: Right" "N: Left" "N: Right"
local rnames: rown out
local rnames=subinstr("`rnames'", "c", "Point",.)
local rnames=subinstr("`rnames'", "pooled", "Pooled",.)
mat rown out=`rnames'

*Exporting results
tempfile X1 X2
frmttable using `X1', s(out) annotate(stars) asymbol(*,**,***) sdec(3,2,2,2,0,0) tex fragment nocenter replace 
filefilter `X1' `X2', from("Point") to("Point ") replace
filefilter `X2' "${tables}\cntrl_rmds_cvsd.tex", from("r}\BS\BS") to("r}") replace


*Between pixels within and outside disputed FMLN zones (not including pixels in controlled and expansion zones)
cap drop c1 c2
gen c1= pnt_x_dspt if _n<31
gen c2= pnt_y_dspt if _n<31

rdms nl13_density x_coord y_coord within_disputed if within_expansion==0 & within_control==0, c(c1 c2) xnorm(z_run_dsptd)
mat b=e(b)
mat V=e(V)
mat p=e(pv_rb)
mat bw=e(H)
mat N=e(sampsis)

mat b=b'
mat bw=bw' 
mat N=N'

*Creating the se and stars matrixes
mata: V=st_matrix("V")
mata: p=st_matrix("p")
mata: se=diagonal(V)
mata: stars=((p:<=0.1)+(p:<=0.05)+(p:<=0.01))'
mata: stars=stars,J(31,5,0)
mata: st_matrix("se", se)
mata: st_matrix("stars", stars)

*Col and row names
mat out=b,se,bw,N
mat coln out = "Coeff: Bias-corrected" "SE: Robust" "Bw: Left" "Bw: Right" "N: Left" "N: Right"
local rnames: rown out
local rnames=subinstr("`rnames'", "c", "Point",.)
local rnames=subinstr("`rnames'", "pooled", "Pooled",.)
mat rown out=`rnames'

*Exporting results
tempfile X1 X2
frmttable using `X1', s(out) annotate(stars) asymbol(*,**,***) sdec(3,2,2,2,0,0) tex fragment nocenter replace 
filefilter `X1' `X2', from("Point") to("Point ") replace
filefilter `X2' "${tables}\dsptd_rmds_dvsnd.tex", from("r}\BS\BS") to("r}") replace


*Between pixels within and outside expansion FMLN zones (not including pixels in controlled and disputed zones)
cap drop c1 c2
gen c1= pnt_x_xpsn if _n<101
gen c2= pnt_y_xpsn if _n<101

rdms nl13_density x_coord y_coord within_expansion if within_disputed==0 & within_control==0, c(c1 c2) xnorm(z_run_xpsn)
mat b=e(b)
mat V=e(V)
mat p=e(pv_rb)
mat bw=e(H)
mat N=e(sampsis)

mat b=b'
mat bw=bw' 
mat N=N'

*Creating the se and stars matrixes
mata: V=st_matrix("V")
mata: p=st_matrix("p")
mata: se=diagonal(V)
mata: stars=((p:<=0.1)+(p:<=0.05)+(p:<=0.01))'
mata: stars=stars,J(101,5,0)
mata: st_matrix("se", se)
mata: st_matrix("stars", stars)

*Col and row names
mat out=b,se,bw,N
mat coln out = "Coeff: Bias-corrected" "SE: Robust" "Bw: Left" "Bw: Right" "N: Left" "N: Right"
local rnames: rown out
local rnames=subinstr("`rnames'", "c", "Point",.)
local rnames=subinstr("`rnames'", "pooled", "Pooled",.)
mat rown out=`rnames'

*Exporting results
tempfile X1 X2
frmttable using `X1', s(out) annotate(stars) asymbol(*,**,***) sdec(3,2,2,2,0,0) tex fragment nocenter replace 
filefilter `X1' `X2', from("Point") to("Point ") replace
filefilter `X2' "${tables}\xpsn_rmds_xvsnx.tex", from("r}\BS\BS") to("r}") replace


*-------------------------------------------------------------------------------
* 						Estimating the Dells specification
*
*-------------------------------------------------------------------------------
rdrobust nl13_density z_run_cntrl, all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)


reg nl13_density within_control x_coord y_coord if abs(z_run_cntrl)<=2.897
reg nl13_density i.within_control##c.z_run_cntrl if abs(z_run_cntrl)<=2.897

gen weights=(1-abs(z_run_cntrl/${h})) if z_run_cntrl<0 & z_run_cntrl>=-${h}
replace weights=(1-abs(z_run_cntrl/${h})) if z_run_cntrl>=0 & z_run_cntrl<=${h}

reg nl13_density within_control x_coord y_coord [aw=weights] if abs(z_run_cntrl)<=2.897, r





rdrobust nl13_density , all kernel(triangular)
gl h=e(h_l) 
gl b=e(b_l)

reg nl13_density within_control x_coord y_coord if abs(z_run_cntrl_v2)<=3.346
reg nl13_density i.within_control##c.z_run_cntrl if abs(z_run_cntrl_v2)<=3.346

*Add weights to this!!!





