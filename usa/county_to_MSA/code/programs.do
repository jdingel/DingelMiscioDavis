
//////////////////////////////////////////////////////////////////////////////////////////
// Program to merge all aggregation schemes into the county-level normfile
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop combine_msa_schemes
program define combine_msa_schemes
syntax, schemes(namelist) saveas(string)

	use "../input/US_counties_2010.dta", clear

	// always merge OMB-defined statistical areas (this is the baseline)
	merge 1:1 fips using "../input/US_2010_mapping_counties2msa_omb.dta", nogen keep(1 3)
	gen cbsa_metro = cbsa if metro==1
	drop metro
	label variable cbsa "OMB-defined metropolitan and micropolitan statistical areas"
	label variable cbsa_metro "OMB-define metropolitan statistical areas only"
	local mylist "`mylist' cbsa_metro cbsa"

	// merge Duranton's MSAs
	if regex("`schemes'","duranton") {

		disp "merging Duranton assignments ..."

		local list_files: dir "../input/" files "Duranton_mapping_*.dta"
		foreach file of local list_files {
			merge 1:1 fips using "../input/`file'", nogen keep(1 3)
		}
	local mylist "`mylist' msa_duranton_*"

	}


	// merge nightlight based MSAs
	if regex("`schemes'","nightlights") {
		tempfile tf_current tf_night
		save "`tf_current'", replace

		import delim "../input/US_county_2010_nightlights.csv", clear
		gen fips = string(statefp10,"%02.0f") + string(countyfp10,"%03.0f")
		destring fips, replace
		save "`tf_night'", replace

		disp "merging nightlight assignments ..."

		use "`tf_current'", clear
		merge 1:1 fips using "`tf_night'", keep(1 3)
		local mylist "`mylist' msa_night_*"
	}

	foreach x of varlist `mylist' {
		bys `x': egen maxpop = max(population) if `x'!=.
		gen `x'_recode = "9" + string(fips,"%05.0f") if population==maxpop
		destring `x'_recode, replace
		gsort `x' -population
		carryforward `x'_recode, replace
		replace `x'_recode = . if `x'==.
		drop `x' maxpop
		ren (`x'_recode) (`x')
	}
	ren cbsa msa_cbsa

	save "`saveas'", replace

end		// end of combine_msa_schemes
