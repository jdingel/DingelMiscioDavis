qui do "programs.do"

//Bin assignments
binassignments_maker using "../input/msapop_2010.dta", ///
														saveas(../output/binassignments.dta) ///
														msavar(msa10) ///
														msapopvar(totalpop)  ///
														binlist(2 8 16 64 96 192) ///
														msagroupstub(msagroup) keepif(totalpop>=100000)

//Weight files: Eduational groups
brazil_popdiffedushare_weights, ///
		msavarnormfile(../input/msapop_2010.dta) msavar(msa10) msapopvar(totalpop) ///
		binlist(2 8 16 64 96 192) msagroupstub(msagroup) ///
		geovareduvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) ///
		eduvar(edu) edupop(edupop) ///
		saveas(../output/weights_edu.dta)  keepifmsa(totalpop>=100000) keepifedu(edu~=5)

//Pairwise comparisons: Education
estimationarray_pairwisecomp, keepif(totalpop>=100000 & edu ~=5) ///
		binlist(2 8 16 64 96 192) binassignmentsfile(../output/binassignments.dta) ///
		msagroupstub(msagroup) weightvars(weight) weightfile(../output/weights_edu.dta) ///
		geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) ///
		geovarmsavarnormfile(../input/msa_municipio_2010_map.dta) msavarnormfile(../input/msapop_2010.dta) ///
		geovar(state_code municipio_code) secvar(edu) msavar(msa10) geosecpop(edupop) msapop(totalpop) ///
		debug saveas1(../output/pairwise_edu.dta) saveas2(../output/pairwise_edu.tex)
