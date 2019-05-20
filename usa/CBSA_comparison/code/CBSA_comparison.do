clear all
foreach package in mylabels grc1leg2 {
	capture which `package'
	if _rc==111 ssc install `package'
}
qui do "programs.do"


/***********************
** PROGRAM CALLS
***********************/

//USA CBSA comparisons

local myfile "../input/counties_2010.dta"
local mybase msa_cbsa
tempfile temp
use "`myfile'", clear
foreach x of varlist msa_duranton_* msa_night_* {
	msa_compare, normfile(`myfile') base(`mybase') comparison(`x')
	capture confirm file `temp'
	if (_rc==0) append using `temp'
	save `temp', replace
}
split comparison, parse(_) destring
rename comparison3 threshold

mylabels 10(5)35, local(labels) suffix("%")

twoway ///
(connected correlation_population threshold if comparison2=="duranton", sort lcol(cranberry) mlcol(cranberry) mfcol(cranberry) msymbol(t)) ///
(connected correlation_landarea threshold if comparison2=="duranton", sort lp(dash) lcol(blue) mlcol(blue) mfcol(white) msymbol(o)), ///
legend(order(1 "Population" 2 "Land area") region(lstyle(none) lcolor(white))) ///
xsize(2) ysc(r(0.7 1)) graphregion(color(white)) ///
ylabel(#6) xlabel(`labels') xtitle("Threshold for commuting flows") name(graph_commuting)
graph save "../output/US_correlations_dt.gph", replace

twoway ///
(connected correlation_population threshold if comparison2=="night", sort lcol(cranberry) mlcol(cranberry) mfcol(cranberry) msymbol(t)) ///
(connected correlation_landarea threshold if comparison2=="night", sort lp(dash) lcol(blue) mlcol(blue) mfcol(white) msymbol(o)), ///
legend(order(1 "Population" 2 "Land area") region(lstyle(none) lcolor(white))) ///
xsize(2) ysc(r(0.7 1)) graphregion(color(white)) ///
ytitle("Correlation with OMB-defined CBSAs") ylabel(#6) xtitle("Threshold for light intensity") name(graph_light)
graph save "../output/US_correlations_ntl.gph", replace

//graph combine US_correlations_dt.gph US_correlations_ntl.gph, graphregion(color(white))
grc1leg2 graph_light graph_commuting , graphregion(color(white)) ycommon rows(1)
gr export "../output/US_correlations.pdf", as(pdf) replace
