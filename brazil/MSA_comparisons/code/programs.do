capture program drop build_msa_crosswalk
program define build_msa_crosswalk
syntax, input(string) saveas(string)

tempfile tf0
use municipio6 population area_km2 msa_duranton_* msa_night_* msa_arranjo msa_microrregio using "`input'", clear
save `tf0', replace

foreach x of varlist msa_duranton_* msa_night_* msa_arranjo msa_microrregio {
	use `tf0', clear
	rename `x' temp_`x'
	bys temp_`x': egen temp_max_pop = max(population) if temp_`x'!=.
	gen long `x' = municipio6 if temp_max_pop == population
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

////////////////////////////////////////////////
// Produce land and population correlation plots
////////////////////////////////////////////////

cap program drop produce_msa_comparisons
program define produce_msa_comparisons
syntax, msavar(string) msacomparisonfile(string) plotname(string)

use "`msacomparisonfile'", clear

split comparison, parse(_) destring
rename comparison3 threshold

local ytitle = "10%-commuting-based metropolitan areas"
mylabels 5(5)25, local(dt_labels) suffix("%")

// Commuting
twoway ///
(connected correlation_population threshold if comparison2=="duranton", sort lcol(cranberry) mlcol(cranberry) mfcol(cranberry) msymbol(t)) ///
(connected correlation_landarea threshold if comparison2=="duranton", sort lp(dash) lcol(blue) mlcol(blue) mfcol(white) msymbol(o)), ///
xsize(2) ysc(r(0.8 1)) ///
legend(order(1 "Population" 2 "Land area") region(lstyle(none) lcolor(white))) ///
xlabel(`dt_labels') xtitle("Threshold for commuting flows") graphregion(color(white))
graph save "`plotname'_dt.gph", replace
// Lights
twoway ///
(connected correlation_population threshold if comparison2=="night", sort lcol(cranberry) mlcol(cranberry) mfcol(cranberry) msymbol(t)) ///
(connected correlation_landarea threshold if comparison2=="night", sort lp(dash) lcol(blue) mlcol(blue) mfcol(white) msymbol(o)), ///
xsize(2) ysc(r(0.8 1)) ytitle("Correlation with `ytitle'") ///
legend(order(1 "Population" 2 "Land area") region(lstyle(none) lcolor(white))) ///
ylabel(#4) xlabel(#6) xtitle("Threshold for light intensity") graphregion(color(white))
graph save "`plotname'_ntl.gph", replace
// graph combine
grc1leg2 `plotname'_ntl.gph `plotname'_dt.gph, graphregion(color(white)) ycommon rows(1)
gr export `plotname'.pdf, as(pdf) replace

end



//////////////////////////////////////////////////////////////////////////////////////////
// Program to compare MSAs constructed with different schemes (for Table)
//////////////////////////////////////////////////////////////////////////////////////////

capture program drop msa_compare
program define msa_compare
syntax, normfile(string) base(string) comparison(string)

	tempfile tf_norm tf_assignment
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
