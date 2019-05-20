qui do "programs.do"

// Combine output from different aggregation schemes
combine_msa_schemes, schemes(duranton nightlights) ///
                     saveas(../output/counties_2010.dta)
