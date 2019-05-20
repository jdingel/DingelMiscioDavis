cap program drop estimationarray_elasticities
program define estimationarray_elasticities


syntax, geovarsecvarnormfile(string) [geovarmsavarnormfile(string)] msavarnormfile(string) ///
		geovar(string) secvar(string) msavar(string) geosecpop(string) msapop(string) ///
		[keepif(string) extramsavars(string) extrageosecvars(string)] ///
		[savearrayas(string)] tablefilename(string) [replace] [ctitle(string)] ///
		[scatterplotname(string) skillintensitynormfile(string)] [debug] ///
		[secvarmarkerfile(string) secvarmarkersize(string)] [savescatterdata(string)]

	//`geovar' is microgeographic identifier, `secvar' is edu, occ, or ind identifier, `msavar' is MSA identifier
	//`geosecpop' is population count of `secvar' in `geovar' and appears in `geovarsecvarnormfile'
	//`msapop' is total population of `msavar' and appears in `msavarnormfile'
	//`geovar' is uniquely assigned to `msavar' in the file `geovarmsavarnormfile'
	//`keepif' is an optional condition that can be any argument; use `extramsavars' or `extrageosecvars' to load relevant covariates from `msavarnormfile' or `geovarsecvarnormfile', respectively
	//

	//(1) Open a normalized file containing geovar-secvar population counts
	//(2) Merge geovar with msavar
	//(3) Collapse to MSA level
	//(4) Merge msavar with MSA population counts
	//(5) Take log of secvar-msavar population counts and log of msavar total population counts
	//(6) Generate dummies for `secvar' and `secvar' interacted with log total population
	//(7) Save estimation array
	//(8) Run the elasticity regression
	//(9) Export regression results to TeX
	//(10) Save the elasticities for scatterplot purposes
	//(11) Produce scatterplot

	tempfile tf_secnum tf_array
	if "`debug'"=="debug" disp "Starting"

	//(1) Open a normalized file containing geovar-secvar population counts
	use `geovar' `secvar' `geosecpop' `extrageosecvars' using "`geovarsecvarnormfile'", clear
	if "`debug'"=="debug" disp "Step (1) done"

	if 	"`geovar'"~="`msavar'" {
		//(2) Merge geovar with msavar
		merge m:1 `geovar' using "`geovarmsavarnormfile'", keep(1 3) keepusing(`msavar') nogen

		//(3) Collapse to MSA level
		collapsewithlabels `geosecpop', by(`msavar' `secvar') statistic(sum)
		if "`debug'"=="debug" disp "Step (3) done"
	}

	//(4a) Merge msavar with MSA population counts
	merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) keepusing(`msapop' `extramsavars') nogen

	//(4b) Apply estimation-sample restrictions
	if "`keepif'"~="" keep if `keepif'

	//(5) Take log of secvar-msavar population counts and log of msavar total population counts
	foreach var of varlist `geosecpop' `msapop' {
		local `var'_label: var label `var'
		gen `var'_log = log(`var')
		label variable `var'_log "Log of ``var'_label'"
	}
	if "`debug'"=="debug" disp "Step (5) done"

	//(6) Generate dummies for `secvar' and `secvar' interacted with log total population
	tab `secvar', gen(secdummy)
	gen str secnum = ""
	foreach var of varlist secdummy*{
		local secnum = substr("`var'",9,length("`var'")-8)
		local `var'_label: var label `var'
		local seclabel = substr("``var'_label'",length("`secvar'==")+1,length("``var'_label'")-length("`secvar'=="))
		gen logpop_x_`secnum' = `msapop'_log * (`var'==1)
		label variable logpop_x_`secnum' "`seclabel' $\times$ log population"
		replace secnum = "`secnum'" if `var'==1
	}
	if "`debug'"=="debug" disp "Step (6) done"

	//(7) Save estimation array
	compress
	desc
	label data "Estimation array: population elasticity of `secvar' for `msavar'"
	if "`savearrayas'"~="" saveold "`savearrayas'", replace $saveoldversion
	save `tf_array', replace

	//Retain the `secvar' variable and accompanying labels
	destring secnum, ig("secdummy") replace
	collapse (firstnm) secnum, by(`secvar')
	if "`debug'"=="debug" list
	save `tf_secnum', replace //This data lets us map the dummies to the original `secvar'

	//(8) Run the elasticity regression
	use `tf_array', clear
	tempvar tv_clustervar
	egen `tv_clustervar' = group(`msavar')
	regress `geosecpop'_log logpop_x_* secdummy*, nocons vce(cluster `tv_clustervar')

	//(9) Export regression results to TeX
	if "`replace'"=="" local replace = "append"
	if "`ctitle'"~="" local ctitle = "ctitle(`ctitle')"
	qui count if e(sample)==1 & secdummy1==1
	local numberofMSAs = `r(N)'

	outreg2 using "`tablefilename'.tex", tex(pr landscape frag) keep(logpop_x_*) ///
		label  nocons noaster nor2 nonotes dec(3) ///
		`replace' `ctitle' addstat("Number of geographic units",`numberofMSAs')  //noobs
	if "`debug'"=="debug" disp "Step (9) done"

	//(10) Save the elasticities for scatterplot purposes
	if "`scatterplotname'"~="" {
		parmest , norestore 						//Change data set to be regression estimates
		keep if substr(parm,1,9)=="logpop_x_"		//Retain population elasticities
		rename estimate populationelasticity
		label var populationelasticity "Population elasticity"
		if "`debug'"=="debug" disp "Step (10) section 1 done"

		//Reattach `secvar' to these elasticities
		gen secnum = substr(parm,10,length(parm)-9)
		destring secnum, replace
		merge 1:1 secnum using `tf_secnum', keepusing(`secvar') assert(match) nogen  //Recover the original `secvar'
	}

	//(11) Produce scatterplot
	if "`scatterplotname'"~="" {
		local alternative = ""
		merge 1:1 `secvar' using "`skillintensitynormfile'", keep(3) nogen keepusing(skillintensity)
		if "`secvarmarkerfile'"~="" merge 1:1 `secvar' using "`secvarmarkerfile'", keep(3) nogen keepusing(`secvarmarkersize')
		if "`savescatterdata'"~="" saveold "`savescatterdata'", replace $saveoldversion

		twoway `alternative' (scatter populationelasticity skillintensity [w=`secvarmarkersize'], ytitle("Population elasticity") ///
		msymbol(Oh) mcolor(black) msize(medsmall)) (scatter populationelasticity skillintensity, ytitle("Population elasticity") ///
		ms(none) mlabel(`secvar') mlabsize(vsmall) mlabcolor(gs8)), xtitle("Skill intensity (employees' average years of schooling)") ///
		graphregion(color(white)) ylabel(,nogrid) legend(off)
		graph export "`scatterplotname'.pdf", as(pdf) replace
	}

	if "`debug'"=="debug" disp "Step (11) done"

end

cap program drop collapsewithlabels
program define collapsewithlabels
syntax varlist, statistic(string) by(varlist)

//This program performs a collapse while keeping the collpased variables labeled as they were pre-collapse

foreach var of varlist `varlist' {
	local `var'_label: var label `var'
	disp "``var'_label'"
}
collapse (`statistic') `varlist', by(`by')
foreach var of varlist `varlist' {
	label variable `var' "``var'_label'"
}

end
