
//////////////////////////////////////////////////////////////////////////////////////////
// Program to compare MSAs constructed with different schemes (for Table)
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop msa_compare
program define msa_compare
syntax, normfile(string) base(string) comparison(string)

	tempfile msa_compare

	//Produce one-to-one assignments 
	tempfile tf_assignment
	use population `base' `comparison' if missing(`base')==0 & missing(`comparison')==0 using "`normfile'", clear
	collapse (sum) population, by(`base' `comparison')
	tempvar largest_component largest_assignment
	gsort `comparison' -population
	by `comparison': gen `largest_component' = (_n==1)
	gsort `base' -population
	by `base': gen `largest_assignment' = (_n==1)
	keep if `largest_component'==1 & `largest_assignment'==1
	keep `base' `comparison'
	save `tf_assignment'

	//Produce population and land area for base and comparison
	tempfile tf_`base' tf_`comparison'
	foreach x in `base' `comparison' {
		use if missing(`x')==0 using "`normfile'", clear
		collapse (sum) population_`x' = population area, by(`x')
		gen lpop_`x' = log(population)
		gen larea_`x' = log(area)
		save `tf_`x''
	}

	//Merge and compare
	use `tf_`base'', clear
	merge 1:1 `base' using `tf_assignment', assert(master match) keep(match) nogen
	keep if inrange(population,100000,.)
	egen tot_popbaseline = total(population)
	merge 1:1 `comparison' using `tf_`comparison'', assert(using match) keep(match) nogen
	recode population_`comparison' (. = 0)
	gen displacement_`comparison' = abs(population_`comparison' - population_`base') / (2 * max(population_`comparison', population_`base'))
	gen N_compared = _N
	save `msa_compare', replace

	collapse (mean) displacement = displacement_* (firstnm) N_compared
	gen base = "`base'"
	gen comparison = "`comparison'"
	tempfile displacement_compare
	save `displacement_compare', replace

	tempfile correlation_compare
	use `msa_compare', replace
	corr lpop_`base' lpop_`comparison'*, wrap
	matrix C = r(C)
	local corr_pop = C[2,1]

	corr larea_`base' larea_`comparison'*, wrap
	matrix C = r(C)
	local corr_area = C[2,1]

	use `displacement_compare', clear
	gen correlation_population = `corr_pop'
	gen correlation_landarea   = `corr_area'

	order base comparison, first

end		// end of msa_compare


capture program drop ranksize_coefficients
program define ranksize_coefficients
syntax, population(varname) geounitvar(varname) minimumpopulation(real) saveas(string)

//This program generates a plot of log rank against log size to examine a city-size distribution in terms of Zipf's law

//Preserve the data in memory before manipulating it
tempfile tf_original
save `tf_original', replace

//Generate log rank and log size variables
drop if missing(`geounitvar')==1
collapse (firstnm) `population', by(`geounitvar') // collapse data
egen rank = rank(-`population') // create rank
keep if `population'>=`minimumpopulation'
gen logpop = log(`population')
gen logrank = log(rank-0.5)

//Make a log rank vs log size plot

reg logrank logpop
local r2: display %5.3f `e(r2)'
local beta: display %5.3f _b[logpop]
local observations = `e(N)'

clear
set obs 1
gen str geounitvar = "`geounitvar'"
gen r2 = `r2'
gen beta = `beta'
gen observations = `observations'

cap confirm file "`saveas'"
if (_rc==0) append using "`saveas'"
save "`saveas'", replace

//Restore original data
use `tf_original', clear //Restore the data as it was when the program was invoked

end
