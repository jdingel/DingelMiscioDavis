# Definitions
folders=slurmlogs ../input ../output

shp_file_ext := shp shx dbf prj
input_shp_file_ext := shp shx dbf prj qpj
levels := 10 20 30 40 50 60
empty:=
space:= $(empty) $(empty)

input_shapefiles=\
	$(foreach raster,F152000.v4b F182010.v4d,../input/$(raster)_web.stable_lights.avg_vis.tif) \
	$(foreach ext,$(input_shp_file_ext),../input/townships_2000_epsg4326.$(ext)) \
	$(foreach ext,$(shp_file_ext),../input/townships_2010_epsg4326.$(ext)) \
	$(foreach ext,$(input_shp_file_ext),../input/China_2000_counties.$(ext)) \
	$(foreach ext,$(input_shp_file_ext),../input/China_2010_counties.$(ext))

input=\
	$(input_shapefiles) \
	../input/proj4string.txt

prepped_raster=$(foreach raster,F152000.v4b F182010.v4d,../output/$(raster)_web.stable_lights.avg_vis_China.tif)

contour_output=\
	$(foreach ext,$(shp_file_ext),$(foreach lvl,$(levels),../output/nightlight_contour_2000_$(lvl).$(ext))) \
	$(foreach ext,$(shp_file_ext),$(foreach lvl,$(levels),../output/nightlight_contour_2010_$(lvl).$(ext)))

sp_join_output=\
	$(foreach ext,csv $(shp_file_ext), $(foreach lvl,$(levels),../output/mapping_counties_2000_NTL$(lvl).$(ext))) \
	$(foreach ext,csv $(shp_file_ext), $(foreach lvl,$(levels),../output/mapping_counties_2010_NTL$(lvl).$(ext))) \
	$(foreach ext,csv $(shp_file_ext), $(foreach lvl,$(levels),../output/mapping_townships_2000_NTL$(lvl).$(ext))) \
	$(foreach ext,csv $(shp_file_ext), $(foreach lvl,$(levels),../output/mapping_townships_2010_NTL$(lvl).$(ext)))

final_output=\
	$(foreach geo,townships counties,$(foreach year,2000 2010,../output/allNTL_$(geo)_$(year).csv)) \
	$(foreach geo,townships counties,$(foreach year,2000 2010,$(foreach lvl,$(levels),../output/$(geo)_$(year)_NTL$(lvl).csv))) \
	../output/radar_map_townships_2000_30_uncropped.png \
	../output/nightlight_raster_township_2000_map_uncropped.png \
	../output/assignment_map_townships_2000_metros_NTL30_uncropped.png

cropped_output=\
	../output/nightlight_raster_township_2000_map.png \
	../output/radar_map_townships_2000_30.png \
	../output/assignment_map_townships_2000_metros_NTL30.png \
	../output/nightlight_raster_township_2000_map_hidef.png \
	../output/radar_map_townships_2000_30_hidef.png \
	../output/assignment_map_townships_2000_metros_NTL30_hidef.png

# Recipes
all: $(folders) $(input) $(prepped_raster) $(contour_output) $(sp_join_output) $(final_output) $(cropped_output)
prepped_raster: $(prepped_raster)
contour_output: $(contour_output)
sp_join_output: $(sp_join_output)
final_output: $(final_output)


$(folders):
	mkdir $@

$(input_shapefiles): | $(folders)
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/proj4string.txt: ../input
	wget "https://spatialreference.org/ref/sr-org/china-albers-equal-area-conic/proj4/" -O ../input/proj4string.txt
	[[ -s ../input/proj4string.txt ]] || echo "+proj=aea +lat_1=27 +lat_2=45 +lat_0=35 +lon_0=105 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=mm +no_defs" > ../input/proj4string.txt

$(prepped_raster): $(input) prep_raster.R run_prep.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run_prep.sbatch; else Rscript prep_raster.R "$(shell cat ../input/proj4string.txt | sed 's/mm/m/' | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)"; fi

$(contour_output) : ../output/nightlight_contour_% : $(prepped_raster) contour_lines.R functions_contour_lines.R run_contour.sbatch
	$(eval year := $(word 1,$(subst _,$(space),$*)))
	$(eval bright := $(basename $(word 2, $(subst _,$(space),$*))))
	if command -v sbatch > /dev/null ; then sbatch -W --export=year=$(year) \
	run_contour.sbatch; else Rscript contour_lines.R "$(shell cat ../input/proj4string.txt | sed 's/mm/m/' | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" $(year) $(bright); fi

$(sp_join_output) : ../output/mapping_% : $(contour_output) sp_join.R functions_sp_join.R run_spjoin.sbatch
	$(eval geo := "$(word 1,$(subst _,$(space),$*))")
	$(eval year := $(word 2,$(subst _,$(space),$*)))
	$(eval bright := $(subst NTL,$(empty),$(basename $(word 3,$(subst _,$(space),$*)))))
	if command -v sbatch > /dev/null ; then sbatch -W --export=geo=$(geo),year=$(year) \
	run_spjoin.sbatch; else Rscript sp_join.R "$(shell cat ../input/proj4string.txt | sed 's/mm/m/')" $(geo) $(year) $(bright); fi

$(final_output): $(sp_join_output) build_output.R functions_build_output.R run_output.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run_output.sbatch; else Rscript build_output.R "$(shell cat ../input/proj4string.txt | sed 's/mm/m/')"; fi

$(cropped_output): ../output/radar_map_townships_2000_30_uncropped.png ../output/nightlight_raster_township_2000_map_uncropped.png ../output/assignment_map_townships_2000_metros_NTL30_uncropped.png crop.sh
	bash crop.sh
