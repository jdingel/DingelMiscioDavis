# Definitions
folders=slurmlogs ../input ../output

input=\
	../input/allchina_township_class3.csv \
	../input/townships_2010_shapefile.csv \
	../input/all_china_townships_2000.dta \
	../input/china_townships_area_2000.csv \
	../input/china_townships_area_2010.csv \
	$(foreach lvl,10 20 30 40 50 60,../input/townships_2000_NTL$(lvl).csv) \
	$(foreach lvl,10 20 30 40 50 60,../input/townships_2010_NTL$(lvl).csv)

output=\
	../output/townships_2000.dta \
	../output/pop_by_educ_townships_2000.dta \
	../output/townships_2010.dta


#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/allchina_township_class3.csv ../input/townships_2010_shapefile.csv ../input/all_china_townships_2000.dta:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/townships%.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi
../input/china_townships_area_2000.csv ../input/china_townships_area_2010.csv:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
