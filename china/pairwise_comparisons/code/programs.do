
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

cap program drop generatepairwise
program define generatepairwise

//Version 0.2, 11 Feb 2016, Jonathan Dingel

syntax, id(varname) covariates(varlist)

//This program generates all pairs of `id' and associated `covariates', naming them `id'_1 and `id'_2 and so forth

tempfile tf0 tf1 tf2
save `tf0', replace
foreach var of varlist `id' `covariates' {
	ren `var' `var'_1
	local covariates_1 = "`covariates_1'" + " `var'_1"
}
save `tf1', replace
use `tf0', clear
foreach var of varlist `id' `covariates' {
	ren `var' `var'_2
	local covariates_2 = "`covariates_2'" + " `var'_2"
}
save `tf2', replace
keep `id'_2
clonevar `id'_1 = `id'_2
fillin `id'_?
drop _fillin
merge m:1 `id'_1 using `tf1', nogen keepusing(`covariates_1')
merge m:1 `id'_2 using `tf2', nogen keepusing(`covariates_2')
order `id'_1 `id'_2 *_1 *_2
sort `id'_1 `id'_2

end

cap program drop transplantlabels
program define transplantlabels

//This program assumes a 1-to-1 correspondences between values of `sourcevar' and `destinationvar'
//Using the labels contained in `sourcelabel', it creates `destinationlabel' and applies it to `destinationvar'

syntax, sourcevar(varname) sourcelabel(string) destinationvar(varname) destinationlabel(string)

  label define `destinationlabel', replace
  levelsof `destinationvar', local(value_levels)
  foreach value_dest of local value_levels {
	disp "`value_dest'"
	summ `sourcevar' if `destinationvar'==`value_dest'
    local value_source = r(mean)
	disp "`labelsource' `value_source'"
    local temp : label `sourcelabel' `value_source' //create macro that contains label for each value
    disp "`temp'"
	label define `destinationlabel' `value_dest' " `temp' ", add
  }
  label values `destinationvar' `destinationlabel'

end

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


cap program drop estimationarray_pairwisecomp
program define estimationarray_pairwisecomp

//Required elements:
syntax, binlist(numlist) binassignmentsfile(string) msagroupstub(string) ///
		weightvars(string) weightfile(string) ///
		geovarsecvarnormfile(string) msavarnormfile(string) ///
		geovar(string) secvar(string) msavar(string) geosecpop(string) msapop(string) ///
		[secvarrankvalue(string) skillintensitynormfile(string)] ///
		[debug] saveas1(string) saveas2(string)[keepif(string)] [extramsavars(string)] [geovarmsavarnormfile(string)]

	//3 March 2016, Jonathan Dingel
	//`binlist' is a list of bins, `binassignmentsfile' contains `msavar' and `msagroupstub' where the latter ends in `bin', a number of bins
	//`geovar' is microgeographic identifier, `secvar' is edu, occ, or ind identifier, `msavar' is MSA identifier
	//`weightvars', `weightfile'

	if "`secvarrankvalue'"=="" local secvarrankvalue = "`secvar'"

	tempfile tf0

	//(1) Open a normalized file containing geovar-secvar population counts
	use "`geovarsecvarnormfile'", clear

	//(2) Merge geovar with msavar
	if 	"`geovar'"~="`msavar'" {
		merge m:1 `geovar' using "`geovarmsavarnormfile'", keep(3) keepusing(`msavar') nogen assert(1 3)
	}

	//(3) Collapse to MSA level, join with msa population, merge with rank variable, take logs
	collapsewithlabels `geosecpop', by(`msavar' `secvar') statistic(sum)
	merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) keepusing(`msapop' `extramsavars') nogen

	drop if missing(`msavar')
	drop if `geosecpop'<=0

	if "`keepif'"~="" keep if `keepif'
	foreach var of varlist `geosecpop' `msapop' {
		local `var'_label: var label `var'
		gen `var'_log = log(`var')
		label variable `var'_log "Log of ``var'_label'"
	}
	if "`secvarrankvalue'"~="`secvar'" {
		merge m:1 `secvar' using "`skillintensitynormfile'", assert(1 3) keepusing(`secvarrankvalue') nogen
	}
	label data "MSA-`secvar'-level observation of log `geosecpop' and log `msapop'"
	qui save `tf0', replace
	if "`debug'"=="debug" {
		summ
		list if missing(`msavar')
		disp "Steps (1) through (3) completed."
	}

	//(4) Loop through bin assignments, computing pairwise comparisons

	foreach bin of numlist `binlist' {
		tempfile tf_bin`bin'
		use `tf0', clear
		//(4a) Merge MSA-`secvar'-level observations with bin assignments
		merge m:1 `msavar' using "`binassignmentsfile'", keepusing(`msagroupstub'`bin') nogen assert(3)
		if "`debug'"=="debug" disp "Merge with bin assignments for `bin' bins completed."
		gen msas_in_bin = 1
		collapse (sum) `msapop'_log `geosecpop'_log msas_in_bin,  by(`secvar' `msagroupstub'`bin')
		gen `geosecpop'_log_avg = `geosecpop'_log / msas_in_bin
		if "`secvarrankvalue'"~="`secvar'" {
			 merge m:1 `secvar' using "`skillintensitynormfile'", assert(2 3) keepusing(`secvarrankvalue') nogen
		}

		//(4b) Compute pairwise comparisons
		if "`debug'"=="debug" disp "Now calling supermodularitycheck."
		supermodularitycheck, x(`secvar') y(`msagroupstub'`bin') value(`geosecpop'_log_avg) xvalue(`secvarrankvalue') testoutcome(outcome_dummy) filename(`tf_bin`bin'')
		if "`debug'"=="debug" disp "supermodularitycheck complete"

		//(4c) Attach weights to pairwise comparisons
		use `tf_bin`bin'', clear
		if "`debug'"=="debug" disp "supermodularitycheck output loaded"
		gen bins = `bin'
		egen comparisons = total(missing(outcome_dummy)==0)
		egen outcome = mean(outcome_dummy) //Computing unweighted mean
		rename (`msagroupstub'`bin'_1 `msagroupstub'`bin'_2) (`msagroupstub'_1 `msagroupstub'_2)
		merge 1:1 bins `msagroupstub'_? `secvar'_? using "`weightfile'", nogen keep(3) assert(2 3) keepusing(`weightvars') //Merge with weights
		egen denom = total(`weightvars')
		egen numer = total(outcome_dummy*`weightvars')
		gen outcome_weighted = numer / denom
		drop outcome_dummy

		collapse (firstnm) outcome* comparisons, by(bins)
		qui save `tf_bin`bin'', replace

	}

	//(4d) Save results of pairwise comparisons
	clear
	foreach bin of numlist `binlist' {
		append using `tf_bin`bin''
	}
	saveold "`saveas1'", replace $saveoldversion

	//(5) Make TeX table
	use "`saveas1'", clear

	foreach var of varlist outcome* {
		replace `var' = round(`var', .01)
		tostring `var', replace format(%3.2f) force
	}

	listtex bins comparisons outcome outcome_weighted using "`saveas2'", replace rstyle(tabular) ///
	head("\begin{tabular}{cccc}" "\multicolumn{4}{c}{Pairwise comparisons} \\ \hline" ///
	"&Total          & \multicolumn{2}{c}{Success rate} \\" ///
	"Bins&comparisons& Outcome  & Weighted Outcome \\ \hline") ///
	foot("\hline \end{tabular}")


end

cap program drop binassignments_maker
program define binassignments_maker

syntax using/, saveas(string) msavar(string) msapopvar(string) binlist(numlist) msagroupstub(string) [keepif(string)]

	use "`using'", clear
	if "`keepif'"!="" keep if `keepif'
	collapse (firstnm) `msapopvar', by(`msavar')
	foreach bin in `binlist' {
		xtile `msagroupstub'`bin' = `msapopvar', nq(`bin')
	}
	label data "Assignments of MSAs (`msavar') to bins"
	saveold "`saveas'", replace $saveoldversion

end

cap program drop brazil_popdiffedushare_weights
program define brazil_popdiffedushare_weights

syntax , msavarnormfile(string) msavar(string) msapopvar(string) binlist(numlist) msagroupstub(string) ///
		 geovareduvarnormfile(string) eduvar(string) edupop(string) ///
		 saveas(string) [keepifmsa(string)] [keepifedu(string)] [debug]

	//Generate populations for bins
	tempfile tf0
	use "`msavarnormfile'", clear
	if "`keepifmsa'"~="" keep if `keepifmsa'
	keep `msavar' `msapopvar'
	save `tf0', replace

	foreach bin in `binlist' {
		tempfile tf_bins`bin'
		use `tf0', clear
		xtile `msagroupstub' = `msapopvar', nq(`bin')
		gen logpop = log(`msapopvar')
		collapse (sum) logpop, by(`msagroupstub')
		gen bins = `bin'
		label data "MSA group populations for `bin' bins"
		save `tf_bins`bin'', replace
	}
	if "`debug'"=="debug" display "Step 1 complete"

	//Generate education shares
	tempfile tf_edushare
	use "`geovareduvarnormfile'", clear
	if "`keepifedu'"~="" keep if `keepifedu'
	collapse (sum) `edupop', by(`eduvar')
	egen total = total(`edupop')
	gen edushare = `edupop' / total
	keep `eduvar' edushare
	gen merger = _n
	local expander = _N
	save `tf_edushare', replace
	if "`debug'"=="debug" display "Step 2 complete"

	//Combine population bins & education shares
	foreach bin in `binlist' {
		tempfile tf_weights`bin'
		use `tf_bins`bin'', clear
		expand `expander'
		bys `msagroupstub' bins: gen merger = _n
		merge m:1 merger using `tf_edushare', assert(3) nogen //keepusing(`eduvar')
		egen id = group(`msagroupstub' bins `eduvar')
		generatepairwise, id(id) covariates(`msagroupstub' bins logpop `eduvar' edushare)
		gen weight = abs(logpop_1-logpop_2)*(edushare_1 * edushare_2)
		ren bins_1 bins
		keep `msagroupstub'_? `eduvar'_? bins weight
		save `tf_weights`bin'', replace
	}

	clear
	foreach bin in `binlist' {
		append using `tf_weights`bin''
	}
	if "`debug'"=="debug" display "Step 3 complete"

	//Save
	label data "Weight: Diff in log pop times product of edu shares"
	saveold "`saveas'", replace $saveoldversion

end

//MLR TEST
//Version: 0.65
//Author: Jonathan Dingel (jonathan.dingel at gmail)
//Date: 27 March 2016 (0.65), 29 Dec 2015 (0.6), 1 October 2014 (0.5)
//Updates: Version 0.6 added quotation marks in save "`filename'.dta", replace
//Updates: Version 0.65 uses clonevar rather than gen "`var'_2 = `var'_1"
//Purpose: Indicate whether observations satisfies the inequality that defines supermodularity

	//This program checks whether value(xvalue,yvalue) is a supermodular function
	//It supports looking at value(x,y), where x and y may index units without ordering them (e.g. x = msa, xvalue = msa population)
	//To check log-supermodularity, use the "logsupermodular" option
	//If you're investigating log-supermodularity, but your observations are already log values, then just check supermodularity of the log values
	//The program assumes that the data consist of a series of observations of value(x,y); the program will generating all the pairwise combinations to check supermodularity

cap program drop supermodularitycheck
program define supermodularitycheck
	syntax [if], x(varname) y(varname) value(varname) [xvalue(varname) yvalue(varname)] [testoutcome(string) filename(string)] [logsupermodular]


	//As of this version, the program doesn't verify that the inputs are of valid form!

	tempfile tforiginal tf0 tf1 tf2 tf3
	save `tforiginal', replace						//Preserve data in memory at time of program call
	if "`if'"~="" keep `if'								//Impose the if condition when specified
	keep `x' `y' `xvalue' `yvalue' `value'				//Keep only variables needed for MLR test
	save `tf0', replace

	//If xvalue or yvalue not specified, rank by x or y
	if "`xvalue'"=="" local xvalue = "`x'"
	if "`yvalue'"=="" local yvalue = "`y'"

	//Create all pairwise combinations to make comparisons
	keep `x' `y'
	foreach var of varlist `x' `y' {
		ren `var' `var'_1
		clonevar `var'_2 = `var'_1
	}
	fillin *
	drop _fillin

	//Retain pairs in which xvalue2>xvalue1 and yvalue2>yvalue1
	if ("`x'"~="`xvalue'")|("`y'"~="`yvalue'") {
		forvalues i=1/2 {
			gen `x' = `x'_`i'
			gen `y' = `y'_`i'
			qui merge m:1 `x' `y' using `tf0', keep(1 3) nogen keepusing (`xvalue' `yvalue')
			drop `x' `y'
			if "`x'"~="`xvalue'" ren `xvalue' `xvalue'_`i'
			if "`y'"~="`yvalue'" ren `yvalue' `yvalue'_`i'
		}
	}
	keep if `xvalue'_2 > `xvalue'_1 & `yvalue'_2 > `yvalue'_1 & (`xvalue'_2 ~=. & `xvalue'_1 ~=. & `yvalue'_2 ~=. & `yvalue'_1 ~=.)
	keep `x'_1 `y'_1 `x'_2 `y'_2

	//Load f(x,y) data and check whether f(x1,y1)+f(x2,y2)>=f(x1,y2)+f(x2,y1)
	forvalues i=1/2 {
		forvalues j=1/2 {
			gen `x' = `x'_`i'
			gen `y' = `y'_`j'
			qui merge m:1 `x' `y' using `tf0', keep(1 3) nogen keepusing(`value')
			ren `value' `value'_`i'`j'
			drop `x' `y'
		}
	}

	if "`logsupermodular'"==""				 	gen `testoutcome' = (`value'_22 + `value'_11 >= `value'_21 + `value'_12) if (`value'_22~=. & `value'_11~=. & `value'_21~=. & `value'_12~=. )
	if "`logsupermodular'"=="logsupermodular"	gen `testoutcome' = (`value'_22 * `value'_11 >= `value'_21 * `value'_12) if (`value'_22~=. & `value'_11~=. & `value'_21~=. & `value'_12~=. )

	//Reports results
	if "`filename'"=="" summ `testoutcome'	//Display the average success if we aren't recording results for each observation
	if "`filename'"~="" {
		keep `x'_? `y'_? `testoutcome'
		save "`filename'", replace
	}

	use `tforiginal', clear

end
