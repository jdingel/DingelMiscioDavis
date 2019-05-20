set more off
qui do "programs.do"

msapop using "../input/geo_crosswalk_10.dta"
msa_estimation_prep using "../input/BR_MUNICIPIO_edupop_Census2010", saveas(../output/BR_MSA_edupop_Census2010) dataset(Census2010) popthresh(0) category(edu)

msapop_alt using "../input/municipios_2010.dta", msavar(msa_microrregio) saveas(../output/msa_microrregiopop_2010.dta)
msapop_alt using "../input/municipios_2010.dta", msavar(msa_arranjo)  saveas(../output/msa_arranjopop_2010.dta)

forvalues x = 10(10)50 {
	msapop_alt using "../input/municipios_2010.dta", msavar(msa_night_`x') saveas(../output/msa_night_`x'pop_2010.dta)
}
forvalues x = 5(5)25 {
	msapop_alt using "../input/municipios_2010.dta", msavar(msa_duranton_`x') saveas(../output/msa_duranton_`x'pop_2010.dta)
}
