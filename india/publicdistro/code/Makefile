#Definitions
folders=slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj

input=\
	../input/India_subdistricts_2001.dta \
	../input/India_subdistricts_2011.dta \
	$(foreach ext,$(shp_file_ext),../input/sub_districts.$(ext))

output=\
	../output/subdistricts_2001.csv \
	../output/subdistricts_2011.csv

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/India_subdistricts_20%1.dta:
	if [ -e ../../SDT_MSA_loaddata/output/$(@F) ] ; then ln -s ../../SDT_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi
$(foreach ext,$(shp_file_ext),../input/sub_districts.$(ext)):
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) clean.do run.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e clean.do; fi
