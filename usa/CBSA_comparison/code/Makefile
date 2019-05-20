# Definitions
FOLDERS= slurmlogs ../input ../output
INPUT=../input/counties_2010.dta
OUTPUT=../output/US_correlations.pdf

# Recipes
all: $(FOLDERS) $(INPUT) $(OUTPUT)

$(FOLDERS):
	mkdir $@

../input/counties_2010.dta:
	if [ -e ../../county_to_MSA/output/$(@F) ] ; then ln -s ../../county_to_MSA/output/$(@F) ../input/ ; else exit 1; fi

$(OUTPUT): $(INPUT) CBSA_comparison.do programs.do
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e CBSA_comparison.do; fi
