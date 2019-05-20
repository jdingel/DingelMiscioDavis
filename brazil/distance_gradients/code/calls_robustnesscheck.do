//This code is the basis for the following statement in the paper:
//	This is not merely due to the set of microregions containing many more places.
//	Restricting attention to microregions in which the largest municipio is also the largest municipio under the metropolitan areas defined by using a nightlight threshold of 30
//	yields an estimated coefficient of -0.050, which is still meaningfully less than -0.0715.

qui do "programs.do"

tempfile tf_msa10_norm
use municipio6 population area_km2 lon lat msa_night_30 using "../input/municipios_2010_withcoordinates.dta", clear
merge m:1 msa_night_30 using "../input/msa_night_30pop_2010.dta", assert(master match) keep(match) nogen keepusing(totalpop)
gen municipios = 1
collapse (sum) population municipios (firstnm) totalpop, by(msa_night_30)
keep if population>100000 & municipios>1
assert population==totalpop
keep msa_night_30 totalpop
save `tf_msa10_norm', replace

tempfile tf_msamicro_norm
use "../input/msa_microrregiopop_2010.dta", clear
clonevar msa_night_30 = msa_microrregio
merge 1:1 msa_night_30 using `tf_msa10_norm', keep(match) nogen
drop msa_night_30
save `tf_msamicro_norm'

tempfile tf_municipios_norm
use "../input/municipios_2010_withcoordinates.dta", clear
merge m:1 msa_microrregio using  `tf_msamicro_norm', assert(master match) keep(match) nogen keepusing(msa_microrregio)
save `tf_municipios_norm', replace

distance_gradients, geospatialnormfile(`tf_municipios_norm') ///
geovar(municipio6) geopop(population) geoarea(area_km2) geolon(lon) geolat(lat) ///
msavar(msa_microrregio) msavarnormfile(`tf_msamicro_norm') ///
characteristic(college) keepif(totalpop>100000) secvar(edu) ///
geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010) geovarsecvarpop(edupop) ///
tablefilename(../output/distance_gradient_college_microregion_alt) ctitle(Microregions)
