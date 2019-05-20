# Definitions
folders=slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj
input_shp_file_ext := shp shx dbf prj qpj
levels := 10 20 30 40 50 60

input=\
	../input/F182010.v4d_web.stable_lights.avg_vis.tif \
	$(foreach ext,$(shp_file_ext),../input/municipios_2010.$(ext)) \
	../input/proj4string.txt

prepped_raster=../output/F182010.v4d_web.stable_lights.avg_vis_Brazil.tif
contour_output=$(foreach ext,$(shp_file_ext),$(foreach lvl,$(levels),../output/nightlight_contour_2010_$(lvl).$(ext)))
sp_join_output=$(foreach ext,csv $(shp_file_ext), $(foreach lvl,$(levels),../output/mapping_municipios_2010_NTL$(lvl).$(ext)))
final_output=../output/allNTL_municipios_2010.csv $(foreach lvl,$(levels),../output/municipios_2010_NTL$(lvl).csv)

# Recipes
all: $(folders) $(input) $(prepped_raster) $(contour_output) $(sp_join_output) $(final_output)

$(folders):
	mkdir $@

../input/proj4string.txt: | ../input
	wget "https://spatialreference.org/ref/sr-org/7823/proj4/" -O ../input/proj4string.txt
	[[ -s ../input/proj4string.txt ]] || echo "+proj=aea +lat_1=-2 +lat_2=-22 +lat_0=-12 +lon_0=-54 +x_0=5000000 +y_0=10000000 +ellps=WGS84 +datum=WGS84 +units=m +no_defs" > ../input/proj4string.txt
../input/municipios_2010.%: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/$(@F) ; else exit 1; fi
../input/F182010%.tif: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) $@ ; else exit 1; fi

$(prepped_raster): $(input) prep_raster.R run_prep.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run_prep.sbatch; else Rscript prep_raster.R "$(shell cat ../input/proj4string.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)"; fi

$(contour_output) : ../output/nightlight_contour_2010_% : $(prepped_raster) contour_lines.R functions_contour_lines.R run_contour.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W \
	run_contour.sbatch; else Rscript contour_lines.R "$(shell cat ../input/proj4string.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" $(basename $*); fi

$(sp_join_output) : ../output/mapping_municipios_2010_NTL% : $(contour_output) sp_join.R functions_sp_join.R run_spjoin.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W \
	run_spjoin.sbatch; else Rscript sp_join.R "$(shell cat ../input/proj4string.txt)" $(basename $*); fi

$(final_output): $(sp_join_output) build_output.R functions_build_output.R run_output.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run_output.sbatch; else Rscript build_output.R ; fi
