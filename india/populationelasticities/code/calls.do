clear
qui do "programs.do"

// 2001 Education Population Elasticities
// workers 4 group scheme
// towns
foreach threshold of numlist 0 0.8 0.95 {
	if "`threshold'"=="0" local replace = "replace"
	if "`threshold'"!="0" local replace = ""
estimationarray_elasticities, `replace' ///
								geovarsecvarnormfile(../input/town_edu_count_4Groups.dta) ///
								geovarmsavarnormfile(../input/town_2001.dta) ///
								msavarnormfile(../input/MSAs_2001.dta) ///
								geovar(TownCode) secvar(edu) msavar(MSACode) ///
								geosecpop(A25to59) msapop(population_MSA) ///
								keepif(share_population_city>=`threshold') ///
								extramsavars(share_population_city) ///
								tablefilename(../output/edu_popelasticity_B9_4scheme_2001) ///
								ctitle(Urban Agglomerations, `threshold')

}
