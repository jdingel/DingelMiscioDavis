///////////////////////////////////////

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
local se: display %5.3f _se[logpop]
local observations = `e(N)'

clear
set obs 1
gen str geounitvar = "`geounitvar'"
gen r2 = `r2'
gen beta = `beta'
gen str se = "(" + string(`se',"%4.3f") + ")"
gen observations = `observations'
gen str se_GI = "(" + string(abs(beta)*sqrt(2/observations),"%4.3f") + ")" //Gabaix & Ibragimov 2011

cap confirm file "`saveas'"
if (_rc==0) append using "`saveas'"
save "`saveas'", replace

//Restore original data
use `tf_original', clear //Restore the data as it was when the program was invoked

end

capture program drop ranksize_figuremaker
program define ranksize_figuremaker
syntax, population(varname) geounitvar(varname) minimumpopulation(real) [datasaveas(string)] [figfilename(string)] [additionalnote(string)]

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
local beta: display %5.3f _b[logpop] //YY: coefficient number format
local observations = `e(N)'
graph twoway (scatter logrank logpop) (lfitci logrank logpop), ///
								ytitle(Log (rank-0.5)) xtitle(Log population) ///
								graphregion(color(white)) legend(off) ylab(,nogrid) ///
								note("N = `observations', {&beta} = `beta', R{sup:2} = `r2'" "`additionalnote'")
if "`figfilename'"!="" graph export "`figfilename'", replace

if "`datasaveas'"!="" {
	clear
	set obs 1
	gen str geounitvar = "`geounitvar'"
	gen r2 = `r2'
	gen beta = `beta'
	gen observations = `observations'
	gen str se_GI = "(" + string(abs(beta)*sqrt(2/observations),"%4.3f") + ")" //Gabaix & Ibragimov 2011
	cap confirm file "`datasaveas'"
	if (_rc==0) append using "`datasaveas'"
	save "`datasaveas'", replace
}

//Restore original data
use `tf_original', clear //Restore the data as it was when the program was invoked

end
/////////////////////////////////////////////////////////

cap program drop  msa_zipf_compare_table_China
program define msa_zipf_compare_table_China
	syntax using/, minimumpopulation(real) msalist(string) tablefilename(string)

	tempfile tf0
	use "`using'", clear
	foreach msascheme of varlist `msalist' {
		use if missing(`msascheme')==0 using "`using'", clear
		collapse (sum) population, by(`msascheme')
		ranksize_coefficients, population(population) geounitvar(`msascheme') minimumpopulation(`minimumpopulation') saveas(`tf0')
	}
	use `tf0', clear
	replace geounitvar = subinstr(geounitvar,"msa","Light intensity ",1) if substr(geounitvar,-5,5)=="night"
	replace geounitvar = subinstr(geounitvar,"_night","",1) if substr(geounitvar,-5,5)=="night"
	replace geounitvar = subinstr(geounitvar,"msa_prefecture","Prefecture-level cities",1)

	sort geounitvar

	format beta r2 %4.3f
 	listtex geounitvar beta se_GI r2 observations using "`tablefilename'", replace ///
		rstyle(tabular) head("\begin{tabular}{lcccc} \toprule" "Metropolitan scheme & $\beta$ & s.e. & $ R^2$ & $ N$ \\ \midrule") foot("\bottomrule \end{tabular}")


end
