cap program drop distance_gradients
program define distance_gradients
syntax, geospatialnormfile(string) geovar(string) ///
  geopop(string) geoarea(string) geolon(string) geolat(string) ///
  characteristic(string) msavar(string) ///
  [secvar(string) geovarsecvarnormfile(string) geovarsecvarpop(string) collegeif(string)] ///
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
gen college = (`collegeif')
collapse college [aw=`geovarsecvarpop'], by(`geovar')
keep college `geovar'
label var college "share of college graduates"
save `tf_geovarsecshare', replace

//join in the share of college graduates
use `tf_distgrad', clear
merge 1:1 `geovar' using `tf_geovarsecshare', assert(using match) keep(match) nogen

// generate MSA population and apply sample restrictions
sort `msavar'
by `msavar': egen totalpop = total(`geopop')
if "`keepif'"!="" keep if `keepif'

//Run the regressions
tempvar tv_clustervar
egen `tv_clustervar' = group(`msavar')
areg `characteristic' distance_normalized, absorb(`msavar') cl(`tv_clustervar')
  local numberofMSAs = `e(N_clust)'

//(9) Export to TeX
if "`replace'"=="" local replace = "append"
if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

outreg2 using "`tablefilename'_msa_night.tex", tex(pr landscape frag) ///
  label nocons noaster nor2 nonotes `replace' `ctitle' ///
  addstat("Number of geographic units", `numberofMSAs')

//Run regression for density-peak center collapse
areg `characteristic' distance2_normalized, absorb(`msavar') cl(`tv_clustervar')
  local numberofMSAs = `e(N_clust)'
outreg2 using "`tablefilename'_msa_night_dist2.tex", tex(pr landscape frag) ///
  label nocons noaster nor2 nonotes `replace' `ctitle' ///
  addstat("Number of geographic units", `numberofMSAs')

//de-mean the dependent variables
sort `msavar'
by `msavar': egen `characteristic'_fe = mean(`characteristic')
by `msavar': gen `characteristic'_dm = `characteristic' - `characteristic'_fe

// save data
save "`tablefilename'_`msavar'.dta", replace

//Produce plot of distance gradients
if "`plotname'"!="" {

  if `characteristic'==college {
    label var `characteristic'_dm "% college graduates (relative to MSA mean)"
  }
  if `characteristic'==pop_density_log {
    label var `characteristic'_dm "log of population density (relative to MSA mean)"
  }

  //linear polynomial plot
  local xvar = "distance_normalized"
  local xtitle: variable label `xvar'
  qui summarize `msavar'_total_`geovar' if inrange(`msavar'_total_`geovar',2,.), d
  local constituents_median = `r(p50)'

  twoway (lpolyci `characteristic'_dm `xvar', lcol(cranberry) ciplot(rline) alp(shortdash) alc(cranberry) alw(vthin)) (lpolyci `characteristic'_dm `xvar' if inrange(`msavar'_total_`geovar',`constituents_median',.), lcol(blue) ciplot(rline) alp(shortdash) alc(blue) alw(vthin)), ///
    yti("`: variable label `characteristic'_dm'") xti(`xtitle') legend(order(2 4) label(2 All MSAs) label(4 MSAs containing at least `constituents_median' geographic units)) ///
    graphregion(color(white))
  graph export "`plotname'.pdf", as(pdf) replace

}

end



cap program drop density_gradients
program define density_gradients
syntax, geospatialnormfile(string) geovar(string) ///
  geopop(string) geoarea(string) geolon(string) geolat(string) ///
  msavar(string) ///
  tablefilename(string) [ctitle(string)] [plotname(string)] [keepif(string)] [debug] ///
  [replace]

tempfile tf_distgrad tf_geovarsecshare

use `geovar' `geopop' `geoarea' `msavar' `geolon' `geolat' if missing(`msavar')==0 & `geopop'!=0 using "`geospatialnormfile'", clear

//Compute population-weighted centroid
sort `msavar'
by `msavar': egen `msavar'_total_`geovar' = total(1)
by `msavar': egen `msavar'_lat = wtmean(`geolat'), weight(`geopop')
by `msavar': egen `msavar'_lon = wtmean(`geolon'), weight(`geopop')

//Calculate distance from `geovar' centroid to `msavar' centroid
geodist `msavar'_lat `msavar'_lon `geolat' `geolon', gen(`msavar'_dist)
label variable `msavar'_dist "Kilometers to MSA center"
tempvar tv1
by `msavar': egen `tv1' = max(`msavar'_dist)
gen distance_normalized = `msavar'_dist / `tv1' if inrange(`msavar'_total_`geovar',2,.)
label variable distance_normalized "Distance to MSA center (as fraction of MSA radius)"

//Generate dependent variables

//Population density = population/area
gen pop_density = `geopop'/`geoarea'

//Take logs
foreach x in pop_density `msavar'_dist {
  gen `x'_log = log(`x')
}
label var pop_density_log "log(population density)"
label var `msavar'_dist_log "log kilometers to city center"
save `tf_distgrad', replace

// generate MSA population and apply sample restrictions
sort `msavar'
by `msavar': egen totalpop = total(`geopop')
if "`keepif'"!="" keep if `keepif'

//Run the regressions
tempvar tv_clustervar
egen `tv_clustervar' = group(`msavar')
areg pop_density_log distance_normalized, absorb(`msavar') cl(`tv_clustervar')
  local numberofMSAs = `e(N_clust)'

//(9) Export to TeX
if "`replace'"=="" local replace = "append"
if "`ctitle'"!="" local ctitle = "ctitle(`ctitle')"

outreg2 using "`tablefilename'_msa_night.tex", tex(pr landscape frag) ///
  label nocons noaster nor2 nonotes `replace' `ctitle' ///
  addstat("Number of geographic units", `numberofMSAs')

//Produce plot of distance gradients
if "`plotname'"!="" {

  //de-mean the dependent variables for linear polynomial
  sort `msavar'
  by `msavar': egen pop_density_log_fe = mean(pop_density_log)
  by `msavar': gen pop_density_log_dm = pop_density_log - pop_density_log_fe

  label var pop_density_log_dm "log of population density (relative to MSA mean)"

  //linear polynomial plot
  local xvar = "distance_normalized"
  local xtitle: variable label `xvar'
  qui summarize `msavar'_total_`geovar' if inrange(`msavar'_total_`geovar',2,.), d
  local constituents_median = `r(p50)'

  save "../output/`plotname'.dta", replace

  twoway (lpolyci pop_density_log_dm `xvar', lcol(cranberry) ciplot(rline) alp(shortdash) alc(cranberry) alw(vthin)) (lpolyci pop_density_log_dm `xvar' if inrange(`msavar'_total_`geovar',`constituents_median',.), lcol(blue) ciplot(rline) alp(shortdash) alc(blue) alw(vthin)), ///
    yti("`: variable label pop_density_log_dm'") xti(`xtitle') legend(order(2 4) label(2 All MSAs) label(4 MSAs containing at least `constituents_median' geographic units) nobox region(color(white))) ///
    graphregion(color(white))
  graph export "`plotname'.pdf", as(pdf) replace

}

end


cap program drop gradient_comparisons
program define gradient_comparisons
syntax, series1(string) series2(string) ///
  characteristic(string) ///
  [lpoly plotname(string) geovar(string) series1label(string) series2label(string)] ///
  [tstat msavar(string) tablename(string)]

// load series 1 dataset; generate identifiers
use `characteristic'_dm `characteristic' distance_normalized `msavar' using "`series1'.dta", clear
gen series1 = 1

// append series 2; fix identifiers
append using "`series2'.dta"
*merge 1:1 using "`series2'.dta", keepusing(`characteristic' distance_normalized `geovar') assert(master using) nogen
replace series1 = 0 if series1==.
gen series2 = (series1==0)

keep `characteristic' `characteristic'_dm distance_normalized `msavar' series1 series2

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

if "`tstat'"!="" {

  // distance interaction with series
  forval s=1/2 {
    gen dist_`s' = distance_normalized*series`s'
  }
  //create new metro identifer including matches between two series
  tostring `msavar', replace
  *replace `msavar'="" if `msavar'=="."
  gen new_`msavar' = substr(`msavar',1,7)
  tempvar tv_clustervar
  egen `tv_clustervar' = group(new_`msavar') // produces M1 u M2 clusters

  // Difference-in-differences cross-equation estimate
  reghdfe `characteristic' dist_2 distance_normalized, a(series1 new_`msavar') cl(`tv_clustervar')
  local clust = `e(N_clust)'
  test _b[dist_2]=0
  local p : di %5.4f `r(p)'

  file open tstat using "`tablename'.txt", write replace
  file write tstat "`p'" _n
  file write tstat "`clust'"
  file close tstat

}

end
