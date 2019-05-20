set more off
qui do "programs.do"

// Import and clean Brazilian municipio population data over several years
// (1940, 1950, 1960, 1970, 1980, 1991, 2000 and 2010).
municipio_pop, saveas(../output/BR_MUNICIPIO_POP)

/*
Read 7-digit municipio identification from the Brazilian municipio population
file to create a normalized files mapping municipio to geographic identifiers.
This is necessary because the true municipio geographic identifier consists of
only 6 digits. The last digit, appended at the end of each code is actually
computed from the other six digits. Instead of calculating this by hand,
which risks error, we extract the municipio codes from the population files we have,
which are already in 7-digit format for years dating back to 1940.
*/
municipio_geoid, saveas(../output/BR_municipio_geoid)
