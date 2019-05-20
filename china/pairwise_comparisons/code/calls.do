clear all
set more off
set matsize 2000
qui do "programs.do"

// Pairwise Comparisons 2000
local msascheme = "msa30_night"

//Produce MSA populations
tempfile tf_pop_`msascheme'
use "../input/townships_2000.dta", clear
drop if missing(`msascheme')
collapse (sum) population, by(`msascheme')
label variable population "MSA population in 2000"
label data "MSA populations in 2000"
save `tf_pop_`msascheme'', replace
count if inrange(population,100000,.)
local binlistmax = r(N)

//Bin assignments
tempfile tf_binassignments
binassignments_maker using `tf_pop_`msascheme'', keepif(inrange(population,100000,.)) ///
														binlist(2 5 10 50 150 `binlistmax') ///
														msavar(`msascheme') msagroupstub(msagroup) msapopvar(population) ///
														saveas(`tf_binassignments')


//Four-group educational categories
tempfile tf_educ_agg
use "../input/pop_by_educ_townships_2000.dta", clear
gen educ_agg = educ_cat
recode educ_agg 1=1 2=1 3=2 4=3 5=4 6=4 7=4 8=4 9=4
label define educ_agg 1 "Unschooled" ///
											2 "Primary school" ///
											3 "Junior middle school" ///
											4 "Senior middle school or higher"
label values educ_agg educ_agg
save `tf_educ_agg', replace

//Four-group weights files
tempfile tf_weights_g4
brazil_popdiffedushare_weights, msavarnormfile(`tf_pop_`msascheme'') ///
																msavar(`msascheme') ///
																msapopvar(population) ///
																binlist(2 5 10 50 150 `binlistmax') ///
																msagroupstub(msagroup) ///
																geovareduvarnormfile(`tf_educ_agg') ///
																eduvar(educ_agg) ///
																edupop(pop_educ) ///
																saveas(`tf_weights_g4')

//Four-group pairwise comparisons
estimationarray_pairwisecomp, debug keepif(inrange(population,100000,.)) ///
															binlist(2 5 10 50 150 `binlistmax') ///
															binassignmentsfile(`tf_binassignments') ///
															msagroupstub(msagroup) ///
															weightfile(`tf_weights_g4') weightvars(weight) ///
															geovarsecvarnormfile(`tf_educ_agg') secvar(educ_agg) geosecpop(pop_educ) ///
															geovarmsavarnormfile(../input/townships_2000.dta) geovar(gbtown) ///
															msavarnormfile(`tf_pop_`msascheme'') msavar(`msascheme') msapop(population) extramsavars(population) ///
		 													saveas1(../output/pairwise_edu_2000_4group.dta) ///
															saveas2(../output/pairwise_edu_2000_4group.tex)
