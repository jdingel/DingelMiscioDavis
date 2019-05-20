qui do "programs.do"
set matsize 11000

//clear old output
foreach ext in txt tex {
	cap rm ../output/distance_gradient_college_msa_night.`ext'
	cap rm ../output/distance_gradient_college_upperpanel.`ext'
	cap rm ../output/distance_gradient_college_lowerpanel.`ext'
}

// Lights at night
forvalues x = 10(10)50 {
	// produce plot for NTL 30 only
	local plot = ""
	if "`x'"=="30" local plot = "plotname(../output/distance_gradient_college_msa_night_`x')"

  distance_gradients, keepif(totalpop>100000) ///
		geospatialnormfile(../input/municipios_2010_withcoordinates) ///
  	geovar(municipio6) geopop(population) geoarea(area_km2) geolon(lon) geolat(lat) ///
		msavar(msa_night_`x') msavarnormfile(../input/msa_night_`x'pop_2010) ///
  	characteristic(college) secvar(edu) ///
  	geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010) geovarsecvarpop(edupop) ///
  	tablefilename(../output/distance_gradient_college_upperpanel) ctitle(Lights: `x') `plot'
}
// Commuting flows
forvalues d = 5(10)25 {
	distance_gradients, keepif(totalpop>100000) ///
		geospatialnormfile(../input/municipios_2010_withcoordinates) ///
		geovar(municipio6) geopop(population) geoarea(area_km2) geolon(lon) geolat(lat) ///
		msavar(msa_duranton_`d') msavarnormfile(../input/msa_duranton_`d'pop_2010) ///
		geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010) geovarsecvarpop(edupop) ///
		characteristic(college) secvar(edu) ///
		tablefilename(../output/distance_gradient_college_lowerpanel) ctitle(Commuting: `d')
}
// Arranjos
distance_gradients, keepif(totalpop>100000) ///
	geospatialnormfile(../input/municipios_2010_withcoordinates) ///
	geovar(municipio6) geopop(population) geoarea(area_km2) geolon(lon) geolat(lat) ///
	msavar(msa_arranjo) msavarnormfile(../input/msa_arranjopop_2010) ///
	geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010) geovarsecvarpop(edupop) ///
	characteristic(college)  secvar(edu) ///
	tablefilename(../output/distance_gradient_college_lowerpanel) ctitle(Arranjos)
// Microregions
distance_gradients, keepif(totalpop>100000) ///
	geospatialnormfile(../input/municipios_2010_withcoordinates) ///
	geovar(municipio6) geopop(population) geoarea(area_km2) geolon(lon) geolat(lat) ///
	msavar(msa_microrregio) msavarnormfile(../input/msa_microrregiopop_2010) ///
	geovarsecvarnormfile(../input/BR_MUNICIPIO_edupop_Census2010) geovarsecvarpop(edupop) ///
	characteristic(college)  secvar(edu) ///
	tablefilename(../output/distance_gradient_college_lowerpanel) ctitle(Microregions)


// cross-equation tests
forval x = 10(10)50 {

	gradient_comparisons, chow characteristic(college) ///
		series1(../output/distance_gradient_college_msa_night_`x') msavar1(msa_night_`x') ///
		series2(../output/distance_gradient_college_msa_microrregio) msavar2(msa_microrregio) ///
		tablename(../output/college_distance_gradient_ntl`x'_microregions_chow)

	gradient_comparisons, chow characteristic(college) ///
		series1(../output/distance_gradient_college_msa_night_`x') msavar1(msa_night_`x') ///
		series2(../output/distance_gradient_college_msa_arranjo) msavar2(msa_arranjo) ///
		tablename(../output/college_distance_gradient_ntl`x'_arranjos_chow)

	}
