cap program drop clean_data
program define clean_data
syntax using/, outfile(string) keepvars(string) [dropvars(string)] [useif(string)]

use `useif' using "`using'", clear

order `keepvars' msa*
ren (msa*) (msa*_night)
if "`dropvars'"!="" drop `dropvars'

outsheet `keepvars' msa*_night using "../output/`outfile'.csv", comma replace
end


clean_data using "../input/India_subdistricts_2001.dta", ///
                  keepvars(GEOKEY ADMIND_NAM STATE lat lon pop_2001_urban pop_2001_total area_km2 STATE_NAME DISTRICT DIST_NAME SUB_DIST TOWN SUBDIST2) ///
                  dropvars(ADMTYPE) ///
                  outfile("subdistricts_2001")
clean_data using "../input/India_subdistricts_2011.dta", ///
                  keepvars(GEOKEY ADMIND_NAM STATE lat lon pop_2011_urban pop_2011_total area_km2 STATE_NAME DISTRICT DIST_NAME SUB_DIST TOWN SUBDIST2) ///
                  dropvars(ADMTYPE) ///
                  outfile("subdistricts_2011")
