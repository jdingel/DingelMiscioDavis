# Definitions
folders=slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj
input_shp_file_ext := shp shx dbf prj qpj
levels:= 10 20 30 40 50 60
empty:=
space:= $(empty) $(empty)

input=\
	$(foreach raster,F152001.v4b F182011.v4c,../input/$(raster)_web.stable_lights.avg_vis.tif) \
	$(foreach ext,$(shp_file_ext),../input/sub_districts.$(ext)) \
	../input/proj4string.txt

prepped_raster=$(foreach raster,F152001.v4b F182011.v4c,../output/$(raster)_web.stable_lights.avg_vis_India.tif)

contour_output=\
	$(foreach ext,$(shp_file_ext),$(foreach lvl,$(levels),../output/nightlight_contour_2001_$(lvl).$(ext))) \
	$(foreach ext,$(shp_file_ext),$(foreach lvl,$(levels),../output/nightlight_contour_2011_$(lvl).$(ext))) \

sp_join_output=\
$(foreach ext,csv $(shp_file_ext),$(foreach lvl,$(levels),../output/mapping_sub_districts_2001_NTL$(lvl).$(ext))) \
$(foreach ext,csv $(shp_file_ext),$(foreach lvl,$(levels),../output/mapping_sub_districts_2011_NTL$(lvl).$(ext)))

final_output=\
	$(foreach year,2001 2011,../output/allNTL_sub_districts_$(year).csv) \
	$(foreach year,2001 2011,$(foreach lvl,$(levels),../output/sub_districts_$(year)_NTL$(lvl).csv))

# Recipes
all: $(folders) $(input) $(prepped_raster) $(contour_output) $(sp_join_output) $(final_output)

$(folders):
	mkdir $@

../input/proj4string.txt: | ../input
	wget "https://spatialreference.org/ref/sr-org/albers-india/proj4/" -O ../input/proj4string.txt
	[[ -s ../input/proj4string.txt ]] || echo "+proj=aea +lat_1=28 +lat_2=12 +lat_0=20 +lon_0=78 +x_0=2000000 +y_0=2000000 +ellps=WGS84 +datum=WGS84 +units=m +no_defs" > ../input/proj4string.txt
../input/sub_districts%: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/$(@F) ; else exit 1; fi
../input/F1%.tif: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/$(@F) ; else exit 1; fi

$(prepped_raster): $(input) prep_raster.R run_prep.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run_prep.sbatch; else Rscript prep_raster.R "$(shell cat ../input/proj4string.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)"; fi

$(contour_output) : ../output/nightlight_contour_% : $(prepped_raster) contour_lines.R functions_contour_lines.R run_contour.sbatch
	$(eval year := $(word 1, $(subst _,$(space),$*)))
	$(eval bright := $(word 2, $(subst _,$(space),$(basename $*))))
	if command -v sbatch > /dev/null ; then sbatch -W --export=year=$(year) \
	run_contour.sbatch; else Rscript contour_lines.R "$(shell cat ../input/proj4string.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" $(year) $(bright); fi

$(sp_join_output) : ../output/mapping_sub_districts_% : $(contour_output) sp_join.R functions_sp_join.R run_spjoin.sbatch
	$(eval year := $(word 1, $(subst _,$(space),$*)))
	$(eval bright := $(subst NTL,$(empty),$(basename $(word 2, $(subst _,$(space),$*)))))
	if command -v sbatch > /dev/null ; then sbatch -W --export=year=$(year) \
	run_spjoin.sbatch; else Rscript sp_join.R "$(shell cat ../input/proj4string.txt)" $(year) $(bright); fi

$(final_output): $(sp_join_output) build_output.R functions_build_output.R run_output.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run_output.sbatch; else Rscript build_output.R ; fi
