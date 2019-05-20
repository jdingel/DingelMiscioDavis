set more off
qui do "programs.do"

make_normalized_geoyear, outputfile(../output/municipios_2010.dta) ///
                         commuting(5 10 15 20 25) ///
                         nightlights(msa10 msa20 msa30 msa40 msa50 msa60)


add_geographic_coordinates using "../output/municipios_2010.dta", ///
                         geofile("../input/brazil_municipios_area.csv") ///
                         saveas("../output/municipios_2010_withcoordinates.dta")

summarize_assignments using "../output/municipios_2010_withcoordinates.dta", ///
              outputtextfile(../output/MSAsummaries.txt) ///
              outputtablefile(../output/MSAsummaries_tables.txt)
