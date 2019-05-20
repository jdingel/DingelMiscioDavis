#Definitions
FOLDERS=slurmlogs ../input ../output

INPUTS_INITIALDATA=\
	$(foreach villa,$(shell seq 1 35),../input/village_2011_2001_$(villa).csv) \
	../input/subdistricts_directory.dta \
	../input/admin_level3.xls \
	../input/admin_level3_urban.xls \
	../input/town_2011_2001.csv

levels:= 10 20 30 40 50 60

INPUT=\
	../input/india_sub_districts_area.csv \
	$(foreach lvl,$(levels),$(foreach year,2001 2011,../input/mapping_sub_districts_$(year)_NTL$(lvl).csv)) \
	$(INPUTS_INITIALDATA)

OUTPUT=\
	$(foreach year,2001 2011,../output/India_subdistricts_$(year).dta) \
	../output/India_subdistrict_crosswalk_2001_2011.dta

#Recipes
all: $(FOLDERS) $(INPUT) $(OUTPUT)

$(FOLDERS):
	mkdir $@

$(INPUTS_INITIALDATA):
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/mapping_sub_districts_2001_NTL%.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi
../input/mapping_sub_districts_2011_NTL%.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi
../input/india_sub_districts_area.csv:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) ../input/ ; else exit 1; fi

$(OUTPUT): $(INPUT) calls.do programs.do run.sbatch | $(FOLDERS)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
