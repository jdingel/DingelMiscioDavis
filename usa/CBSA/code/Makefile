# Definitions
folders=../input ../output slurmlogs
input=../input/List1.txt ../input/List1_2013.xls
output=../output/US_2010_mapping_counties2msa_omb.dta

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/List1.txt ../input/List1_2013.xls:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
