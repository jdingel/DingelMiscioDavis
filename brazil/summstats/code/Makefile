#Definitions

FOLDERS= slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj
INPUTS=$(foreach ext,$(shp_file_ext),../input/municipios_2010.$(ext)) ../input/proj4string.txt
OUTPUTS=$(addprefix ../output/brazil_municipios_area.,csv tex) ../output/brazil_municipios_area_details.tex

#Recipes

all: $(FOLDERS) $(INPUTS) $(OUTPUTS)

$(FOLDERS):
	mkdir $@

../input/proj4string.txt:
	if [ -e ../../nightlights/input/$(@F) ] ; then ln -s ../../nightlights/input/$(@F) ../input/ ; else exit 1; fi
../input/municipios_2010.%:  | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(OUTPUTS): $(INPUTS) functions.R calls.R run.sbatch | $(FOLDERS)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else Rscript calls.R "$(shell cat ../input/proj4string.txt)"; fi
