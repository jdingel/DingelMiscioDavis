#Definitions
folders=slurmlogs ../input ../output

states_list := AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO

input=\
	../input/CENSO10_pes.dta \
	$(foreach state,$(states_list),../input/CENSO10_$(state)_pes.dta)

output=\
	../output/BR_MUNICIPIO_demowages_Census2010.dta \
	../output/BR_MUNICIPIO_eduwages_Census2010.dta

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/CENSO10_pes.dta:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/CENSO10_%_pes.dta:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
