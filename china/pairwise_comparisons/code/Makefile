# Definitions
folders=slurmlogs ../input ../output

input=\
	../input/townships_2000.dta \
	../input/pop_by_educ_townships_2000.dta

output=\
	../output/pairwise_edu_2000_4group.dta \
	../output/pairwise_edu_2000_4group.tex

# Recipes

all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../input/townships_2000.dta ../input/pop_by_educ_townships_2000.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi
