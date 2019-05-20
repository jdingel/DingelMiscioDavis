
cap program drop demean
program define demean
syntax varlist, [by(varlist)] suffix(string)

// version 0.2, 14 December 2016, JDingel

foreach var of varlist `varlist' {
	tempvar tv
	if "`by'"!="" bys `by': egen `tv' = mean(`var')
	else egen `tv' = mean(`var')
	gen `var'`suffix' = `var' - `tv'
	drop `tv'
	local label`var': variable label `var'
	if "`by'"!="" local byphrase = "by `by'"
	if "`label`var''"~="" label variable `var'`suffix' "`label`var'' (demeaned `byphrase')"
}

end


cap program drop collapsewithlabels
program define collapsewithlabels
syntax varlist, statistic(string) by(varlist)

//This program performs a collapse while keeping the collpased variables labeled as they were pre-collapse

foreach var of varlist `varlist' {
	local `var'_label: var label `var'
	disp "``var'_label'"
}
collapse (`statistic') `varlist', by(`by')
foreach var of varlist `varlist' {
	label variable `var' "``var'_label'"
}

end


////////////////////////////////
// Intermediate Program
////////////////////////////////

cap program drop popelast_lpolyplot
program define popelast_lpolyplot

	//This function plots local polynomials with an optional histogram

	syntax varname, values(numlist) depvar(varname) logpopulation(varname) [ytitle(string)] [histogram] [rows(integer 0)]

	if "`ytitle'"!= "" local ytitle = "ytitle(`ytitle')"

    local color_list gray magenta blue red dkgreen black
    local series_number 2


    display "debug check 0"

    foreach x of numlist `values' {
			//Pick parameters for this instance
    	local line_color: word `series_number' of `color_list'
			local foo: value label `varlist'
			local xlabel: label `foo' `x'
    	//Concatenate list
    	local graphcommand `graphcommand' (lpoly `depvar' `logpopulation' if `varlist' == `x', yaxis(1) lcolor(`line_color'))
    	local legendlabels `legendlabels' lab(`series_number' `"`xlabel'"')
			local legendorders `legendorders' `series_number'
    	//Advance along parameter list
    	local ++series_number
    }
	if `rows'==0 local rows = `series_number' - 1

    twoway `graphcommand', ylabel(,nogrid) graphregion(color(white)) ///
		yscale(alt axis(1) range(-0.6 0.6)) ylabel(#6,axis(1)) ///
    `ytitle' xtitle("Metropolitan log population") ///
		legend(region(color(white)) rows(`rows') `legendlabels')

	if "`histogram'"=="histogram" {
		local upper_bound = _N/4
		twoway (hist `logpopulation', fcolor(gray%10) lcolor(gray) yaxis(2) freq) `graphcommand', ylabel(,nogrid) graphregion(color(white)) ///
		yscale(alt axis(1) range(-0.3 0.5)) ylabel(#8,axis(1)labsize(small)) ///
		yscale(alt axis(2) range(0 `upper_bound')) ylabel(#4,axis(2)) ///
		`ytitle' xtitle("Metropolitan log population") ///
		legend(region(color(white)) order(`legendorders') rows(`rows') `legendlabels')
	}

end

///////////////////////////////////////
// Final Figure
///////////////////////////////////////

cap program drop popelast_plotmaker
program define popelast_plotmaker

syntax, geovarsecvarnormfile(string) [geovarmsavarnormfile(string)] msavarnormfile(string) ///
		geovar(string) secvar(string) msavar(string) geosecpop(string) msapop(string) ///
		[keepif(string) extramsavars(string) extrageosecvars(string)] valuelist(numlist) [histogram] [rows(integer 0)]

	//(1) Open a normalized file containing geovar-secvar population counts
	use `geovar' `secvar' `geosecpop' `extrageosecvars' using "`geovarsecvarnormfile'", clear
	if "`debug'"=="debug" disp "Step (1) done"

	if 	"`geovar'"~="`msavar'" {
		//(2) Merge geovar with msavar
		merge m:1 `geovar' using "`geovarmsavarnormfile'", keep(1 3) keepusing(`msavar') nogen

		//(3) Collapse to MSA level
		collapsewithlabels `geosecpop', by(`msavar' `secvar') statistic(sum)
		if "`debug'"=="debug" disp "Step (3) done"
	}

	//(4a) Merge msavar with MSA population counts
	merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) keepusing(`msapop' `extramsavars') nogen

	//(4b) Apply estimation-sample restrictions
	if "`keepif'"~="" keep if `keepif'

	//(5) Take log of secvar-msavar population counts and log of msavar total population counts
	foreach var of varlist `geosecpop' `msapop' {
		local `var'_label: var label `var'
		gen `var'_log = log(`var')
		label variable `var'_log "Log of ``var'_label'"
	}
	if "`debug'"=="debug" disp "Step (5) done"

	local `msapop'_label: var label `msapop'
	gen `secvar'_logshare = `geosecpop'_log - `msapop'_log
	label variable `secvar'_logshare "Log of ``var'_label' share of ``msapop'_label'"

	demean `secvar'_logshare, suffix(_dm) by(`secvar')

	popelast_lpolyplot `secvar', values(`valuelist') depvar(`secvar'_logshare_dm) logpopulation(`msapop'_log) ytitle("Log share of population (demeaned)") `histogram' rows(`rows')

end
