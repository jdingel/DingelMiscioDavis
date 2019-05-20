set more off
qui do "estimationarrays.do"

// Townships 2000
// (1) Produce more aggregated educational tempfile
tempfile tf_educ_agg_townships_2000 educ_agg_townships_2000_msa100k
use "../input/pop_by_educ_townships_2000.dta", clear
gen educ_agg = educ_cat
recode educ_agg 1=1 2=1 3=1 4=2 5=3 6=3 7=4 8=4 9=4
label define educ_agg 1 "Primary school or less" 2 "Middle school" 3 "High school" 4 "College or university"
label values educ_agg educ_agg
save `tf_educ_agg_townships_2000', replace

// NTL
foreach x in 10 30 50 {
	local replace = ""
	if "msa`x'_night" == "msa10_night" local replace = "replace"

	//(2) Produce MSA population file
		tempfile tf_town_pop_msa`x'_night
		use "../input/townships_2000.dta", clear
		collapse (sum) totalpop=population, by(msa`x'_night)
		label variable totalpop "MSA population in 2000"
		label data "MSA populations in 2000"
		save `tf_town_pop_msa`x'_night', replace

	//(3) Call population elasticity program for aggregated educational categories
	estimationarray_elasticities, geovarsecvarnormfile(`tf_educ_agg_townships_2000') ///
			geovarmsavarnormfile(../input/townships_2000.dta) ///
			msavarnormfile(`tf_town_pop_msa`x'_night') ///
			geovar(gbtown) secvar(educ_agg) msavar(msa`x'_night) geosecpop(pop_educ) msapop(totalpop) ///
			keepif(totalpop>=100000) ///
			tablefilename(../output/popelast_eduagg_2000_100k_townships_counties_raw) `replace' ctitle(Township-based, `x')
}

// Counties 2000
//(1) create geovarsecvarnormfile
tempfile tf_educ_agg_counties_2000 educ_agg_counties_2000_msa100k
use "../input/pop_by_educ_counties_2000.dta", clear
gen educ_agg = educ_cat
recode educ_agg 1=1 2=1 3=1 4=2 5=3 6=3 7=4 8=4 9=4
label define educ_agg 1 "Primary school or less" 2 "Middle school" 3 "High school" 4 "College or university"
label values educ_agg educ_agg
save `tf_educ_agg_counties_2000', replace

// NTL
foreach x in 10 30 50 {

	//(2) Produce MSA population file
	tempfile tf_county_pop_msa`x'_night
	use "../input/counties_2000.dta", clear
	collapse (sum) totalpop=population, by(msa`x'_night)
	label variable totalpop "MSA population in 2000"
	label data "MSA populations in 2000"
	save `tf_county_pop_msa`x'_night', replace

	//(3) Call population elasticity program for aggregated educational categories
	estimationarray_elasticities, geovarsecvarnormfile(`tf_educ_agg_counties_2000') ///
			geovarmsavarnormfile(../input/counties_2000.dta) ///
			msavarnormfile(`tf_county_pop_msa`x'_night') ///
			geovar(gbcnty) secvar(educ_agg) msavar(msa`x'_night) geosecpop(pop_educ) msapop(totalpop) ///
			keepif(totalpop>=100000) ///
			tablefilename(../output/popelast_eduagg_2000_100k_townships_counties_raw) `replace' ctitle(County-based, `x')
}
