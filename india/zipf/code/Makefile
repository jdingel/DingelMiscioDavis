#Definitions
FOLDERS= slurmlogs ../input ../output

INPUT=\
	../input/India_subdistricts_2001.dta \
	../input/India_subdistricts_2011.dta \
	../input/MSAs_2001.dta \
	../input/district_pop.dta \
	../input/district_pop_allages.dta \
	../input/UAs.dta \
	../input/Towns_notbelongtoUAs.dta

OUTPUT_STATA=\
	../output/msa_compare_zipf_India_SDT_2001.tex \
	../output/msa_compare_zipf_India_SDT_2011.tex \
	../output/zipfplot_2001_SDT_msa30.pdf \
	../output/zipfplot_2011_SDT_msa30.pdf \
	../output/zipfplot_allMSAs.pdf \
	../output/zipfplot_2011_UAsandnonUAs.pdf

OUTPUT= $(OUTPUT_STATA) ../output/msa_compare_zipf_India_SDT_2001_2011.tex

#Recipes
all: $(FOLDERS) $(INPUT) $(OUTPUT)

$(FOLDERS):
	mkdir $@

../input/India_subdistricts_2001.dta ../input/India_subdistricts_2011.dta:
	if [ -e ../../SDT_MSA_loaddata/output/$(@F) ] ; then ln -s ../../SDT_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/Towns_notbelongtoUAs.dta ../input/UAs.dta:
	if [ -e ../../urban_agglomerations/output/$(@F) ] ; then ln -s ../../urban_agglomerations/output/$(@F) ../input/ ; else exit 1; fi
../input/town_2001.dta ../input/MSAs_2001.dta ../input/district_pop.dta ../input/district_pop_allages.dta:
	if [ -e ../../town_MSA_loaddata/output/$(@F) ] ; then ln -s ../../town_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(OUTPUT_STATA): $(INPUT) calls.do programs.do run.sbatch | $(FOLDERS)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/msa_compare_zipf_India_SDT_2001_2011.tex: ../output/msa_compare_zipf_India_SDT_2001.tex ../output/msa_compare_zipf_India_SDT_2011.tex clean_zipftable.sh
	bash clean_zipftable.sh
