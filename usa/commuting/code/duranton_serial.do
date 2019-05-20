qui do "programs.do"

//serial
forval x=10/35 {
   Duranton_MSA_aggregation, thresh(`x') ///
 		commuting_file("../output/US_counties_commuting.dta") ///
 		saveas1("../output/Duranton_steps_`x'.dta") ///
 		saveas2("../output/Duranton_mapping_`x'.dta")
}
