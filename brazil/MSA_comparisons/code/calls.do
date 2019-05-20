qui do "programs.do"

foreach y in msa_microrregio msa_duranton_10 {
	local msacomparisonfile = "../output/`y'_comparison.dta"

  foreach x in msa_duranton_5 msa_duranton_10 msa_duranton_15 msa_duranton_20 msa_duranton_25 ///
               msa_night_10 msa_night_20 msa_night_30 msa_night_40 msa_night_50 msa_night_60 {
    msa_compare, normfile(../input/municipios_2010.dta) base(`y') comparison(`x')
	cap append using "`msacomparisonfile'"
	duplicates drop
	save "`msacomparisonfile'", replace
  }
  msa_compare, normfile(../input/municipios_2010.dta) base(`y') comparison(msa_microrregio)
	cap append using "`msacomparisonfile'"
	duplicates drop
	save "`msacomparisonfile'", replace
  msa_compare, normfile(../input/municipios_2010.dta) base(`y') comparison(msa_arranjo)
	cap append using "`msacomparisonfile'"
	duplicates drop
	save "`msacomparisonfile'", replace
}

produce_msa_comparisons, msavar(msa_duranton_10) msacomparisonfile(../output/msa_duranton_10_comparison.dta) ///
  plotname(../output/msa_duranton_10_baseline_correlation_plot)

//Establish a crosswalk for MSAs to compare NTL metros
build_msa_crosswalk, input("../input/municipios_2010.dta") ///
                     saveas("../output/crosswalk_msa_2010.dta")

//Make a table of comparisons
tempfile tf0
foreach base in msa_duranton_5 msa_duranton_15 msa_duranton_25 {
	use "../output/crosswalk_msa_2010.dta", clear
	collapse (sum) population , by(`base')
	keep if population>=100000 & population!=. & `base'!=.
	local base_num_msas : di _N

	use "../output/crosswalk_msa_2010.dta", clear
	tempfile tf1
	foreach comp of varlist msa_duranton_? msa_duranton_?? msa_night_?? msa_arranjo msa_microrregio {
		msa_compare, normfile("../output/crosswalk_msa_2010.dta") base(`base') comparison(`comp')
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
replace metro = subinstr(metro,"msa_night_","Nightlight, intensity ",1) if substr(metro,-8,5)=="night"
replace metro = subinstr(metro,"msa_duranton_","Commuting Flows, threshold 0",1)+"\%" if substr(metro,-10,8)=="duranton" // single digit duranton
replace metro = subinstr(metro,"msa_duranton_","Commuting Flows, threshold ",1)+"\%" if substr(metro,-11,8)=="duranton" // double digit duranton
replace metro = subinstr(metro,"msa_arranjo","Arranjos",1) if substr(metro,-7,7)=="arranjo" // arranjo
replace metro = subinstr(metro,"msa_microrregio","Microregions",1) if substr(metro,-11,11)=="microrregio" // microregions

foreach var of varlist corr_pop_msa_duranton_5 corr_pop_msa_duranton_?5 corr_land_msa_duranton_5 corr_land_msa_duranton_?5 {
	replace `var' = . if `var'==1
}
format corr_pop_msa_duranton_5 corr_land_msa_duranton_5 corr_pop_msa_duranton_15 corr_land_msa_duranton_15 corr_pop_msa_duranton_25 corr_land_msa_duranton_25 %5.2fc

// we have to sort the output somehow to have the table organized neatly - alphabetical sorting will no longer be desirable
gen metro_num = 0
  replace metro_num = 1 if substr(metro,1,9)=="Commuting"
	replace metro_num = 2 if substr(metro,1,10)=="Nightlight"
  replace metro_num = 3 if substr(metro,1,12)=="Microregions"
  replace metro_num = 4 if substr(metro,1,8)=="Arranjos"
sort metro_num metro

order metro N_100k corr_pop_msa_duranton_5 corr_land_msa_duranton_5 corr_pop_msa_duranton_15 corr_land_msa_duranton_15 corr_pop_msa_duranton_25 corr_land_msa_duranton_25
listtex  metro N_100k corr_pop_msa_duranton_5 corr_land_msa_duranton_5 corr_pop_msa_duranton_15 corr_land_msa_duranton_15 corr_pop_msa_duranton_25 corr_land_msa_duranton_25 using "../output/msa_compare_Brazil_municipios_2010.tex", replace ///
	rstyle(tabular) head("\begin{tabular}{lcccccc} \toprule" ///
	"&& \multicolumn{6}{c}{Correlation with commuting flow:} \\ \cline{3-8}" ///
	"&& \multicolumn{2}{c}{Threshold: 5\%} & \multicolumn{2}{c}{Threshold: 15\%} & \multicolumn{2}{c}{Threshold: 25\%}\\ \cmidrule(lr){3-4} \cmidrule(lr){5-6} \cmidrule(lr){7-8}" ///
	"Metropolitan scheme & N & Pop'n & Land & Pop'n & Land & Pop'n & Land \\  \midrule") ///
	foot("\bottomrule \end{tabular}")
