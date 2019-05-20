# Definitions
folders=\
	../input \
	../output \
	slurmlogs

input=\
	../input/allchina_township_class3.csv \
	../input/County2000.xls \
	../input/2010CountyCensusL.xlsx \
	../input/2010CountyCensusA.xlsx \
	../input/china_counties_area_2000.csv \
	../input/china_counties_area_2010.csv \
	../input/2010CountyCensusA.dta \
	../input/county_2000_shapefile.csv \
	$(foreach lvl,10 20 30 40 50 60,../input/counties_2000_NTL$(lvl).csv) \
	$(foreach lvl,10 20 30 40 50 60,../input/counties_2010_NTL$(lvl).csv)


output=\
	../output/counties_2000.dta \
	../output/pop_by_educ_counties_2000.dta \
	../output/counties_2010.dta \
	../output/pop_by_educ_counties_2010.dta

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/allchina_township_class3.csv ../input/County2000.xls ../input/2010CountyCensusA.xlsx ../input/2010CountyCensusL.xlsx ../input/2010CountyCensusA.dta:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/county_2000_shapefile.csv:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/China_2000_mapping_counties_msa%.csv:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/China_2010_mapping_counties_msa%.csv:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/counties_2000_NTL%.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi
../input/counties_2010_NTL%.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi
../input/china_counties_area_2000.csv ../input/china_counties_area_2010.csv:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
