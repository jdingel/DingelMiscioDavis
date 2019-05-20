#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/CENSO10_pes.dta \
	../input/tab3_1.xls \
	../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta \
	../input/BR_MUNICIPIO_POP.dta \
	../input/MCARPs_Chauvin2017.dta \
	../input/brazil_municipios_area.csv \
	$(foreach lvl,10 20 30 40 50 60,../input/municipios_2010_NTL$(lvl).csv)

output_commuting=\
	../output/geo_crosswalk_5.dta \
	../output/geo_crosswalk_10.dta \
	../output/geo_crosswalk_15.dta \
	../output/geo_crosswalk_20.dta \
	../output/geo_crosswalk_25.dta \
	../output/msa_municipio_2010_map.dta \

output_assignments=\
	../output/municipios_2010.dta \
	../output/municipios_2010_withcoordinates.dta

#Recipes
all: $(folders) $(output_commuting) $(output_assignments)

$(folders):
	mkdir $@

../input/CENSO10_pes.dta ../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta ../input/tab3_1.xls ../input/MCARPs_Chauvin2017.dta:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/municipios_2010_NTL%.csv:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) $@ ; else exit 1; fi
../input/brazil_municipios_area.csv:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) $@ ; else exit 1; fi
../input/BR_MUNICIPIO_POP.dta:
	if [ -e ../../municipios_loaddata/output/$(@F) ] ; then ln -s ../../municipios_loaddata/output/$(@F) ../input/ ; else exit 1; fi

../output/CENSO10_commuting.dta: calls_commuting_prep.do programs.do ../input/CENSO10_pes.dta run.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W --export=command1='module load stata',command2='stata-se -e calls_commuting_prep.do' --job-name=municipio_to_MSA_prep run.sbatch; else stata-se -e calls_commuting_prep.do ; fi
$(output_commuting): ../input/Unidades_da_Federacao_Mesorregioes_microrregioes_e_municipios_2010.dta calls_commuting.do programs.do ../output/CENSO10_commuting.dta run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W --export=command1='module load stata',command2='stata-se -e calls_commuting.do' --job-name=municipio_to_MSA_commuting run.sbatch; else stata-se -e calls_commuting.do ; fi
$(output_assignments): $(input) $(output_commuting) calls_join.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W --export=command1='module load stata',command2='stata-se -e calls_join.do' --job-name=municipio_to_MSA_join run.sbatch; else stata-se -e calls_join.do ; fi
