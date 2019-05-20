# Definitions
folders=../input ../output slurmlogs

input=\
	../input/tl_2010_us_county10.csv \
	../input/states.csv \
	../input/CO-EST2015-alldata.csv

output=../output/US_counties_2010.dta

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/tl_2010_us_county10.csv ../input/states.csv ../input/CO-EST2015-alldata.csv:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
