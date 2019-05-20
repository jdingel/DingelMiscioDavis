#Definitions

folders=\
	slurmlogs \
	../input \
	../output

input=\
	../input/townships_2000.dta \
	../input/counties_2000.dta \
	../input/pop_by_educ_townships_2000.dta \
	../input/pop_by_educ_counties_2000.dta

output=$(foreach ext,tex txt,../output/popelast_eduagg_2000_100k_townships_counties_raw.$(ext))

# Recipes
all: $(folders) $(input) $(output) ../output/popelast_eduagg_2000_100k_townships_counties.tex

$(folders):
	mkdir $@

../input/counties_2000.dta ../input/pop_by_educ_counties_2000.dta:
	if [ -e ../../counties_loaddata/output/$(@F) ] ; then ln -s ../../counties_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/townships_2000.dta ../input/pop_by_educ_townships_2000.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do estimationarrays.do run.sbatch cleantables.sh | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/popelast_eduagg_2000_100k_townships_counties.tex: ../output/popelast_eduagg_2000_100k_townships_counties_raw.tex cleantables.sh
	bash cleantables.sh
