//////////////////////////////////////////////////////////////////////////////////////////
// Program to import official MSA delineations from Office of Management and Budget
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop US_MSA_OMB
program define US_MSA_OMB
syntax, standard(int)

	if 	(`standard'==2009) {
		tempfile cbsa_name mapping
		infix cbsa 1-5 fips 17-22 str name 25-400 in 12/L if (cbsa!=.) using "../input/List1.txt", clear
		save `mapping', replace

		bys cbsa: gen order = _n
		keep if order==1
		keep cbsa name
		rename name cbsa_name
		gen metro = substr(cbsa_name,-29,5)=="Metro"
		replace cbsa_name = subinstr(cbsa_name,"Micropolitan Statistical Area","",.)
		replace cbsa_name = subinstr(cbsa_name,"Metropolitan Statistical Area","",.)
		save `cbsa_name', replace

		use `mapping', replace
		keep if fips!=.
		merge m:1 cbsa using `cbsa_name', nogen
		rename name county_name
	}

	if (`standard'==2013) {
		import excel cbsa = A fips_st = J fips_co = K cbsa_name = D county_name = H metro = E using "../input/List1_2013.xls", clear cellrange(A4)
		gen fips = fips_st + fips_co
		replace metro = "1" if metro=="Metropolitan Statistical Area"
		replace metro = "0" if metro=="Micropolitan Statistical Area"
		destring cbsa fips metro, replace force
		drop if cbsa==.
		keep cbsa cbsa_name county_name metro fips
	}


	// Cosmetics
	compress
	order fips county_name cbsa cbsa_name metro
	label variable fips "State-County FIPS (2 digits for state, 3 for county)"
	label variable county_name "County name"
	label variable cbsa "Core Based Statistical Area defined by Office for Management and Budget"
	label variable cbsa_name "CBSA name"
	label variable metro "dummy = 1 if Metropolitan Area, = 0 if Micropolitan Area"
	save "../output/US_2010_mapping_counties2msa_omb.dta", replace

end 	// end of US_MSA_OMB
