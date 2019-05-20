# Definitions
folders=slurmlogs ../input ../output

input=\
	../input/pop_by_educ_townships_2000.dta \
	../input/townships_2000.dta

output=../output/edu_shares_msa30_night.tex

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/townships_2000.dta ../input/pop_by_educ_townships_2000.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
