//Created by: Jonathan Dingel, Antonio Miscio, Yue Charles Yuan
//Date: Feb 2016
//Software: Stata 13 or 14
//Purposes: Create population counts by education category normalized file for townships 2000

//POPULATION COUNTS BY EDUCATIONAL CATEGORIES

cap program drop pop_by_edu_townships_2000
program define pop_by_edu_townships_2000

syntax using/, saveas(string)

// import raw data
use  gbtown ename a108004 a108007 a108010 a108013 a108016 a108019 a108022 a108025 a108028 using "`using'", clear

// rename pop counts by educ variables for reshape
rename a1080# pop_educ#, renumber

//each row will be a distinct township-educational combination
reshape long pop_educ, i(gbtown) j(educ_cat)

#delimit;
label define educ_cat_labels 1 "No schooling"
				  2 "Eliminate illiteracy"
				  3 "Primary school"
				  4 "Junior middle school"
				  5 "Senior middle school"
				  6 "Specialized secondary school"
				  7 "Junior college"
				  8 "University"
				  9 "Graduate", replace;
#delimit cr
label values educ_cat educ_cat_labels

// relabel variables to be more informative
label variable gbtown "township id"
label variable ename "township name"
label variable educ_cat "education category"
label variable pop_educ "total population corresponding to the education category"

replace pop_educ = 0 if pop_educ == . //code missing observations as zero

// label data
label data "2000 townships' population counts by education level"

// save the normalized file
saveold "`saveas'", replace

end

cap program drop make_normalized_geoyear
program define make_normalized_geoyear

syntax, geo(string) year(integer) mappings(namelist min=1) saveas(string) raster(string)

if ("`geo'"=="townships") local geo_id = "gbtown"
if ("`geo'"=="counties") local geo_id = "gbcnty"

// Load Chinese Census data for a given administrative level and year
tempfile temp_census
if ("`geo'"=="townships" & `year'==2000) {
	use "../input/all_china_townships_2000.dta", clear
	// This file has 50,503 obs, of which 3 have value 0 for all the variables.
	// One of these 3 (id = 350122206) is in the shapefile also and is an island;
	// the other two (id = 469038450, 469039450) don't appear in the shapefile.
	keep gbtown ename a101004
	rename (ename a101004) (name population)

	drop if missing(gbtown)==1 & missing(population)==1

}

if ("`geo'"=="townships" & `year'==2010) { // YY added 12/19/2016
	insheet using "../input/townships_2010_shapefile.csv", clear
	keep gbcode ename a100001_10
	rename (gbcode ename a100001_10) (gbtown name population)
}

if ("`geo'"=="counties" & `year'==2000) {
	insheet using "../input/county_2000_shapefile.csv", clear
	// This file has 2,876 obs, of which 5 have value 0 for all the variables.
	// Of these, 3 correspond to Hong Kong, Macao and Taiwan (id = 1,2,3).
	// The other 2 (id = 469038 and 469039) are an archipelago of small islands.
	// I drop all of them from the analysis.
	keep gbcnty ename a101004
	rename (ename a101004) (name population)
	drop if (gbcnty<=3 | gbcnty==469038 | gbcnty==469039)
}

if ("`geo'"=="counties" & `year'==2010) {
	use "../input/2010CountyCensusA.dta", clear
	// This file has 2,872 obs, of which 2 have value 0 for all the variables (id = 469032 and 469033).
	// Both are an archipelago of small islands. I drop all of them from the analysis.
	// NB: Hong Kong, Macau and Taiwan are not listed among the counties in 2010.
	keep gbcounty county_en a100001
	rename (gbcounty county_en a100001) (gbcnty name population)
	drop if (gbcnty==469033 | gbcnty==469032)
}

replace name = trim(name)

