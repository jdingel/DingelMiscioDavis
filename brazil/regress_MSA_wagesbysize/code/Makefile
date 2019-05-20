#Definitions

folders=slurmlogs ../input ../output

input=\
	$(foreach lvl,10 20 30 40 50,../input/msa_night_$(lvl)pop_2010.dta) \
	$(foreach lvl,5 10 15 20 25,../input/msa_duranton_$(lvl)pop_2010.dta) \
	../input/msa_microrregiopop_2010.dta \
	../input/municipios_2010.dta \
	../input/msa_arranjopop_2010.dta \
	../input/BR_MUNICIPIO_eduwages_Census2010.dta \
	../input/BR_MUNICIPIO_demowages_Census2010.dta \
	../input/BR_MUNICIPIO_edupop_Census2010.dta

output=\
	../output/hce_pop_wage_Census2010_upperpanel.tex \
	../output/hce_pop_wage_Census2010_lowerpanel.tex \
	../output/hce_pop_wage_Census2010.tex \
	../output/skillpremia3_Census2010_upperpanel.tex \
	../output/skillpremia3_Census2010_lowerpanel.tex \
	../output/skillpremia3_Census2010.tex

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/BR_MUNICIPIO_demowages_Census2010.dta ../input/BR_MUNICIPIO_eduwages_Census2010.dta:
	if [ -e ../../compute_municipio_wages/output/$(@F) ] ; then ln -s ../../compute_municipio_wages/output/$(@F) ../input/ ; else exit 1; fi
../input/municipios_2010.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi
../input/msapop_2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi
../input/msa_%_2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_edupop_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi

../output/hce_pop_wage_Census2010_upperpanel.tex ../output/hce_pop_wage_Census2010_lowerpanel.tex: $(input) calls_hce_pop.do programs.do run_hce_pop.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run_hce_pop.sbatch ; else stata-se -e calls_hce_pop.do ; fi
../output/hce_pop_wage_Census2010.tex: hce_pop_cleantable.sh ../output/hce_pop_wage_Census2010_upperpanel.tex ../output/hce_pop_wage_Census2010_lowerpanel.tex
	bash hce_pop_cleantable.sh
../output/skillpremia3_Census2010_upperpanel.tex ../output/skillpremia3_Census2010_lowerpanel.tex: $(input) calls_skillpremia.do programs.do run_skillpremia.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run_skillpremia.sbatch ; else stata-se -e calls_skillpremia.do ; fi
../output/skillpremia3_Census2010.tex: skillpremia_cleantable.sh ../output/skillpremia3_Census2010_upperpanel.tex ../output/skillpremia3_Census2010_lowerpanel.tex
	bash skillpremia_cleantable.sh
