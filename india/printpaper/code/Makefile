# Definitions

folders=\
	../input \
	../output \

input=\
	../input/msa_compare_zipf_India_SDT_2001_2011.tex \
	../input/zipfplot_allMSAs.pdf \
	../input/zipfplot_2011_UAsandnonUAs.pdf \
	../input/edu_shares_UA.tex \
	../input/edu_popelasticity_B9_4scheme_2001_clean.tex \
	../input/india_sub_districts_area_details.tex \
	../input/pairwise_edu_4group_0.tex


output=../output/paper_india.pdf

# Recipes

all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/msa_compare_zipf_India_SDT_2001_2011.tex 	../input/zipfplot_allMSAs.pdf ../input/zipfplot_2011_UAsandnonUAs.pdf:
	if [ -e ../../zipf/output/$(@F) ] ; then ln -s ../../zipf/output/$(@F) ../input/ ; else exit 1; fi
../input/edu_shares_UA.tex:
	if [ -e ../../edushares/output/$(@F) ] ; then ln -s ../../edushares/output/$(@F) ../input/ ; else exit 1; fi
../input/edu_popelasticity_B9_4scheme_2001_clean.tex:
	if [ -e ../../populationelasticities/output/$(@F) ] ; then ln -s ../../populationelasticities/output/$(@F) ../input/ ; else exit 1; fi
../input/india_sub_districts_area_details.tex:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) ../input/ ; else exit 1; fi
../input/pairwise_edu_4group_0.tex:
	if [ -e ../../pairwise_comparisons/output/$(@F) ] ; then ln -s ../../pairwise_comparisons/output/$(@F) ../input/ ; else exit 1; fi

../output/paper_india.pdf: buildpaper.sh paper_india.tex $(input)
	bash buildpaper.sh
