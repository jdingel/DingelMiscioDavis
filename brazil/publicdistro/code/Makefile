#Definitions
folders=slurmlogs ../input ../output
input=../input/municipios_2010.dta
output=../output/municipios_2010.csv

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/municipios_2010.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) clean.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e clean.do; fi
