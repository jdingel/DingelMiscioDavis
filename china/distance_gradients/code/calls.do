qui do "programs.do"
set matsize 11000

//clear old output
foreach x in townships counties {
	cap rm ../output/distance_gradient_college_`x'_2000_msa_night.tex
	cap rm ../output/distance_gradient_college_`x'_2000_msa_night.txt
}


forvalues x = 10(10)60 {

// Townships 2000
distance_gradients, keepif(totalpop>100000) ///
										geospatialnormfile(../input/townships_2000.dta) ///
  									geovar(gbtown) geopop(population) ///
										geoarea(area_km2) geolon(lon) geolat(lat) ///
										msavar(msa`x'_night) ///
  									characteristic(college) secvar(educ_cat) collegeif(educ_cat==7|educ_cat==8|educ_cat==9) ///
  									geovarsecvarnormfile(../input/pop_by_educ_townships_2000) geovarsecvarpop(pop_educ) ///
  									tablefilename(../output/distance_gradient_college_townships_2000) ctitle(Lights, `x')

// Counties 2000
distance_gradients, keepif(totalpop>100000) ///
										geospatialnormfile(../input/counties_2000.dta) ///
  									geovar(gbcnty) geopop(population) ///
										geoarea(area_km2) geolon(lon) geolat(lat) ///
										msavar(msa`x'_night) ///
  									characteristic(college) secvar(educ_cat) collegeif(educ_cat==7|educ_cat==8|educ_cat==9) ///
  									geovarsecvarnormfile(../input/pop_by_educ_counties_2000) geovarsecvarpop(pop_educ) ///
  									tablefilename(../output/distance_gradient_college_counties_2000) ctitle(Lights, `x')

}

// cross-equation tests
forval x = 10(10)60 {
	gradient_comparisons, tstat msavar(msa`x'_night) characteristic(college) ///
		series1(../output/distance_gradient_college_townships_2000_msa`x'_night) ///
		series2(../output/distance_gradient_college_counties_2000_msa`x'_night) ///
		tablename(../output/college_distance_gradient_ntl`x'_townships_counties_tstat)
	}
