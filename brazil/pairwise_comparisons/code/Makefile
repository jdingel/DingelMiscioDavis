#Definitions
FOLDERS=slurmlogs ../input ../output

INPUT_BRAZIL=\
	../input/msapop_2010.dta \
	../input/municipios_2010.dta \
	../input/msa_municipio_2010_map.dta \
	../input/BR_MUNICIPIO_edupop_Census2010.dta

INPUT_CHINAINDIA=\
	../input/pairwise_edu_2000_4group.tex \
	../input/pairwise_edu_4group_0.tex

INPUT= $(INPUT_BRAZIL) $(INPUT_CHINAINDIA)

OUTPUT=\
	../output/binassignments.dta \
	../output/weights_edu.dta \
	../output/pairwise_edu.tex \
	../output/pairwise_edu.dta

#Recipes
all: $(FOLDERS) $(INPUT) $(OUTPUT) ../output/edu_pairwise.tex

$(FOLDERS):
	mkdir $@

# Brazil inputs
../input/municipios_2010.dta ../input/msa_municipio_2010_map.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi
../input/msapop_2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_edupop_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi
# foreign pairwise tables
../input/pairwise_edu_2000_4group.tex:
	if [ -e ../../../china/pairwise_comparisons/output/$(@F) ] ; then ln -s ../../../china/pairwise_comparisons/output/$(@F) ../input/ ; else exit 1; fi
../input/pairwise_edu_4group_0.tex:
	if [ -e ../../../india/pairwise_comparisons/output/$(@F) ] ; then ln -s ../../../india/pairwise_comparisons/output/$(@F) ../input/ ; else exit 1; fi

$(OUTPUT): $(INPUT_BRAZIL) calls.do programs.do run.sbatch | $(FOLDERS)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/edu_pairwise.tex: edu_pairwise.sh ../output/pairwise_edu.tex $(INPUT_CHINAINDIA)
	bash edu_pairwise.sh