save `temp_census', replace

foreach x in `mappings' {
	tempfile temp_mapping

	// Load mappings from a given administrative level to different definitions of MSAs
	import delim "../input/`geo'_`year'_NTL`=substr("`x'",4,2)'.csv", clear

	if ("`geo'"=="townships" & `year'==2000) rename (polygon_id gbcode) (`x' gbtown)
	if ("`geo'"=="townships" & `year'==2010) rename (polygon_id gbcode) (`x' gbtown)
	if ("`geo'"=="counties" & `year'==2000) rename polygon_id `x'
	if ("`geo'"=="counties" & `year'==2010) rename (gbcounty polygon_id) (gbcnty `x')
	keep `x' `geo_id'
	save `temp_mapping', replace

	// Combining Census data and MSA mappings
	use `temp_census', replace
	merge 1:1 `geo_id' using `temp_mapping', nogen assert(master match)

	// Create new MSA identifiers = digit "9" + id of largest constituent (e.g. largest township)
	// This is done so we can compare individual MSAs across definition
	// Otherwise the MSA identifiers are meaningless.
	rename `x' temp_`x'
	bys temp_`x': egen temp_max_pop = max(population) if temp_`x'!=.
	gen long `x' = `geo_id' if temp_max_pop == population
	tostring `x', replace
	replace `x' = "9" + `x' if `x'!="."
	destring `x', ignore(.) replace
	format `x' %12.0f

	gsort temp_`x' -population
	by temp_`x': carryforward `x', replace
	drop temp_`x' temp_max_pop

	local rasta = "`raster'"
	if regexm("`x'", "[0-9][0-9]") local threshold = regexs(0)
	label var `x' "Raster = `rasta' data; Threshold = `threshold'."
	notes drop `x'
	notes `x': MSA id = digit 9 + id of most populous component
	save `temp_census', replace

}

// Merge area in sqkm
tempfile area
if ("`geo'"=="townships" & `year'==2000) {
	insheet using "../input/china_`geo'_area_`year'.csv", clear comma
	keep gbcode area_km2 lon lat
	rename gbcode gbtown
	merge 1:1 gbtown using `temp_census', nogen keep(master match)
}
if ("`geo'"=="townships" & `year'==2010) {
	insheet using "../input/china_`geo'_area_`year'.csv", clear comma
	keep gbcode area_km2 lon lat
	rename gbcode gbtown
	duplicates drop
	merge 1:1 gbtown using `temp_census', nogen keep(master match)
}
if ("`geo'"=="counties") {
	insheet using "../input/china_`geo'_area_`year'.csv", clear comma
	if (`year'==2010) rename gbcounty gbcnty
	keep gbcnty area_km2 lon lat
	merge 1:1 gbcnty using `temp_census', nogen keep(master match)
}

label var `geo_id' "`geo' identifier"
label var name "`geo' name"
label var population "`geo' population in year `year'"
if ("`geo'"!="townships" | `year'!=2010) label var area_km2 "area in square kilometers"

// Merge classification of county-level divisions (to replicate geographies used in prior work)
tempfile normfile
save `normfile', replace

if ("`geo'"=="townships" & `year'!=2010) {

	tempfile county_classification
	insheet using "../input/allchina_township_class3.csv", comma clear
	gen type = 3
	replace type = 1 if classen=="Qu"
	replace type = 2 if classen=="City"
	label variable type "1 = urban distict/prefecture-level city, 2 = county-level city, 3 = rural county"
	keep code type
	rename code gbcnty
	save `county_classification'

	use `normfile', clear
	if ("`geo'"=="townships") gen gbcnty = floor(gbtown/1000)
	merge m:1 gbcnty using `county_classification', nogen keep(match)

	gen gbpref = floor(gbcnty/100)

	gen temp_prefecture = gbpref if type==1
	bys temp_prefecture: egen temp_max_pop = max(population) if temp_prefecture!=.
	if ("`geo'"=="townships") gen msa_prefecture = "9" + string(gbtown,"%12.0f") if temp_max_pop == population
	if ("`geo'"=="counties") gen msa_prefecture = "9" + string(gbcnty,"%12.0f") if temp_max_pop == population

	gsort temp_prefecture -population
	by temp_prefecture: carryforward msa_prefecture, replace
	drop temp*
	destring msa_prefecture, ignore(.) replace
	format msa_prefecture %12.0f

}

if ("`geo'"=="townships" & `year'==2010) gen gbcnty = floor(gbtown/1000)

sort `geo_id'
if ("`geo'"!="townships" | `year'!=2010) order `geo_id' population area_km2 lon lat, first
compress

saveold "`saveas'", replace

end		// end of make_normalized_geoyear
