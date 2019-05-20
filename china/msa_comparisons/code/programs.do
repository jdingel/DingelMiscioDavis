capture program drop build_msa_crosswalk
program define build_msa_crosswalk
syntax, input1(string) ///
				input2(string) ///
				saveas(string)

tempfile tf0
use gbcnty msa*_night msa_prefecture using "`input1'", clear
rename (msa*_night) (msa*_night_cnty)
save `tf0', replace
use "`input2'"
merge m:1 gbcnty using `tf0', nogen assert(match) keep(match)
save `tf0',replace

// Build common metro identifier for prefectures and counties
foreach x of varlist msa*_night_cnty msa_prefecture { // comparisons
	use `tf0', clear
	rename `x' temp_`x'
	bys temp_`x': egen temp_max_pop = max(population) if temp_`x'!=.
	gen long `x' = gbtown if temp_max_pop == population
	tostring `x', replace
	replace `x' = "9" + `x' if `x'!="."
	destring `x', ignore(.) replace
	format `x' %12.0f
	gsort temp_`x' -population
	by temp_`x': carryforward `x', replace
	drop temp*
	unique `x'
	save `tf0', replace
}
save "`saveas'",replace

end

//////////////////////////////////////////////////////////////////////////////////////////
// Program to compare MSAs constructed with different schemes (for Graphic)
//////////////////////////////////////////////////////////////////////////////////////////

cap program drop produce_msa_comparisons
program define produce_msa_comparisons
syntax, msavar(string) msacomparisonfile(string) plotname(string) [ytitle(string)]

if "`ytitle'"=="" local ytitle "baseline metropolitan areas"

use "`msacomparisonfile'", clear

split comparison, parse(_) destring
replace comparison1 = substr(comparison1,4,2)
rename comparison1 threshold
destring threshold, replace

// NTL
twoway ///
(connected correlation_population threshold if comparison2=="night", sort lcol(cranberry) mcol(cranberry) mfcol(cranberry) msymbol(t)) ///
(connected correlation_landarea threshold if comparison2=="night", sort lcol(blue) mlcol(blue) mfcol(white) msymbol(o)), ///
legend(order(1 "Population" 2 "Land area") region(lstyle(none) lcolor(white))) ///
ytitle("Correlation with `ytitle'") ylabel(#6) xtitle("Threshold for light intensity") graphregion(color(white))
graph save "`plotname'_ntl.gph", replace
gr export `plotname'.pdf, as(pdf) replace

end

//////////////////////////////////////////////////////////////////////////////////////////
// Program to compare MSAs constructed with different schemes (for Table)
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop msa_compare
program define msa_compare
syntax, normfile(string) base(string) comparison(string)

	tempfile tf_assignment
	tempfile msa_compare

	use if missing(`base')==0 & missing(`comparison')==0 using "`normfile'", clear
		collapse (sum) population, by(`base' `comparison')
		tempvar largest_component largest_assignment
		gsort `comparison' -population
		by `comparison': gen `largest_component' = (_n==1)
		gsort `base' -population
		by `base': gen `largest_assignment' = (_n==1)
		keep if `largest_component'==1 & `largest_assignment'==1
		keep `base' `comparison'
	save `tf_assignment', replace

	tempfile msa_compare correlation_compare displacement_compare

	// set up MSA traits
	tempfile tf_`base' tf_`comparison'
	foreach x in `base' `comparison' {
		use if missing(`x')==0 using "`normfile'", clear
		collapse (sum) population_`x' = population area_`x' = area_ , by(`x')
		egen N_100k = total (inrange(population,100000,.))
		gen lpop_`x' = log(population_`x')
		gen larea_`x' = log(area_`x')
		save `tf_`x'', replace
	}
	// merge and compare
	use `tf_`base'', clear
	drop N_100k
	merge 1:1 `base' using `tf_assignment', assert(master match) keep(match) nogen
	keep if inrange(population_`base',100000,.)
	egen tot_popbaseline=total(population_`base')
	merge 1:1 `comparison' using `tf_`comparison'', assert(using match) keep(match) nogen keepusing(lpop_`comparison' larea_`comparison' population_`comparison' N_100k)
	recode population_`comparison' (.=0)
	gen displacement_`comparison' = abs(population_`comparison' - population_`base') / (2 * max(population_`comparison', population_`base'))
	gen N_compared = _N
	save `msa_compare', replace

	collapse (mean) displacement = displacement_* (firstnm) N_compared N_100k
	gen base = "`base'"
	gen comparison = "`comparison'"
	save `displacement_compare', replace

	use `msa_compare', clear
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
/////////////////////////////////////
