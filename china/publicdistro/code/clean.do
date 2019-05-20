cap program drop clean_data
program define clean_data
syntax using/, outfile(string) keepvars(string) [dropvars(string)] [useif(string)]

use `useif' using "`using'", clear

order `keepvars' msa*_night
if "`dropvars'"!="" drop `dropvars'

outsheet `keepvars' msa*_night using "../output/`outfile'.csv", comma replace
end

clean_data using "../input/townships_2000.dta", ///
                  keepvars(gbtown name lat lon gbcnty population area_km2) ///
                  dropvars(type msa_prefecture gbpref) ///
                  outfile("townships_2000")

clean_data using "../input/townships_2010.dta", ///
                  keepvars(gbtown name lat lon gbcnty population area_km2) ///
                  outfile("townships_2010")

clean_data using "../input/counties_2000.dta", useif(if !inrange(gbcnty,1,3)) /// drop Special Administration Regions (SARs)
                  keepvars(gbcnty name lat lon population area_km2) ///
                  dropvars(type msa_prefecture gbpref) ///
                  outfile("counties_2000")

clean_data using "../input/counties_2010.dta", ///
                  keepvars(gbcnty name lat lon population area_km2) ///
                  outfile("counties_2010")
