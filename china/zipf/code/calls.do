clear all
set more off
qui do "programs.do"

//Zipf Tables
msa_zipf_compare_table_China using "../input/townships_2000.dta", ///
	msalist(msa*_night) minimumpopulation(100000) ///
	tablefilename(../output/msa_compare_zipf_China_townships_2000.tex)

msa_zipf_compare_table_China using "../input/townships_2010.dta", ///
	msalist(msa*_night) minimumpopulation(100000) ///
	tablefilename(../output/msa_compare_zipf_China_townships_2010.tex)

//Zipf Figures
local msascheme="msa30_night"
// Townships 2000
use if missing(`msascheme')==0 using "../input/townships_2000.dta", clear
collapse (sum) population, by(`msascheme')
ranksize_figuremaker, population(population) ///
											geounitvar(`msascheme') ///
											minimumpopulation(100000) ///
											figfilename(../output/2000_townships_`msascheme'_100k.pdf) ///
											additionalnote("Census 2000. Metropolitan areas defined by aggregating townships based on lights at night.")

//Townships 2010
use if missing(`msascheme')==0 using "../input/townships_2010.dta", clear
collapse (sum) population, by(`msascheme')
ranksize_figuremaker, population(population) ///
											geounitvar(`msascheme') ///
											minimumpopulation(100000) ///
											figfilename(../output/2010_townships_`msascheme'_100k.pdf) ///
											additionalnote("Census 2010. Metropolitan areas defined by aggregating townships based on lights at night.")
