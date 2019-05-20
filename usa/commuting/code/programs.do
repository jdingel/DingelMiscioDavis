
//////////////////////////////////////////////////////////////////////////////////////////
// Program to prepare normfile with commuting flow data from American Community Survey
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop prepare_commuting_ACS
program define prepare_commuting_ACS
syntax using/, saveas(string)
	import excel state_o = A county_o = B state_d = G county_d = H x_od = M using "`using'", sheet("Table 1") cellrange(A7:N137501) clear

	destring *, replace force
	drop if x_od==. | state_d==. | county_d==.
	gen origin = string(state_o,"%02.0f") + string(county_o,"%03.0f")
	gen destin = string(state_d,"%02.0f") + string(county_d,"%03.0f")
	destring origin destin, replace

	order origin state_o county_o destin state_d county_d x_od
	label var origin "fips code of origin (2 for state, 3 for county)"
	label var destin "fips code of destination (2 for state, 3 for county)"
	label var state_o "fips of origin state"
	label var state_d "fips of destination state"
	label var county_o "fips of origin county"
	label var county_d "fips of destination county"
	label var x_od "workers' commuting flow from ACS 2009-2013"
	save "`saveas'", replace

end 		// end of prepare_commuting_ACS

//////////////////////////////////////////////////////////////////////////////////////////
// Program to implement Duranton's (2013) MSA aggregation based on commuting flows
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop Duranton_MSA_aggregation
program define Duranton_MSA_aggregation
syntax, thresh(integer) commuting_file(string) saveas1(string) saveas2(string)

	tempfile updated_commuting_dataset reference reference_steps

	// Input 1: commuting threshold in %
	global k = `thresh'

	// input 2: file with origin, destination, commuting and population by origin
	use "`commuting_file'", clear
	bys origin: egen resident_origin = total(x_od)
	save `updated_commuting_dataset', replace

	keep origin
	rename origin old_geo_id
	duplicates drop
	gen previous_geo_id = old_geo_id
	save `reference', replace

	global i = 1	// start iteration counter, this indexes files taken by iteration i as input
	global to_merge = 1000	// value to initialise loop, any value > 0 is fine
	while $to_merge>0 {

		// We merge a single spatial unit in each iteration, this rules out the possibility that
		// in any one round, i->j while at the same time j->i, or that a i->k while k->j, etc.

		// store origin and destin of pair with largest flow (in % of population at origin)
		use `updated_commuting_dataset', replace
		drop if origin==destin
		gen share = 100 * x_od/resident_origin
		gsort -share
		global old = origin[1]
		global new = destin[1]

		// update aggregation_reference_$k.dta and aggregation_reference_steps_$k.dta
		use `reference', replace
		gen new_geo_id = previous_geo_id
		recode new_geo_id ($old = $new)
		drop previous_geo_id
		rename new_geo_id previous_geo_id
		save `reference', replace

		clear

		set obs 1
		gen step = $i
		gen old = $old
		gen new = $new

		if ($i>1) append using `reference_steps'
		save `reference_steps', replace

		// update file with commuting flows
		use `updated_commuting_dataset', replace
		recode origin destin ($old = $new)
		collapse (sum) x_od, by(origin destin) fast
		bys origin: egen resident_origin = total(x_od)
		save `updated_commuting_dataset', replace

		global i = $i+1
		drop if origin==destin
		gen share = 100*x_od/resident_origin
		count if share!=. & share>=$k
		global to_merge = `r(N)'
	}

	use `reference_steps', clear
	save "`saveas1'", replace

	use `reference', replace
	rename (old_geo_id previous_geo_id) (fips msa_duranton_$k)
	save "`saveas2'", replace

end		// end of Duranton_MSA_aggregation
