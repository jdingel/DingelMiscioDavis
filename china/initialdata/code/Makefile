# Definitions
folders=../output slurmlogs

shp_file_ext := shp shx dbf qpj prj
output_shp_file_ext := shp shx dbf prj

input=\
	../input/2010CountyCensusA.xlsx \
	../input/2010CountyCensusA.dta  \
	../input/2010CountyCensusL.xlsx \
	../input/all_china_townships_2000.dta \
	../input/allchina_township_class3.csv \
	../input/County2000.xls \
	../input/county_2000_shapefile.csv \
	../input/townships_2010_shapefile.csv \
	$(foreach ext,$(shp_file_ext),../input/China_2000_counties.$(ext)) \
	$(foreach ext,$(shp_file_ext),../input/China_2010_counties.$(ext)) \
	$(foreach ext,$(shp_file_ext),../input/townships_2000_epsg4326.$(ext)) \
	$(foreach ext,$(shp_file_ext),../input/all_China_townships_2010_epsg4326.$(ext))

shp_output=$(foreach ext,$(output_shp_file_ext),../output/townships_2010_epsg4326.$(ext))

output=\
	../output/2010CountyCensusA.xlsx \
	../output/2010CountyCensusA.dta  \
	../output/2010CountyCensusL.xlsx \
	../output/all_china_townships_2000.dta \
	../output/allchina_township_class3.csv \
	../output/County2000.xls \
	../output/county_2000_shapefile.csv \
	../output/townships_2010_shapefile.csv \
	$(foreach ext,$(shp_file_ext),../output/China_2000_counties.$(ext)) \
	$(foreach ext,$(shp_file_ext),../output/China_2010_counties.$(ext)) \
	$(foreach ext,$(shp_file_ext),../output/townships_2000_epsg4326.$(ext)) \
	$(shp_output) \
	../output/F152000.v4b_web.stable_lights.avg_vis.tif \
	../output/F182010.v4d_web.stable_lights.avg_vis.tif

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

#unzip content
$(foreach ext,$(shp_file_ext),../input/China_2000_counties.$(ext)): | ../input/China_2000_counties.zip
	unzip ../input/China_2000_counties.zip -d ../input
$(foreach ext,$(shp_file_ext),../input/China_2010_counties.$(ext)): | ../input/China_2010_counties.zip
	unzip ../input/China_2010_counties.zip -d ../input
$(foreach ext,$(shp_file_ext),../input/townships_2000_epsg4326.$(ext)): | ../input/townships_2000_epsg4326.zip
	unzip ../input/townships_2000_epsg4326.zip -d ../input
$(foreach ext,$(shp_file_ext),../input/all_China_townships_2010_epsg4326.$(ext)): | ../input/all_China_townships_2010_epsg4326.zip
	unzip ../input/all_China_townships_2010_epsg4326.zip -d ../input

# symbolic links
../output/2010CountyCensusA.xlsx ../output/2010CountyCensusL.xlsx ../output/2010CountyCensusA.dta ../output/all_china_townships_2000.dta ../output/allchina_township_class3.csv:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/County2000.xls ../output/county_2000_shapefile.csv ../output/townships_2010_shapefile.csv:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/China_2000_counties.%:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/China_2010_counties.%:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/townships_2000_epsg4326.%:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi

# retrieved from web
../output/F152000.v4b_web.stable_lights.avg_vis.tif:
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F152000.v4.tar" -O ../input/F152000.v4.tar
	tar -C ../output/ -xvf ../input/F152000.v4.tar
	gunzip ../output/F152000.v4b_web.stable_lights.avg_vis.tif.gz
../output/F182010.v4d_web.stable_lights.avg_vis.tif:
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F182010.v4.tar" -O ../input/F182010.v4.tar
	tar -C ../output/ -xvf ../input/F182010.v4.tar
	gunzip ../output/F182010.v4d_web.stable_lights.avg_vis.tif.gz

# produced inputs
$(shp_output): $(input) modify.R run_modify.sbatch
	if command -v sbatch > /dev/null ; then sbatch -W run_modify.sbatch ; else Rscript modify.R ; fi
