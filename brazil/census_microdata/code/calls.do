qui do "programs.do"

// education by age population counts
agepop_Census, saveas(../output/BR_MUNICIPIO_agepop_edupop_Census2010) ///
               minage(25) maxage(1000)
//educational group counts by municipio from 2000 to 2014
edupop_Census, saveas(../output/BR_MUNICIPIO_edupop_Census2010) ///
               minage(25) maxage(1000)

//occupational employment by municipio from 2000 to 2014
occpop_Census, saveas(../output/BR_MUNICIPIO_occpop_Census2010) ///
               minage(25) maxage(1000) formal(0) raisformal(0)

empskill_census, emp(occ) ///
                 using(../output/BR_MUNICIPIO_occpop_Census2010.dta) ///
                 saveas(../output/BR_AvgSch_occ_Census2010.dta)

//industrial group counts by municipio from 2000 to 2014
indpop_Census, saveas(../output/BR_MUNICIPIO_indpop_Census2010) ///
               minage(25) maxage(1000) formal(0) raisformal(0)

empskill_census, emp(ind) ///
                 using(../output/BR_MUNICIPIO_indpop_Census2010.dta) ///
                 saveas(../output/BR_AvgSch_ind_Census2010.dta)
