qui do "programs.do"

popelast_plotmaker, geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) ///
	geovarmsavarnormfile(../input/municipios_2010.dta) ///
	msavarnormfile(../input/msa_duranton_10pop_2010.dta) ///
	geovar(municipio6) secvar(edu) msavar(msa_duranton_10) geosecpop(edupop) msapop(totalpop) ///
	keepif(totalpop>=100000 & edu~=5) valuelist(4 3 2 1) histogram rows(2)

graph export "../output/popelast_edu_lpoly.pdf", as(pdf) replace
