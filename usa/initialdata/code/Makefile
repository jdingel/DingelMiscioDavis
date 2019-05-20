# Definitions
folders=../input ../output slurmlogs

input_shp_file_ext := shp shp.xml shx dbf prj
shp_file_ext := shp shx dbf prj

modified_geo_output=\
	../output/tl_2010_us_county10.csv \
	$(foreach ext,$(shp_file_ext),$(foreach area,continental_US alaska hawaii,../output/tl_2010_us_county10_$(area).$(ext)))

output=\
	$(foreach ext,$(input_shp_file_ext),../output/tl_2010_us_county10.$(ext)) \
	../output/states.csv \
	../output/CO-EST2015-alldata.csv \
	../output/List1.txt \
	../output/List1_2013.xls \
	$(modified_geo_output) \
	../output/tl_2010_us_county10.csv \
	../output/acs_commute_flows_table1.xlsx \
	../output/F182010.v4d_web.stable_lights.avg_vis.tif

# Recipes
all: $(folders) $(modified_geo_output) $(output)

$(folders):
	mkdir $@

# Nighlights image retrieved from web
../output/F182010.v4d_web.stable_lights.avg_vis.tif: | ../input/ ../output
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F182010.v4.tar" -O ../input/F182010.v4.tar
	tar -C ../output/ -xvf ../input/F182010.v4.tar
	gunzip ../output/F182010.v4d_web.stable_lights.avg_vis.tif.gz
# ACS commuting flows
../output/acs_commute_flows_table1.xlsx: | ../output
	wget "https://www2.census.gov/programs-surveys/commuting/tables/time-series/commuting-flows/table1.xlsx" -O ../output/acs_commute_flows_table1.xlsx
# State list and abbreviations
../output/states.csv: | ../output
	wget "https://raw.githubusercontent.com/jasonong/List-of-US-States/master/states.csv" -O ../output/states.csv
#CBSA definitions
../output/List1.txt: | ../output
	wget "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2009/historical-delineation-files/list1.txt" -O ../output/List1.txt
../output/List1_2013.xls: | ../output
	wget "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2013/delineation-files/list1.xls" -O ../output/List1_2013.xls
#County population counts
../output/CO-EST2015-alldata.csv: | ../output
	wget "https://www2.census.gov/programs-surveys/popest/datasets/2010-2015/counties/totals/co-est2015-alldata.csv" -O ../output/CO-EST2015-alldata.csv
#County shapefiles
$(foreach ext,$(input_shp_file_ext),../output/tl_2010_us_county10.$(ext)): | ../output
	wget "https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2010/tl_2010_us_county10.zip" -O ../output/tl_2010_us_county10.zip
	unzip ../output/tl_2010_us_county10.zip -d ../output/
# produced output
$(modified_geo_output): modify.R run_modify.sbatch $(foreach ext,$(input_shp_file_ext),../output/tl_2010_us_county10.$(ext))
	if command -v sbatch > /dev/null ; then sbatch -W run_modify.sbatch ; else Rscript modify.R ; fi
