//
// These programs regress MSA wages and skill premia on MSA size
//

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

/****************************************************************************
// A. This program regresses average nominal wage on log MSA population and demographics
*****************************************************************************/

cap program drop estimationarray_urbanwagepremia
program define estimationarray_urbanwagepremia
syntax, geovardemovarnormfile(string) geovarmsavarnormfile(string) msavarnormfile(string) ///
  incvar(string) geovar(string) demovar(namelist min=1) msavar(string) geodemopop(string) msapop(string) ///
  [savearrayas(string)] tablefilename(string) [replace] [ctitle(string)] [debug] [keepif(string)]


  //(1) Open a normalized file containing geovar-demovar population counts and wages
  //(2) Merge geovar with msavar
  //(3) Collapse to MSA level
  //(4) Merge msavar with MSA population counts
  //(5) Take logs of msavar total population counts and income variable
  //(6) Generate dummies for `demovar'
  //(7) Save estimation array
  //(8) Run the urban premia regression
  //(9) Export regression results to TeX


  tempfile tf_array
  if "`debug'"=="debug" di "Starting"

  //(1) Open the normalized file containing geovar-demovar population counts
  use `geovar' `demovar' `geodemopop' `incvar' using "`geovardemovarnormfile'", clear

  if "`geovar'"~="`msavar'" {

    //(2) Merge geovar with msavar
    merge m:1 `geovar' using "`geovarmsavarnormfile'", keep (1 3) nogen

    //(3) Collapse to MSA level
    collapse (rawsum) `geodemopop' (mean) `incvar' [aw=`geodemopop'], by(`msavar' `demovar')

    if "`debug'"=="debug" disp "Step (3) done"

  }

  //(4a) Merge msavar with MSA population counts
  merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) nogen

  //(4b) Apply estimation-sample restrictions
  if "`keepif'"~="" keep if `keepif'

  //(5) Take logs of msavar total population counts and income variable
  foreach var of varlist `msapop' `incvar' {
    local `var'_label: var label `var'
    gen `var'_log = log(`var')
    label var `var'_log "Log of ``var'_label'"
  }
  if "`debug'"=="debug" disp "Step (5) done"

  //(6) Generate dummies for `demovar'
  foreach x in `demovar' {
    qui tab `x', gen(`x'dummy)
  }
  if "`debug'"=="debug" disp "Step (6) done"

  //(7) Save estimation array
  compress
  desc
  label data "Estimation array: urban wage premia for `msavar'"
  if "`savearrayas'"~="" saveold "`savearrayas'", replace $saveoldversion
  save `tf_array', replace

  //(8) Run the urban wage premia regression
		// quick set up of the demographic control vector
			local democovs "racedummy* female agedummy* edudummy*"
  use `tf_array', clear
  tempvar tv_clustervar
  egen `tv_clustervar' = group(`msavar')
  reg `incvar'_log `msapop'_log `democovs' [aw=`geodemopop'], cl(`tv_clustervar')
		local numberofMSAs = `e(N_clust)'
  //(9) Export regression results to TeX
  if "`replace'"=="" local replace = "append"
  if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

  outreg2 using "`tablefilename'.tex", tex(pr landscape frag) ///
		keep(`msapop'_log) label nocons noaster nor2 nonotes ///
    `replace' `ctitle' addstat("Number of geographic units", `numberofMSAs')
  if "`debug'"=="debug" disp "Step (9) done"

end


/****************************************************************************
// B. This program regresses (demographic-adjusted) skill premia on log MSA population
*****************************************************************************/

cap program drop estimationarray_skillpremia
program define estimationarray_skillpremia
syntax, geovardemovarnormfile(string) geovarmsavarnormfile(string) ///
  msavarnormfile(string) incvar(string) geovar(string) skill(string) skillpremia(string) ///
  msavar(string) msapop(string) geodemopop(string) [savearrayas(string)] ///
	tablefilename(string) [replace] [ctitle(string)] [debug] [keepif(string)]


	//(1) Open a normalized file containing geovar population counts and wages
  //(2) Define skill according to 2 categories
	//(3a) Merge geovar with msavar
  //(3b) Collapse to Skill x MSA level
  //(4) Compute skill premium at the MSA level
	//(5) Merge msavar with MSA population counts
  //(6) Take log of demovar-msavar population counts and log of msavar total population counts
  //(7) Save estimation array
  //(8) Run the skill premia regression
  //(9) Export regression results to TeX


	tempfile tf_array
	if "`debug'"=="debug" di "Starting"

  //(1) Open normalized file containing geovar-demovar population counts
  use `geovar' edu `geodemopop' `incvar' `incvar'_residuals using `geovardemovarnormfile', clear

  //(2) Define skill
  //skilled = college graduate; unskilled = high school graduate
  drop if (edu==1 | edu==2)
  gen `skill'=(edu==4)

  if "`geovar'"~="`msavar'" {

    //(3a) Merge geovar with msavar
    merge m:1 `geovar' using "`geovarmsavarnormfile'", keep (1 3) nogen

    //(3b) Collapse to Skill x MSA level
    collapse (mean) `incvar' `incvar'_residuals (rawsum) `geodemopop' [aw=`geodemopop'], by(`skill' `msavar')

    if "`debug'"=="debug" disp "Step (3) done"

  }

  //(4) Compute skill premium at the MSA level
  gen `skillpremia' = `incvar'_residuals if `skill'==1
  replace `skillpremia' = -(`incvar'_residuals) if `skill'==0
	label var `skillpremia' "skill premium"
  collapsewithlabels `skillpremia' `geodemopop', statistic(sum) by(`msavar')

  //(5a) Merge msavar with MSA population counts
  merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) nogen

  //(5b) Apply estimation-sample restrictions
  if "`keepif'"~="" keep if `keepif'

  //(6) Take logs of msavar total population counts and skill premium
  foreach var of varlist `msapop' {
    local `var'_label: var label `var'
    gen `var'_log = log(`var')
    label var `var'_log "Log of ``var'_label'"
  }
  if "`debug'"=="debug" disp "Step (5) done"

	//(7) Save estimation array
	compress
	desc
	label data "Estimation array: skill premia for `msavar'"
	if "`savearrayas'"~="" saveold "`savearrayas'", replace $saveoldversion
	save `tf_array', replace

	//(8) Run the skill premia regression
	use `tf_array', clear
	tempvar tv_clustervar
	egen `tv_clustervar' = group(`msavar')
	reg `skillpremia' `msapop'_log, cl(`tv_clustervar')
		local numberofMSAs = `e(N_clust)'

	//(9) Export regression results to TeX
	if "`replace'"=="" local replace = "append"
	if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

	outreg2 using "`tablefilename'.tex", tex(pr landscape frag) keep(`msapop'_log) label nocons noaster nor2 nonotes ///
		`replace' `ctitle' //addstat("Number of metropolitan areas", `numberofMSAs')

	if "`debug'"=="debug" disp "Step (9) done"

end

/****************************************************************************
// C. This program runs Human Capital (HK) Externality regressions
*****************************************************************************/

cap program drop estimationarray_hkexternalities
program define estimationarray_hkexternalities
syntax, geovardemovarnormfile(string) geovarmsavarnormfile(string) msavarnormfile(string) ///
  incvar(string) geovar(string) demovar(namelist min=1) msavar(string) geodemopop(string) msapop(string) ///
	secvar(string) geovarsecvarnormfile(string) geovarsecvarpop(string) ///
  [savearrayas(string)] tablefilename(string) [replace] [ctitle(string)] [debug] [keepif(string)]


  //(1) Open a normalized file containing individual wages
  //(2) Merge geovar with msavar
	//(3) Collapse to MSA level
  //(4) Merge msavar with MSA population counts
	//(5) Compute MSA share of college graduates using geovarsecvarnormfile
  //(6) Sample restrictions + Take logs of msavar total population counts and income variable
  //(7) Generate dummies for `demovar'
  //(8) Save estimation array
  //(9a) Run the HK externalities regression without log MSA Population
	//(10a) Export results to TeX
	//(9b) Run the HK externalities regression with log MSA Population
	//(10b) Export results to TeX


  tempfile tf_msavarsecvarnormfile tf_array
  if "`debug'"=="debug" di "Starting"

  //(1) Open the normalized file containing geovar-demovar population counts
  use `geovar' `demovar' `geodemopop' `incvar' using "`geovardemovarnormfile'", clear

  if "`geovar'"!="`msavar'" {

    //(2) Merge geovar with msavar
    merge m:1 `geovar' using "`geovarmsavarnormfile'", keep (1 3) nogen

		//(3) Collapse to MSA level
    collapse (rawsum) `geodemopop' (mean) `incvar' [aw=`geodemopop'], by(`msavar' `demovar')

    if "`debug'"=="debug" disp "Step (3) done"

  }

  //(4) Merge msavar with MSA population counts
  merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) nogen

	//(5) Compute MSA share of college graduates
	preserve
	use `geovar' `secvar' `geovarsecvarpop' using "`geovarsecvarnormfile'", clear
	gen college = (edu==4)
	merge m:1 `geovar' using "`geovarmsavarnormfile'", keep (1 3) nogen
	collapse college [aw=`geovarsecvarpop'], by(`msavar')
	keep college `msavar'
	replace college = college*100 // this makes the coefficients more intelligible
	label var college "MSA share of college graduates"
	save `tf_msavarsecvarnormfile', replace
	restore
	merge m:1 `msavar' using `tf_msavarsecvarnormfile', keep (1 3) nogen

  //(6a) Apply estimation-sample restrictions
  if "`keepif'"!="" keep if `keepif'

  //(6b) Take logs of msavar total population counts and income variable
  foreach var of varlist `msapop' `incvar' {
    local `var'_label: var label `var'
    gen `var'_log = log(`var')
    label var `var'_log "Log of ``var'_label'"
  }
  if "`debug'"=="debug" disp "Step (6) done"

  //(7) Generate dummies for `demovar'
  foreach x in `demovar' {
    qui tab `x', gen(`x'dummy)
  }
  if "`debug'"=="debug" disp "Step (7) done"

  //(8) Save estimation array
  compress
  desc
  label data "Estimation array: HK externalities for `msavar'"
  if "`savearrayas'"~="" saveold "`savearrayas'", replace $saveoldversion
  save `tf_array', replace

  //(9a) Run the HK externalities regression without log MSA population
		// quick set up of the demographic control vector
			local democovs "racedummy* female agedummy* edudummy*"
  use `tf_array', clear
  tempvar tv_clustervar
  egen `tv_clustervar' = group(`msavar')
  reg `incvar'_log college `democovs', cl(`tv_clustervar')
		local numberofMSAs = `e(N_clust)'

  //(10a) Export regression results to TeX
  if "`replace'"=="" local replace = "append"
  if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

  outreg2 using "`tablefilename'.tex", tex(pr landscape frag) ///
		keep(college) label nocons noaster nor2 nonotes ///
    `replace' `ctitle' addstat("Number of geographic units", `numberofMSAs')

	//(9b) Run the HK externalities regression with log MSA population
		// quick set up of the demographic control vector
			local democovs "racedummy* female agedummy* edudummy*"
	use `tf_array', clear
	tempvar tv_clustervar
	egen `tv_clustervar' = group(`msavar')
	reg `incvar'_log college `msapop'_log `democovs', cl(`tv_clustervar')
		local numberofMSAs = `e(N_clust)'

	//(10b) Export regression results to TeX
	if "`replace'"=="" local replace = "append"

	outreg2 using "`tablefilename'.tex", tex(pr landscape frag) ///
		keep(college `msapop'_log) label nocons noaster nor2 nonotes ///
		`replace' `ctitle' addstat("Number of geographic units", `numberofMSAs')
	if "`debug'"=="debug" disp "Step (9) done"

end


/****************************************************************************
// D. This program runs Human Capital (HK) Externality regressions
*****************************************************************************/

cap program drop estimationarray_hce_pop
program define estimationarray_hce_pop
syntax, geovardemovarnormfile(string) geovarmsavarnormfile(string) msavarnormfile(string) ///
  incvar(string) geovar(string) demovar(namelist min=1) msavar(string) geodemopop(string) msapop(string) ///
  secvar(string) geovarsecvarnormfile(string) geovarsecvarpop(string) ///
  [savearrayas(string)] tablefilename(string) [replace] [ctitle(string)] [debug] [keepif(string)]


  //(1) Open a normalized file containing individual wages
  //(2) Merge geovar with msavar
  //(3) Collapse to MSA level
  //(4) Merge msavar with MSA population counts
  //(5) Compute MSA share of college graduates using geovarsecvarnormfile
  //(6) Sample restrictions + Take logs of msavar total population counts and income variable
  //(7) Generate dummies for `demovar'
  //(8) Save estimation array
  //(9) Run the HK externalities regression without log MSA Population
  //(10) Export results to TeX


  tempfile tf_msavarsecvarnormfile tf_array
  if "`debug'"=="debug" di "Starting"

  //(1) Open the normalized file containing geovar-demovar population counts
  use `geovar' `demovar' `geodemopop' `incvar' id using "`geovardemovarnormfile'", clear

  if "`geovar'"!="`msavar'" {

    //(2) Merge geovar with msavar
    merge m:1 `geovar' using "`geovarmsavarnormfile'", keep (1 3) nogen

    //(3) Collapse to MSA level
    collapse (rawsum) id `geodemopop' (mean) `incvar' [aw=`geodemopop'], by(`msavar' `demovar')

    if "`debug'"=="debug" disp "Step (3) done"

  }

  //(4) Merge msavar with MSA population counts
  merge m:1 `msavar' using "`msavarnormfile'", keep(1 3) nogen

  //(5) Compute MSA share of college graduates
  preserve
  use `geovar' `secvar' `geovarsecvarpop' using "`geovarsecvarnormfile'", clear
  gen college = (edu==4)
  merge m:1 `geovar' using "`geovarmsavarnormfile'", keep (1 3) nogen
  collapse college [aw=`geovarsecvarpop'], by(`msavar')
  keep college `msavar'
  replace college = college*100 // this makes the coefficients more intelligible
  label var college "MSA share of college graduates"
  save `tf_msavarsecvarnormfile', replace
  restore
  merge m:1 `msavar' using `tf_msavarsecvarnormfile', keep (1 3) nogen

  //(6a) Apply estimation-sample restrictions
  if "`keepif'"!="" keep if `keepif'

  //(6b) Take logs of msavar total population counts and income variable
  foreach var of varlist `msapop' `incvar' {
    local `var'_label: var label `var'
    gen `var'_log = log(`var')
    label var `var'_log "Log of ``var'_label'"
  }
  if "`debug'"=="debug" disp "Step (6) done"

  //(7) Generate dummies for `demovar'
  foreach x in `demovar' {
    qui tab `x', gen(`x'dummy)
  }
  if "`debug'"=="debug" disp "Step (7) done"

  //(8) Save estimation array
  compress
  desc
  label data "Estimation array: HCE + population for `msavar'"
  if "`savearrayas'"~="" saveold "`savearrayas'", replace $saveoldversion
  save `tf_array', replace

  //(9) Run the HK externalities regression with log MSA population
    // quick set up of the demographic control vector
      local democovs "racedummy* female agedummy* edudummy*"
  use `tf_array', clear
  tempvar tv_clustervar
  egen `tv_clustervar' = group(`msavar')
  reg `incvar'_log college `msapop'_log `democovs', cl(`tv_clustervar')
		egen Nfull = total(id) if e(sample)
		format Nfull %20.10f
		local N = Nfull
    local numberofMSAs = `e(N_clust)'
  if "`debug'"=="debug" disp "Step (9) done"

  //(10b) Export regression results to TeX
  if "`replace'"=="" local replace = "append"
  if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

  outreg2 using "`tablefilename'.tex", tex(pr landscape frag) ///
    keep(college `msapop'_log) label nocons noaster nor2 nonotes ///
    `replace' `ctitle' addstat("Full Sample", `N', "Number of geographic units", `numberofMSAs') afmt(f)
  if "`debug'"=="debug" disp "Step (10) done"

end
