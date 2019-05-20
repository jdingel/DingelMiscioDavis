qui do "programs.do"

// MSA Comparisons (Figure 6 in 20161231)
foreach y in msa_prefecture msa30_night {
	local msacomparisonfile = "../output/`y'_comparison.dta"

	foreach x in msa10_night msa20_night msa30_night msa40_night msa50_night msa60_night {
		msa_compare, normfile(../input/townships_2000.dta) base(`y') comparison(`x')
		cap append using "`msacomparisonfile'"
		duplicates drop
		save "`msacomparisonfile'", replace
	}

}

produce_msa_comparisons, msavar(msa30_night) ///
												 msacomparisonfile(../output/msa30_night_comparison.dta) ///
												 plotname(../output/msa30_night_baseline_correlation_plot)

produce_msa_comparisons, msavar(msa_prefecture) ytitle(prefecture-level cities) ///
												 msacomparisonfile(../output/msa_prefecture_comparison.dta) ///
												 plotname(../output/msa_prefecture_baseline_correlation_plot)

//Establish a crosswalk for MSAs to compare county-based and township-based MSAs
build_msa_crosswalk,	input1("../input/counties_2000.dta") ///
						input2("../input/townships_2000.dta") ///
						saveas("../output/crosswalk_msa_2000.dta")

//Make a table of correlation comparisons
tempfile tf0
foreach base in msa10_night msa30_night msa50_night { // baseline metros ; township-based

	use "../output/crosswalk_msa_2000.dta", clear
	tempfile tf1

	// generate the crosswalk file
	foreach comp of varlist msa??_night msa??_night_cnty {
		msa_compare, normfile("../output/crosswalk_msa_2000.dta") base(`base') comparison(`comp')
		duplicates drop
		capture confirm file `tf1'
		if (_rc==0) append using `tf1'
		save `tf1', replace
	}

	use `tf1', clear
	rename (correlation_population correlation_landarea) (corr_pop_`base' corr_land_`base')
	keep comparison corr_pop corr_land N_100k
	capture confirm file `tf0'
	if (_rc==0) merge 1:1 comparison using `tf0', nogen assert(match)
	save `tf0', replace
}

// set up labels for listtex
use `tf0', clear
rename comparison metro
replace metro = subinstr(metro,"msa","County-based, intensity ",1) if substr(metro,-4,4)=="cnty"
replace metro = subinstr(metro,"_night_cnty","",1) if substr(metro,-4,4)=="cnty"
replace metro = subinstr(metro,"msa","Township-based, intensity ",1) if substr(metro,-6,6)=="_night"
replace metro = subinstr(metro,"_night","",1) if substr(metro,-6,6)=="_night"

foreach var of varlist corr_pop_msa?0_night corr_land_msa?0_night {
	replace `var' = . if `var'==1
}
format corr_pop_msa10_night corr_land_msa10_night corr_pop_msa30_night corr_land_msa30_night corr_pop_msa50_night corr_land_msa50_night %5.2fc
sort metro

order metro N_100k corr_pop_msa10_night corr_land_msa10_night corr_pop_msa30_night corr_land_msa30_night corr_pop_msa50_night corr_land_msa50_night
listtex metro N_100k corr_pop_msa10_night corr_land_msa10_night corr_pop_msa30_night corr_land_msa30_night corr_pop_msa50_night corr_land_msa50_night using "../output/msa_compare_China_townships_counties_2000.tex", replace ///
	rstyle(tabular) head("\begin{tabular}{lrcccccc} \toprule" ///
	"&& \multicolumn{6}{c}{Correlation with township-based} \\ \cline{3-8}" ///
	"&& \multicolumn{2}{c}{Intensity: 10} & \multicolumn{2}{c}{Intensity: 30} & \multicolumn{2}{c}{Intensity: 50}\\ \cmidrule(lr){3-4} \cmidrule(lr){5-6} \cmidrule(lr){7-8}" ///
	"Metropolitan scheme & \multicolumn{1}{c}{N} & Pop'n & Land & Pop'n & Land & Pop'n & Land \\  \midrule") ///
	foot("\bottomrule \end{tabular}")
