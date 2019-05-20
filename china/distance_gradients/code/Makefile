# Definitions
folders=slurmlogs ../input ../output

input=\
	$(foreach geo,townships counties,../input/$(geo)_2000.dta) \
	$(foreach geo,townships counties,../input/pop_by_educ_$(geo)_2000.dta)

levels = 10 20 30 40 50 60

output=\
	$(foreach geo,townships counties,../output/distance_gradient_college_$(geo)_2000_msa_night.tex) \
	$(foreach lvl,$(levels),$(foreach geo,townships counties,../output/distance_gradient_college_$(geo)_2000_msa$(lvl)_night.dta)) \
	$(foreach lvl,$(levels),../output/college_distance_gradient_ntl$(lvl)_townships_counties_tstat.txt)

# Recipes
all: $(folders) $(input) $(output) ../output/distance_gradient_college_2000_nostats.tex ../output/distance_gradient_college_2000.tex

$(folders):
	mkdir $@

../input/counties_2000.dta ../input/pop_by_educ_counties_2000.dta:
	if [ -e ../../counties_loaddata/output/$(@F) ] ; then ln -s ../../counties_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/townships_2000.dta ../input/pop_by_educ_townships_2000.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/distance_gradient_college_2000_nostats.tex: cleantable.sh ../output/distance_gradient_college_townships_2000_msa_night.tex ../output/distance_gradient_college_counties_2000_msa_night.tex ../output/college_distance_gradient_ntl60_townships_counties_tstat.txt
	bash cleantable.sh
../output/distance_gradient_college_2000.tex: ../output/distance_gradient_college_2000_nostats.tex append_stats.sh
	bash append_stats.sh
