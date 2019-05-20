qui do "programs.do"

//Night lights: Normalized files for township-year and county-year with different MSA assignments under different schema
make_normalized_geoyear, geo(counties) ///
                         year(2000) ///
                         saveas("../output/counties_2000.dta") ///
                         raster("F152000.v4b_web.stable_lights.avg_vis") ///
                         mappings(msa10_night msa20_night msa30_night msa40_night msa50_night msa60_night)

make_normalized_geoyear, geo(counties) ///
                         year(2010) ///
                         saveas("../output/counties_2010.dta") ///
                         raster("F182010.v4d_web.stable_lights.avg_vis") ///
                         mappings(msa10_night msa20_night msa30_night msa40_night msa50_night msa60_night)

//Generate normalized files for counties2000
pop_by_edu_counties_2000 using "../input/County2000.xls", ///
                         saveas("../output/pop_by_educ_counties_2000.dta")

//Generate normalized files for counties2010
pop_by_edu_counties_2010 using "../input/2010CountyCensusA.xlsx", ///
                         saveas("../output/pop_by_educ_counties_2010.dta")
