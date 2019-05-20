# Defintions

folders=slurmlogs ../input ../output

input=\
	../input/msa_duranton_10_baseline_correlation_plot.pdf \
	../input/edu_shares_Census_All_and_Metro.tex \
	../input/edupop_elasticities_Census2010_msa_compare_clean.tex \
	../input/popelast_edu_lpoly.pdf \
	../input/distance_gradient_college.tex \
	../input/distance_gradient_college_msa_night_30.pdf \
	../input/hce_pop_wage_Census2010.tex \
	../input/skillpremia3_Census2010.tex \
	../input/indpop_elasticities_Census2010.pdf \
	../input/indpop_elasticities_Census2010_zoom.pdf \
	../input/occpop_elasticities_Census2010.pdf \
	../input/occpop_elasticities_Census2010_zoom.pdf \
	../input/brazil_municipios_area_details.tex \
	../input/pairwise_edu.tex

output=../output/paper_brazil.pdf

# Recipes

all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/msa_duranton_10_baseline_correlation_plot.pdf:
	if [ -e ../../MSA_comparisons/output/$(@F) ] ; then ln -s ../../MSA_comparisons/output/$(@F) $@ ; else exit 1; fi
../input/edu_shares_Census_All_and_Metro.tex:
	if [ -e ../../shares/output/$(@F) ] ; then ln -s ../../shares/output/$(@F) $@ ; else exit 1; fi
../input/popelast_edu_lpoly.pdf:
	if [ -e ../../popelast_plot/output/$(@F) ] ; then ln -s ../../popelast_plot/output/$(@F) $@ ; else exit 1; fi
../input/edupop_elasticities_Census2010_msa_compare_clean.tex ../input/indpop_elasticities_Census2010.pdf ../input/indpop_elasticities_Census2010_zoom.pdf ../input/occpop_elasticities_Census2010.pdf ../input/occpop_elasticities_Census2010_zoom.pdf:
	if [ -e ../../populationelasticities/output/$(@F) ] ; then ln -s ../../populationelasticities/output/$(@F) $@ ; else exit 1; fi
../input/distance_gradient_college.tex ../input/distance_gradient_college_msa_night_30.pdf:
	if [ -e ../../distance_gradients/output/$(@F) ] ; then ln -s ../../distance_gradients/output/$(@F) $@ ; else exit 1; fi
../input/skillpremia3_Census2010.tex ../input/hce_pop_wage_Census2010.tex:
	if [ -e ../../regress_MSA_wagesbysize/output/$(@F) ] ; then ln -s ../../regress_MSA_wagesbysize/output/$(@F) $@ ; else exit 1; fi
../input/pairwise_edu.tex:
	if [ -e ../../pairwise_comparisons/output/$(@F) ] ; then ln -s ../../pairwise_comparisons/output/$(@F) $@ ; else exit 1; fi
../input/brazil_municipios_area_details.tex:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) $@ ; else exit 1; fi

../output/paper_brazil.pdf: buildpaper.sh paper_brazil.tex $(input)
	bash buildpaper.sh
