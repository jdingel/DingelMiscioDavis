qui do "programs.do"

// prepare normfile with US commuting data from American Community Survey
prepare_commuting_ACS using "../input/acs_commute_flows_table1.xlsx", ///
										 saveas("../output/US_counties_commuting.dta")
