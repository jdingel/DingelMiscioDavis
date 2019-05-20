qui do "programs.do"

//Workers 4 Groups

// 1. Weights
//Generate weights for education : weights = log_pop_diff * share of education category
//weights = log_pop_diff * share of education category
binassignments_maker using "../input/MSAs_2001.dta", saveas(../output/binassignments.dta) ///
	msavar(MSACode) msapopvar(population_MSA) binlist(2 5 11 33 110 330) msagroupstub(msagroup) keepif(share_population_city !=0)

brazil_popdiffedushare_weights , msavarnormfile(../input/MSAs_2001.dta) msavar(MSACode) msapopvar(population_MSA) binlist(2 5 11 33 110 330) ///
		 msagroupstub(msagroup) geovareduvarnormfile(../input/town_edu_count_4Groups.dta) eduvar(edu) edupop(A25to59) ///
		 saveas(../output/weights_edu_4group.dta) keepifmsa(share_population_city !=0)

// 2. Pairwise Comparisons
local threshold=0
estimationarray_pairwisecomp, binlist(2 5 11 33 110 330) binassignmentsfile(../output/binassignments.dta) msagroupstub(msagroup) ///
		weightvars(weight) weightfile(../output/weights_edu_4group.dta) ///
		geovarsecvarnormfile(../input/town_edu_count_4Groups.dta) msavarnormfile(../input/MSAs_2001.dta) ///
		geovarmsavarnormfile(../input/town_2001.dta) ///
		geovar(TownCode) secvar(edu) msavar(MSACode) geosecpop(A25to59) msapop(population_MSA) ///
		saveas1(../output/pairwise_edu_4group_`threshold'.dta) saveas2(../output/pairwise_edu_4group_`threshold'.tex) ///
		keepif(share_population_city>=`threshold') extramsavars(share_population_city)
