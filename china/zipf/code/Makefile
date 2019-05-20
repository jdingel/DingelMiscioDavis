# Definitions

folders=slurmlogs ../input ../output

input=\
	../input/townships_2000.dta \
	../input/townships_2010.dta

output=\
	../output/msa_compare_zipf_China_townships_2000.tex \
	../output/msa_compare_zipf_China_townships_2010.tex \
	../output/2000_townships_msa30_night_100k.pdf \
	../output/2010_townships_msa30_night_100k.pdf

# Recipes

all: $(folders) $(input) $(output) ../output/msa_compare_zipf_China_townships_2000_2010.tex

$(folders):
	mkdir $@

../input/townships_2000.dta ../input/townships_2010.dta:
	if [ -e ../../townships_loaddata/output/$(@F) ] ; then ln -s ../../townships_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/msa_compare_zipf_China_townships_2000_2010.tex: clean_zipftable.sh ../output/msa_compare_zipf_China_townships_2000.tex ../output/msa_compare_zipf_China_townships_2010.tex
	bash clean_zipftable.sh
