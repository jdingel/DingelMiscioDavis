#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/municipios_2010.dta \
	../input/BR_MUNICIPIO_edupop_Census2010.dta \
	../input/msa_duranton_10pop_2010.dta

output=../output/popelast_edu_lpoly.pdf

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/municipios_2010.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi
../input/msa_duranton_10pop_2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_edupop_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
