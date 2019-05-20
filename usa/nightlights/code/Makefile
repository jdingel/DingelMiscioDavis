# Definitions
folders=slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj
levels := $(shell seq 30 2 62)
empty:=
space:= $(empty) $(empty)

input_shapefiles=$(foreach ext,$(shp_file_ext),$(foreach area,continental_US alaska hawaii,../input/tl_2010_us_county10_$(area).$(ext)))

raster=../input/F182010.v4d_web.stable_lights.avg_vis.tif

input=\
	$(input_shapefiles) \
	$(raster) \
	../input/proj4string_continental.txt \
	../input/proj4string_alaska.txt \
	../input/proj4string_hawaii.txt

prepped_raster=$(foreach area,continental alaska hawaii,../output/F182010.v4d_web.stable_lights.avg_vis_$(area).tif) \

contour_output=$(foreach ext,$(shp_file_ext),$(foreach area,continental alaska hawaii,$(foreach lvl,$(levels),../output/nightlight_contour_2010_$(area)_$(lvl).$(ext))))

sp_join_output=$(foreach ext,$(shp_file_ext) csv,$(foreach area,continental alaska hawaii,$(foreach lvl,$(levels),../output/mapping_counties_2010_$(area)_NTL$(lvl).$(ext))))

final_output=\
	../output/US_county_2010_nightlights.csv \
	$(foreach lvl,$(levels),../output/US_counties_2010_NTL$(lvl).csv)

# Recipes
all: $(folders) $(input) $(prepped_raster) $(contour_output) $(sp_join_output) $(final_output)
prepped_raster: $(prepped_raster)
contour_output: $(contour_output)
sp_join_output: $(sp_join_output)
final_output: $(final_output)

$(folders):
	mkdir $@

$(input_shapefiles): | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/$(@F) ; else exit 1; fi
$(raster): | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/$(@F) ; else exit 1; fi
../input/proj4string_continental.txt: | ../input
	wget "https://spatialreference.org/ref/esri/usa-contiguous-albers-equal-area-conic/proj4/" -O ../input/proj4string_continental.txt
	[[ -s ../input/proj4string_continental.txt ]] || echo "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" > ../input/proj4string_continental.txt
../input/proj4string_alaska.txt: | ../input
	wget "https://spatialreference.org/ref/esri/alaska-albers-equal-area-conic/proj4/" -O ../input/proj4string_alaska.txt
	[[ -s ../input/proj4string_alaska.txt ]] || echo "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" > ../input/proj4string_alaska.txt
../input/proj4string_hawaii.txt: | ../input
	wget "https://spatialreference.org/ref/esri/hawaii-albers-equal-area-conic/proj4/" -O ../input/proj4string_hawaii.txt
	[[ -s ../input/proj4string_hawaii.txt ]] || echo "+proj=aea +lat_1=8 +lat_2=18 +lat_0=13 +lon_0=-157 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" > ../input/proj4string_hawaii.txt

$(prepped_raster): $(input) prep_raster.R run_prep.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run_prep.sbatch; else Rscript prep_raster.R \
	"$(shell cat ../input/proj4string_continental.txt | sed 's/aea/eqdc/' | cut -d " " -f 1-3,5-)" \
	"$(shell cat ../input/proj4string_alaska.txt | sed 's/aea/aeqd/' | sed 's/+lat\_0=50/+lat\_ts=60/' | cut -d " " -f 1,4-)" \
	"$(shell cat ../input/proj4string_hawaii.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" ; fi

$(contour_output) : ../output/nightlight_contour_2010_% : $(prepped_raster) contour_lines.R functions_contour_lines.R run_contour.sbatch
	$(eval bright := $(basename $(word 2, $(subst _,$(space),$*))))
	if command -v sbatch > /dev/null ; then sbatch -W \
	run_contour.sbatch; else Rscript contour_lines.R \
	"$(shell cat ../input/proj4string_continental.txt | sed 's/aea/eqdc/' | cut -d " " -f 1-3,5-)" \
	"$(shell cat ../input/proj4string_alaska.txt | sed 's/aea/aeqd/' | sed 's/+lat\_0=50/+lat\_ts=60/' | cut -d " " -f 1,4-)" \
	"$(shell cat ../input/proj4string_hawaii.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" $(bright) ; fi

$(sp_join_output) : ../output/mapping_counties_2010_% : $(contour_output) sp_join.R functions_sp_join.R run_spjoin.sbatch
	$(eval bright := $(subst NTL,$(empty),$(basename $(word 2, $(subst _,$(space),$*)))))
	if command -v sbatch > /dev/null ; then sbatch -W \
	run_spjoin.sbatch; else Rscript sp_join.R \
	"$(shell cat ../input/proj4string_continental.txt)" \
	"$(shell cat ../input/proj4string_alaska.txt | sed 's/+lat\_0=50/+lat\_0=60/')" \
	"$(shell cat ../input/proj4string_hawaii.txt)" $(bright); fi

$(final_output): $(sp_join_output) build_output.R functions_build_output.R run_output.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run_output.sbatch ; else Rscript build_output.R ; fi
