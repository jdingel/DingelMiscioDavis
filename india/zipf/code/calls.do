qui do "programs.do"

// Zipf regressions tables
msa_zipf_compare_table_India using "../input/India_subdistricts_2001.dta", ///
	msalist(msa*) minimumpopulation(100000) population(pop_2001_urban) ///
	tablefilename(../output/msa_compare_zipf_India_SDT_2001.tex)

msa_zipf_compare_table_India using "../input/India_subdistricts_2011.dta", ///
	msalist(msa*) minimumpopulation(100000) population(pop_2011_urban) ///
	tablefilename(../output/msa_compare_zipf_India_SDT_2011.tex)

//all MSAs (0 threshold)
use "../input/MSAs_2001.dta", clear
ranksize_figuremaker, population(population) ///
					  geounitvar(MSACode) ///
					  minimumpopulation(100000) ///
					  figfilename(../output/zipfplot_allMSAs.pdf)

//Nightlights-based aggregations of sub-districts: 2001/2011
local x=30

use "../input/India_subdistricts_2001.dta", clear
	ranksize_figuremaker, population(pop_2001_urban) ///
						  geounitvar(msa`x') ///
						  minimumpopulation(100000) ///
						  figfilename(../output/zipfplot_2001_SDT_msa`x'.pdf)

use "../input/India_subdistricts_2011.dta", clear
	ranksize_figuremaker, population(pop_2011_urban) ///
						  geounitvar(msa`x') ///
						  minimumpopulation(100000) ///
						  figfilename(../output/zipfplot_2011_SDT_msa`x'.pdf)

//2011 Urban Agglomerations + large Towns
use "../input/Towns_notbelongtoUAs.dta", clear
replace UACode = 9000 + _n
merge 1:1 StateCode UACode using "../input/UAs.dta", assert(1 2) nogen
egen UA_identifier = group(StateCode UAC)
ranksize_figuremaker, population(TOT_P) ///
					  geounitvar(UA_identifier) ///
					  minimumpopulation(100000) ///
					  figfilename(../output/zipfplot_2011_UAsandnonUAs.pdf)
