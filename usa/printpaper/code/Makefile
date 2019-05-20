# Definitions
folders=../input ../output
input=../input/US_correlations.pdf
output=../output/paper_usa.pdf

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/US_correlations.pdf:
	if [ -e ../../CBSA_comparison/output/$(@F) ] ; then ln -s ../../CBSA_comparison/output/$(@F) ../input/ ; else exit 1; fi

../output/paper_usa.pdf: buildpaper.sh paper_usa.tex $(input)
	bash buildpaper.sh
