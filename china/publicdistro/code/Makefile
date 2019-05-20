#Definitions
folders=slurmlogs ../input ../output
input=\
	../input/townships_2000.dta \
	../input/townships_2010.dta \
	../input/counties_2000.dta \
	../input/counties_2010.dta
output=\
	../output/townships_2000.csv \
	../output/townships_2010.csv \
	../output/counties_2000.csv \
	../output/counties_2010.csv

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/townships_2000.dta ../input/townships_2010.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/counties_2000.dta ../input/counties_2010.dta:
	if [ -e ../../counties_loaddata/output/$(@F) ] ; then ln -s ../../counties_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) clean.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e clean.do; fi
