cap program drop distance_gradients
program define distance_gradients
syntax, geospatialnormfile(string) geovar(string) ///
  geopop(string) geoarea(string) geolon(string) geolat(string) ///
  characteristic(string) msavar(string) msavarnormfile(string) ///
  secvar(string) geovarsecvarnormfile(string) geovarsecvarpop(string) ///
  tablefilename(string) [ctitle(string)] [plotname(string)] [keepif(string)] [debug] ///
  [replace]

tempfile tf_distgrad tf_geovarsecshare

use `geovar' `geopop' `geoarea' `msavar' `geolon' `geolat' if missing(`msavar')==0 & `geopop'!=0 using "`geospatialnormfile'", clear

//Population density = population/area
gen pop_density = `geopop'/`geoarea'

//Compute population-weighted centroid
sort `msavar'
by `msavar': egen `msavar'_total_`geovar' = total(1)
by `msavar': egen `msavar'_lat = wtmean(`geolat'), weight(`geopop')
by `msavar': egen `msavar'_lon = wtmean(`geolon'), weight(`geopop')

//Compute density-peak centroid
gsort `msavar' -pop_density
by `msavar': gen `msavar'_lat2 = `geolat'[1]
by `msavar': gen `msavar'_lon2 = `geolon'[1]

//Calculate distance from `geovar' centroid to `msavar' centroid
geodist `msavar'_lat `msavar'_lon `geolat' `geolon', gen(`msavar'_dist)
label variable `msavar'_dist "Kilometers to MSA center"
tempvar tv1
by `msavar': egen `tv1' = max(`msavar'_dist)
gen distance_normalized = `msavar'_dist / `tv1' if inrange(`msavar'_total_`geovar',2,.)
label variable distance_normalized "Distance to MSA center (as fraction of MSA radius)"

//Calculate distance from `geovar' centroid to `msavar' density-peak centroid
geodist `msavar'_lat2 `msavar'_lon2 `geolat' `geolon', gen(`msavar'_dist2)
label variable `msavar'_dist2 "Kilometers to MSA center (density peak)"
tempvar tv1
by `msavar': egen `tv1' = max(`msavar'_dist2)
gen distance2_normalized = `msavar'_dist2 / `tv1' if inrange(`msavar'_total_`geovar',2,.)
label variable distance2_normalized "Distance to MSA center (density peak) (as fraction of MSA radius)"

//Take logs
foreach x in pop_density `msavar'_dist {
  gen `x'_log = log(`x')
}
label var pop_density_log "log(population density)"
label var `msavar'_dist_log "log kilometers to city center"
save `tf_distgrad', replace

//Compute share of college graduates
use "`geovarsecvarnormfile'", clear
gen college = (`secvar'==4)
collapse college [aw=`geovarsecvarpop'], by(`geovar')
keep college `geovar'
label var college "share of college graduates"
save `tf_geovarsecshare', replace

//join in the share of college graduates
use `tf_distgrad', clear
merge 1:1 `geovar' using `tf_geovarsecshare', assert(using match) keep(match) nogen

// bring in MSA population data to apply sample restrictions
merge m:1 `msavar' using "`msavarnormfile'", assert(using match) keep(match) nogen
if "`keepif'"!="" keep if `keepif'

//Run the regressions
tempvar tv_clustervar
egen `tv_clustervar' = group(`msavar')
areg `characteristic' distance_normalized, absorb(`msavar') cl(`tv_clustervar')
  local numberofMSAs = `e(N_clust)'

//Export to TeX
if "`replace'"=="" local replace = "append"
if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

outreg2 using "`tablefilename'.tex", tex(pr landscape frag) ///
  label nocons noaster nor2 nonotes `replace' `ctitle' ///
  addstat("Number of geographic units", `numberofMSAs')

//Run regression for density-peak center collapse
areg `characteristic' distance2_normalized, absorb(`msavar') cl(`tv_clustervar')
  local numberofMSAs = `e(N_clust)'
outreg2 using "`tablefilename'_dist2.tex", tex(pr landscape frag) ///
  label nocons noaster nor2 nonotes `replace' `ctitle' ///
  addstat("Number of geographic units", `numberofMSAs')

//de-mean the dependent variables
sort `msavar'
by `msavar': egen `characteristic'_fe = mean(`characteristic')
by `msavar': gen `characteristic'_dm = `characteristic' - `characteristic'_fe

// save data
save "../output/distance_gradient_`characteristic'_`msavar'.dta", replace

//Produce plot of distance gradients
if "`plotname'"!="" {

  if `characteristic'==college {
    label var `characteristic'_dm "College graduate share (relative to MSA mean)"
  }
  if `characteristic'==pop_density_log {
    label var `characteristic'_dm "log of population density (relative to MSA mean)"
  }

  //linear polynomial plot
  local xvar = "distance_normalized"
  local xtitle = "Distance to metro center (as fraction of metro radius)" //temporary hard-coding due to tables and figures having different labels
  //local xtitle: variable label `xvar'
  qui summarize `msavar'_total_`geovar' if inrange(`msavar'_total_`geovar',2,.), d
  local constituents_median = `r(p50)'

  twoway (lpolyci `characteristic'_dm `xvar', lcol(cranberry) ciplot(rline) alp(shortdash) alc(cranberry) alw(vthin)) (lpolyci `characteristic'_dm `xvar' if inrange(`msavar'_total_`geovar',`constituents_median',.), lcol(blue) ciplot(rline) alp(shortdash) alc(blue) alw(vthin)), ///
    yti("`: variable label `characteristic'_dm'") xti(`xtitle') legend(order(2 4) label(2 All metros) label(4 Metros containing at least `constituents_median' municipios) nobox region(color(white))) ///
    graphregion(color(white))
  graph export "`plotname'.pdf", as(pdf) replace

}

