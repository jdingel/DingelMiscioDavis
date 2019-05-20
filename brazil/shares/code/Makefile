#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/BR_MSA_edupop_Census2010.dta \
	$(foreach sec,ind occ,../input/BR_MUNICIPIO_$(sec)pop_Census2010.dta)

output=\
	../output/edu_shares_Census.tex \
	../output/edu_shares_Census_fullpop.tex \
	../output/occ_shares_Census2010.dta \
	../output/ind_shares_Census2010.dta

#Recipes

all: $(folders) $(input) $(output) ../output/edu_shares_Census_All_and_Metro.tex

$(folders):
	mkdir $@

../input/BR_MSA_edupop_Census2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_%_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
../output/edu_shares_Census_All_and_Metro.tex: $(output) edu_shares_Census_All_and_Metro.sh
	bash edu_shares_Census_All_and_Metro.sh
