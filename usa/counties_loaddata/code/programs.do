//////////////////////////////////////////////////////////////////////////////////////////
// Program to produce a normalized file with data at the county level for base year 2010
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop US_counties_normfile
program define US_counties_normfile

	// Area from Tiger data (official US shapefile for 2010)
	insheet using "../input/tl_2010_us_county10.csv", comma clear
	keep geoid10 aland10 intptlat10 intptlon10
	rename (geoid10 aland10 intptlat10 intptlon10) (fips area_km2 lat lon)
	replace area_km2 = area_km2/10^6
	tempfile area
	save `area', replace

	// State name abbreviated
	insheet using "../input/states.csv", comma clear name
	rename state state_name
	tempfile state_abbreviated
	save `state_abbreviated', replace

	// Population from 2010 Census
	insheet using "../input/CO-EST2015-alldata.csv", clear comma
	keep state county stname ctyname census2010pop
	drop if county==0
	gen fips = string(state,"%02.0f") + string(county,"%03.0f")
	destring fips, replace
	rename (stname ctyname census2010pop) (state_name county_name population)

	// Merge
	merge 1:1 fips using `area', keep(3) nogen
	merge m:1 state_name using `state_abbreviated', nogen
	gen full_name = subinstr(county_name," County","",.) + ", " + abbreviation
	drop abbreviation

	// Cosmetics
	label variable fips "State-County FIPS (2 digits for state, 3 for county)"
	label variable state "State FIPS"
	label variable county "County FIPS"
	label variable state_name "State name"
	label variable county_name "County name"
	label variable population "County Population in 2010 Census"
	label variable area_km2 "land area in square km"
	label variable lat "centroid latitude"
	label variable lon "centroid longitude"
	order fips state county state_name county_name full_name population area_km2 lat lon

	save "../output/US_counties_2010.dta", replace

end	// end of US_counties_normfile
