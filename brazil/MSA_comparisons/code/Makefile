#Definitions
folders=slurmlogs ../input ../output

input=../input/municipios_2010.dta

output=\
	../output/msa_microrregio_comparison.dta \
	../output/msa_duranton_10_comparison.dta \
	../output/msa_duranton_10_baseline_correlation_plot.pdf \
	../output/crosswalk_msa_2010.dta \
	../output/msa_compare_Brazil_municipios_2010.tex

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/municipios_2010.dta:
	if [ -e ../../municipio_to_MSA/output/$(@F) ] ; then ln -s ../../municipio_to_MSA/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
