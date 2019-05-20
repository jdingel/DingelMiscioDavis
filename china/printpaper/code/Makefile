# Definitions

folders=\
	../input \
	../output \

input=\
	../input/nightlight_raster_township_2000_map.png \
	../input/radar_map_townships_2000_30.png \
	../input/assignment_map_townships_2000_metros_NTL30.png \
	../input/msa_prefecture_baseline_correlation_plot.pdf \
	../input/msa_compare_China_townships_counties_2000.tex \
	../input/2000_townships_msa30_night_100k.pdf \
	../input/2010_townships_msa30_night_100k.pdf \
	../input/msa_compare_zipf_China_townships_2000_2010.tex \
	../input/edu_shares_msa30_night.tex \
	../input/popelast_eduagg_2000_100k_townships_counties.tex \
	../input/distance_gradient_college_2000.tex \
	../input/china_townships_area_2000_details.tex \
	../input/china_counties_area_2000_details.tex \
	../input/pairwise_edu_2000_4group.tex


output=../output/paper_china.pdf

# Recipes

all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/nightlight_raster_township_2000_map.png ../input/radar_map_townships_2000_30.png ../input/assignment_map_townships_2000_metros_NTL30.png:
	if [ -e ../../nightlights/output/$(@F) ] ; then ln -s ../../nightlights/output/$(@F) ../input/ ; else exit 1; fi
../input/msa_compare_China_townships_counties_2000.tex ../input/msa_prefecture_baseline_correlation_plot.pdf:
	if [ -e ../../msa_comparisons/output/$(@F) ] ; then ln -s ../../msa_comparisons/output/$(@F) ../input/ ; else exit 1; fi
../input/msa_compare_zipf_China_townships_2000_2010.tex ../input/2000_townships_msa30_night_100k.pdf ../input/2010_townships_msa30_night_100k.pdf:
	if [ -e ../../zipf/output/$(@F) ] ; then ln -s ../../zipf/output/$(@F) ../input/ ; else exit 1; fi
../input/edu_shares_msa30_night.tex:
	if [ -e ../../edushares/output/$(@F) ] ; then ln -s ../../edushares/output/$(@F) ../input/ ; else exit 1; fi
../input/popelast_eduagg_2000_100k_townships_counties.tex:
	if [ -e ../../populationelasticities/output/$(@F) ] ; then ln -s ../../populationelasticities/output/$(@F) ../input/ ; else exit 1; fi
../input/distance_gradient_college_2000.tex 	../input/distance_gradient_college_townships_2000_msa30_night.pdf:
	if [ -e ../../distance_gradients/output/$(@F) ] ; then ln -s ../../distance_gradients/output/$(@F) ../input/ ; else exit 1; fi
../input/china_townships_area_2000_details.tex ../input/china_counties_area_2000_details.tex:
	if [ -e ../../summstats/output/$(@F) ] ; then ln -s ../../summstats/output/$(@F) ../input/ ; else exit 1; fi
../input/pairwise_edu_2000_4group.tex:
	if [ -e ../../pairwise_comparisons/output/$(@F) ] ; then ln -s ../../pairwise_comparisons/output/$(@F) ../input/ ; else exit 1; fi

../output/paper_china.pdf: buildpaper.sh paper_china.tex $(input)
	bash buildpaper.sh
