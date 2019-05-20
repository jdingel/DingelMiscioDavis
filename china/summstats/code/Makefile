#Definitions

FOLDERS= slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj
input_shp_file_ext := shp shx dbf prj qpj

R_INPUTS=\
	../input/proj4string.txt \
	$(foreach ext,$(shp_file_ext),../input/townships_2010_epsg4326.$(ext)) \
	$(foreach ext,$(input_shp_file_ext),../input/townships_2000_epsg4326.$(ext)) \
	$(foreach ext,$(input_shp_file_ext),../input/China_2000_counties.$(ext)) \
	$(foreach ext,$(input_shp_file_ext),../input/China_2010_counties.$(ext))

R_OUTPUTS=\
	$(addprefix ../output/china_townships_area_2000,.csv .tex _details.tex) \
	$(addprefix ../output/china_townships_area_2010,.csv .tex _details.tex) \
	$(addprefix ../output/china_counties_area_2000,.csv .tex _details.tex) \
	$(addprefix ../output/china_counties_area_2010,.csv .tex _details.tex)

#Recipes

all: $(FOLDERS) $(R_INPUTS) $(R_OUTPUTS)

$(FOLDERS):
	mkdir $@

../input/proj4string.txt:
	if [ -e ../../nightlights/input/$(@F) ] ; then ln -s ../../nightlights/input/$(@F) ../input/ ; else exit 1; fi
../input/townships_2010_epsg4326.%: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/townships_2000_epsg4326.%:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/China_2000_counties.%:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/China_2010_counties.%: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(R_OUTPUTS): $(R_INPUTS) functions.R calls.R run.sbatch | ../output
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else Rscript calls.R "$(shell cat ../input/proj4string.txt | sed 's/mm/m/')"; fi
