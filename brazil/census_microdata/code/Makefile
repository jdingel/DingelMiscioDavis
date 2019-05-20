#Definitions
folders=slurmlogs ../input ../output
input= ../input/CENSO10_pes.dta

output=\
	../output/BR_MUNICIPIO_agepop_edupop_Census2010.dta \
	../output/BR_MUNICIPIO_edupop_Census2010.dta \
	../output/BR_MUNICIPIO_indpop_Census2010.dta \
	../output/BR_MUNICIPIO_occpop_Census2010.dta \
	../output/BR_AvgSch_ind_Census2010.dta \
	../output/BR_AvgSch_occ_Census2010.dta

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/CENSO10_pes.dta:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
