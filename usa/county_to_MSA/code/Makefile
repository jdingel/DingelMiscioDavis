# Definitions
folders=../input ../output slurmlogs

input=\
	../input/US_counties_2010.dta \
	../input/US_2010_mapping_counties2msa_omb.dta \
	../input/US_county_2010_nightlights.csv \
	$(foreach flow,$(shell seq 10 35),../input/Duranton_mapping_$(flow).dta)

output=../output/counties_2010.dta

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/US_counties_2010.dta:
	if [ -e ../../counties_loaddata/output/$(@F) ] ; then ln -s ../../counties_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/US_2010_mapping_counties2msa_omb.dta:
	if [ -e ../../CBSA/output/$(@F) ] ; then ln -s ../../CBSA/output/$(@F) ../input/ ; else exit 1; fi
../input/Duranton_mapping_%.dta:
	if [ -e ../../commuting/output/$(@F) ] ; then ln -s ../../commuting/output/$(@F) ../input/ ; else exit 1; fi
../input/US_county_2010_nightlights.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
