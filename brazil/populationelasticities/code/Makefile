#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/municipios_2010.dta \
	../input/msa_microrregiopop_2010.dta \
	../input/msa_arranjopop_2010.dta \
	$(foreach lvl,10 20 30 40 50,../input/msa_night_$(lvl)pop_2010.dta) \
	$(foreach lvl,5 10 15 20 25,../input/msa_duranton_$(lvl)pop_2010.dta) \
	../input/BR_MUNICIPIO_edupop_Census2010.dta \
	../input/BR_MUNICIPIO_agepop_edupop_Census2010.dta \
	../input/BR_MUNICIPIO_indpop_Census2010.dta \
	../input/BR_MUNICIPIO_occpop_Census2010.dta \
	../input/occ_shares_Census2010.dta \
	../input/ind_shares_Census2010.dta \
	../input/BR_AvgSch_ind_Census2010.dta \
	../input/BR_AvgSch_occ_Census2010.dta

output=\
	../output/edupop_elasticities_Census2010_msa_compare.tex \
	$(foreach class,night duranton,../output/agepop_edupop_elasticities_Census2010_msa_$(class).tex) \
	$(foreach sec,ind occ,../output/$(sec)pop_elasticities_Census2010_duranton10.pdf) \
	$(foreach sec,ind occ,../output/$(sec)pop_elasticities_Census2010_zoom_duranton10.pdf)

OUTPUT_RENAMED=\
	../output/occpop_elasticities_Census2010_zoom.pdf \
	../output/occpop_elasticities_Census2010.pdf \
	../output/indpop_elasticities_Census2010_zoom.pdf \
	../output/indpop_elasticities_Census2010.pdf

OUTPUT_CLEAN=\
	../output/edupop_elasticities_Census2010_msa_compare_clean.tex \
	../output/agepop_edupop_elasticities_Census2010_duranton_clean.tex \
	../output/agepop_edupop_elasticities_Census2010_night_clean.tex

#Recipes
all: $(folders) $(input) $(output) $(OUTPUT_RENAMED) $(OUTPUT_CLEAN)

$(folders):
	mkdir $@

../input/municipios_2010.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi
../input/msa_%_2010.dta:
	if [ -e ../../MSA_traits/output/$(@F) ] ; then ln -s ../../MSA_traits/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_MUNICIPIO_%_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi
../input/BR_AvgSch_ind_Census2010.dta ../input/BR_AvgSch_occ_Census2010.dta:
	if [ -e ../../census_microdata/output/$(@F) ] ; then ln -s ../../census_microdata/output/$(@F) ../input/ ; else exit 1; fi
../input/occ_shares_Census2010.dta ../input/ind_shares_Census2010.dta:
	if [ -e ../../shares/output/$(@F) ] ; then ln -s ../../shares/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) programs.do calls.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

$(OUTPUT_CLEAN): $(output) clean_edupop.sh
	bash clean_edupop.sh

../output/occpop_elasticities_Census2010_zoom.pdf: ../output/occpop_elasticities_Census2010_zoom_duranton10.pdf
	ln -s -f $< $@
../output/occpop_elasticities_Census2010.pdf: ../output/occpop_elasticities_Census2010_duranton10.pdf
	ln -s -f $< $@
../output/indpop_elasticities_Census2010_zoom.pdf: ../output/indpop_elasticities_Census2010_zoom_duranton10.pdf
	ln -s -f $< $@
../output/indpop_elasticities_Census2010.pdf: ../output/indpop_elasticities_Census2010_duranton10.pdf
	ln -s -f $< $@
