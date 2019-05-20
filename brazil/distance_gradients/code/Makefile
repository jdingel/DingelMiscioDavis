# Definitions
folders=slurmlogs ../input ../output

levels:= 10 20 30 40 50
commute:= 5 15 25

input=\
	../input/BR_MUNICIPIO_edupop_Census2010.dta \
	../input/municipios_2010_withcoordinates.dta \
	$(foreach lvl,$(levels),../input/msa_night_$(lvl)pop_2010.dta) \
	$(foreach lvl,$(commute),../input/msa_duranton_$(lvl)pop_2010.dta) \
	../input/msa_arranjopop_2010.dta \
	../input/msa_microrregiopop_2010.dta

output=\
	../output/distance_gradient_college_upperpanel.tex \
	../output/distance_gradient_college_lowerpanel.tex \
	$(foreach class,$(foreach ntl,$(levels),night_$(ntl)) $(foreach d,$(commute),duranton_$(d)) arranjo microrregio,../output/distance_gradient_college_msa_$(class).dta) \
	../output/distance_gradient_college_msa_night_30.pdf \
	../output/distance_gradient_college_microregion_alt.tex \
	$(foreach lvl,$(levels),../output/college_distance_gradient_ntl$(lvl)_microregions_chow.txt) \
	$(foreach lvl,$(levels),../output/college_distance_gradient_ntl$(lvl)_arranjos_chow.txt)
#Recipes
all: $(folders) $(input) $(output) ../output/distance_gradient_college_nostats.tex ../output/distance_gradient_college.tex

$(folders):
	mkdir $@

../input/municipios_2010_withcoordinates.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_edupop_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi
../input/msa_%pop_2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/distance_gradient_college_nostats.tex: cleantable.sh ../output/distance_gradient_college_upperpanel.tex ../output/distance_gradient_college_lowerpanel.tex ../output/college_distance_gradient_ntl50_arranjos_chow.txt
	bash cleantable.sh
../output/distance_gradient_college.tex: append_stats.sh ../output/distance_gradient_college_nostats.tex
	bash append_stats.sh