end

cap program drop gradient_comparisons
program define gradient_comparisons
syntax, series1(string) series2(string) ///
  characteristic(string) ///
  [lpoly plotname(string) geovar(string) series1label(string) series2label(string)] ///
  [chow msavar1(string) msavar2(string) tablename(string)]

// load series 1 dataset; generate identifiers
use `characteristic'_dm `characteristic' distance_normalized `msavar1' using "`series1'.dta", clear
gen series1 = 1

// append series 2; fix identifiers
append using "`series2'.dta"
*merge 1:1 using "`series2'.dta", keepusing(`characteristic' distance_normalized `geovar') assert(master using) nogen
replace series1 = 0 if series1==.
gen series2 = (series1==0)

keep `characteristic' `characteristic'_dm distance_normalized `msavar1' `msavar2' series1 series2

if "`lpoly'"!="" {

  // prep graphics
  if "`characteristic'"=="college"{
  label var college_dm "college share (relative to metro mean)"
  }
  else {
  label var pop_density_log_dm "log of population density (relative to metro mean)"
  }

  local xvar = "distance_normalized"
  local xtitle: variable label `xvar'

  // plot
  twoway ///
    (lpolyci `characteristic'_dm `xvar' if series1==1, lcol(cranberry) ciplot(rline) alp(shortdash) alc(cranberry) alw(vthin)) ///
    (lpolyci `characteristic'_dm `xvar' if series2==1, lcol(blue) ciplot(rline) alp(shortdash) alc(blue) alw(vthin)), ///
    yti("`: variable label `characteristic''") xti(`xtitle') legend(order(2 4) label(2 "`series1label'") label(4 "`series2label'") nobox region(color(white))) ///
    graphregion(color(white))
  graph export "`plotname'.pdf", as(pdf) replace

}

if "`chow'"!="" {

  forval s=1/2 {
    gen dist_`s' = distance_normalized*series`s'
    qui tab `msavar`s'' if series`s'==1, gen(_msa`s'fe)
    qui reg `characteristic' distance_normalized _msa`s'fe* if series`s'==1
    est store series`s'
  }
  // set up clustering MSA variable
  tempvar tv_clustervar
  local option=1 // 1 = match MSAs ; 2 = disjoint MSAs

  if `option'==1 {
    // MSA var includes matches between two series
    replace `msavar1' = `msavar2' if series2==1
    egen `tv_clustervar' = group(`msavar1') // produces M1 u M2 clusters
  }
  if `option'==2 {
    // MSA var treats all MSAs as independent
    forval s=1/2 {
      replace `msavar`s''=0 if `msavar`s''==.
    }
    egen `tv_clustervar' = group(`msavar1' `msavar2') // produces M1 + M2 clusters
  }

  suest series1 series2, vce(cluster `tv_clustervar')
  local clust = `e(N_clust)'

  test [series1_mean]distance_normalized = [series2_mean]distance_normalized
  local p : di %4.3f `r(p)'

  file open CHOW using "`tablename'.txt", write replace
  file write CHOW "`p'" _n
  file write CHOW "`clust'"
  file close CHOW

}

end
