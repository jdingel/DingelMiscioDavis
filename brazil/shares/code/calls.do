qui do "programs.do"

//Education shares
edu_shares_census using "../input/BR_MSA_edupop_Census2010.dta", dropif_msapop(msapop<100000) ///
							outputname(../output/edu_shares_Census.tex)
edu_shares_census using "../input/BR_MSA_edupop_Census2010.dta", ///
							outputname(../output/edu_shares_Census_fullpop.tex)

category_shares using "../input/BR_MUNICIPIO_indpop_Census2010.dta", ///
											geosecpop(indpop) ///
											secvar(greatind) ///
											saveas(../output/ind_shares_Census2010.dta)
category_shares using "../input/BR_MUNICIPIO_occpop_Census2010.dta", ///
											geosecpop(occpop) ///
											secvar(greatocc) ///
											saveas(../output/occ_shares_Census2010.dta)
