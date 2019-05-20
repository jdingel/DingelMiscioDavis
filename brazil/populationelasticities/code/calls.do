qui do "programs.do"

/**********************************************************
** ELASTICITY REGRESSION: EDUCATION
**********************************************************/

// Table 5 in paper
foreach msa in msa_duranton_5 msa_duranton_15 msa_duranton_25 msa_night_10 msa_night_30 msa_night_50 msa_arranjo msa_microrregio {

	local replace = ""
	if "`msa'" == "msa_duranton_5" local replace = "replace"

	// create a string to pass as column title
	local n01 = subinstr(subinstr("`msa'","msa_","",1),"_",",",2)
	if strpos("`n01'",",")==0 local n01 = "`n01'" + ",NA"

	estimationarray_elasticities, `replace' ctitle(`n01') ///
	geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010.dta) ///
		geovarmsavarnormfile(../input/municipios_2010.dta) ///
		msavarnormfile(../input/`msa'pop_2010.dta) ///
		geovar(municipio6) secvar(edu) msavar(`msa') geosecpop(edupop) msapop(totalpop) ///
		keepif(totalpop>=100000 & edu~=5) ///
		tablefilename(../output/edupop_elasticities_Census2010_msa_compare)

}





// Education-cohort regressions (footnote 26)
// commuting
foreach x of numlist 5 15 25 {
	forval cohort=1/3 {
		local replace = ""
		if ("msa_duranton_`x'" == "msa_duranton_5" & `cohort'==1) local replace = "replace"
		estimationarray_elasticities, `replace' ///
			geovarsecvarnormfile(../input/BR_MUNICIPIO_agepop_edupop_Census2010.dta) ///
			geovarmsavarnormfile(../input/municipios_2010.dta) ///
			msavarnormfile(../input/msa_duranton_`x'pop_2010.dta) ///
			geovar(municipio6) secvar(edu) msavar(msa_duranton_`x') ///
			extrageosecvars(cohort) geosecpop(edupop) msapop(totalpop) ///
			keepif(totalpop>=100000 & edu~=5 & cohort==`cohort') ///
			tablefilename(../output/agepop_edupop_elasticities_Census2010_msa_duranton) ///
			ctitle(Commute, `x', Age, `cohort')
	}
}

// lights at night
forvalues x = 10(20)50 {
	forval cohort=1/3 {
		local replace = ""
		if ("msa_night_`x'" == "msa_night_10" & `cohort'==1) local replace = "replace"
		estimationarray_elasticities, `replace' ///
			geovarsecvarnormfile(../input/BR_MUNICIPIO_agepop_edupop_Census2010.dta) ///
			geovarmsavarnormfile(../input/municipios_2010.dta) ///
			msavarnormfile(../input/msa_night_`x'pop_2010.dta) ///
			geovar(municipio6) secvar(edu) msavar(msa_night_`x') ///
			extrageosecvars(cohort) geosecpop(edupop) msapop(totalpop) ///
			keepif(totalpop>=100000 & edu~=5 & cohort==`cohort') ///
			tablefilename(../output/agepop_edupop_elasticities_Census2010_msa_night) ///
			ctitle(Lights, `x', Age, `cohort')
	}
}

/**********************************************************
** ELASTICITY REGRESSION: SECTORS
**********************************************************/

//Dingel, 29 June 2018
local z = "duranton"
local x = 10
foreach sec in occ ind {
	estimationarray_elasticities, replace debug ///
		geovarsecvarnormfile(../input/BR_MUNICIPIO_`sec'pop_Census2010.dta) ///
		geovarmsavarnormfile(../input/municipios_2010.dta) ///
		msavarnormfile(../input/msa_`z'_`x'pop_2010.dta) ///
		geovar(municipio6) secvar(great`sec') ///
		msavar(msa_`z'_`x') geosecpop(`sec'pop) msapop(totalpop) ///
		keepif(totalpop>=100000) ///
		tablefilename(../output/`sec'pop_elasticities_Census2010_`z'`x') ///
		scatterplotname(../output/`sec'pop_elasticities_Census2010_`z'`x') ///
		skillintensitynormfile(../input/BR_AvgSch_`sec'_Census2010.dta) ///
		secvarmarkerfile(../input/`sec'_shares_Census2010.dta) ///
		secvarmarkersize(share) ///
		savescatterdata(../output/`sec'pop_elasticities_Census2010_`z'`x'.dta)
	//Produce a scatterplot that drops agriculture
	use "../output/`sec'pop_elasticities_Census2010_`z'`x'.dta", clear
	twoway (scatter populationelasticity skillintensity if great`sec'!="Agriculture" [w=share], ytitle("Population elasticity") ///
	msymbol(Oh) mcolor(black) msize(medsmall)) (scatter populationelasticity skillintensity if great`sec'!="Agriculture", ytitle("Population elasticity") ///
	ms(none) mlabel(great`sec') mlabsize(vsmall) mlabcolor(gs8)) (lfit populationelasticity skillintensity  if great`sec'!="Agriculture") ///
	, xtitle("Skill intensity (employees' average years of schooling)") graphregion(color(white)) ylabel(,nogrid) legend(off)
	graph export "../output/`sec'pop_elasticities_Census2010_zoom_`z'`x'.pdf", as(pdf) replace
}
