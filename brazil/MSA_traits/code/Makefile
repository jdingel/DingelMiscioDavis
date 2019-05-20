#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/municipios_2010.dta \
	../input/msa_municipio_2010_map.dta \
	../input/geo_crosswalk_10.dta \
	../input/BR_MUNICIPIO_edupop_Census2010.dta \
	../input/BR_MUNICIPIO_POP.dta

levels:= 10 20 30 40 50
commute:= 5 10 15 20 25

output=\
	$(foreach lvl,$(levels),../output/msa_night_$(lvl)pop_2010.dta) \
	$(foreach lvl,$(commute),../output/msa_duranton_$(lvl)pop_2010.dta) \
	../output/msa_microrregiopop_2010.dta \
	../output/BR_MSA_edupop_Census2010.dta \
	../output/msapop_2010.dta \
	../output/msa_arranjopop_2010.dta

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/geo_crosswalk_10.dta ../input/msa_municipio_2010_map.dta ../input/municipios_2010.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_POP.dta:
	if [ -e ../../municipios_loaddata/output/$(@F) ] ; then ln -s ../../municipios_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_edupop_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
