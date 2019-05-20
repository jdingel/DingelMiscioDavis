# Definitions
folders= slurmlogs ../input ../output

input=\
	../input/counties_2000.dta \
	../input/counties_2010.dta \
	../input/townships_2000.dta \
	../input/townships_2010.dta

output=\
	../output/crosswalk_msa_2000.dta \
	../output/msa30_night_baseline_correlation_plot.pdf \
	../output/msa30_night_comparison.dta \
	../output/msa_prefecture_baseline_correlation_plot.pdf \
	../output/msa_prefecture_comparison.dta \
	../output/msa_compare_China_townships_counties_2000.tex

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/counties_20%0.dta:
	if [ -e ../../counties_loaddata/output/$(@F) ] ; then ln -s ../../counties_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/townships_20%0.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
