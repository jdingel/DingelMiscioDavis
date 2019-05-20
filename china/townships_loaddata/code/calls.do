qui do "programs.do"

//Night lights: Normalized files for township-year and county-year with different MSA assignments under different schema
make_normalized_geoyear, geo(townships) ///
                         year(2000) ///
                         saveas("../output/townships_2000.dta") ///
                         raster("F152000.v4b_web.stable_lights.avg_vis") ///
                         mappings(msa10_night msa20_night msa30_night msa40_night msa50_night msa60_night)

//Generate normalized files for townships2000
pop_by_edu_townships_2000 using "../input/all_china_townships_2000.dta", ///
                          saveas("../output/pop_by_educ_townships_2000.dta")

//Night lights 2010
make_normalized_geoyear, geo(townships) ///
                         year(2010) ///
                         saveas("../output/townships_2010.dta") ///
                         raster("F182010.v4d_web.stable_lights.avg_vis") ///
                         mappings(msa10_night msa20_night msa30_night msa40_night msa50_night msa60_night)
