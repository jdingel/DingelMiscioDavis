set more off
qui do "programs.do"

clean_census_data, saveas(../output/BR_MUNICIPIO_wages_Census2010) ///
  wagemin(1) wagemax(99) minage(25) maxage(65) ///
  geovar(municipio6)

municipio_demo_wages, using(../output/BR_MUNICIPIO_wages_Census2010) ///
  saveas(../output/BR_MUNICIPIO_demowages_Census2010) ///
  demovar(edu race age female) geovar(municipio6)

municipio_edu_wages, using(../output/BR_MUNICIPIO_demowages_Census2010) ///
  saveas(../output/BR_MUNICIPIO_eduwages_Census2010) ///
  demovar(edu) geovar(municipio6)
