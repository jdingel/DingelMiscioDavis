#Definitions
FOLDERS= slurmlogs ../input ../output

#states_citylist (27 states); states_list (35 states)
states_citylist  := Andhra_Pradesh Assam Bihar Chandigarh Chhattisgarh Delhi Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Orissa Puducherry Punjab Rajasthan Tamil_Nadu Tripura Uttar_Pradesh Uttarakhand West_Bengal
states_partiallist2 := Andhra_Pradesh Assam Bihar Chhattisgarh Delhi Goa Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Madhya_Pradesh Maharashtra Manipur Meghalaya Orissa Puducherry Punjab Rajasthan Tamil_Nadu Uttar_Pradesh Uttarakhand West_Bengal
states_list := Andaman_and_Nicobar_Islands Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh Chhattisgarh Dadra_and_Nagar_Haveli Daman_and_Diu Delhi Goa Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Lakshadweep Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Orissa Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Tripura Uttar_Pradesh Uttarakhand West_Bengal

B9_INPUTS  = $(foreach state,$(states_citylist),../input/B_9_City_$(state).xls)
C8_CITY_INPUTS = $(foreach state,$(states_citylist),../input/C_8_City_$(state).xls)

PCA_CSV_INPUTS = $(foreach state,$(states_partiallist2),../input/PCA_UA_Table_For_$(state).csv)

C8_INPUTS = $(foreach state,$(states_list),../input/C_8_$(state).xls)
PCA_XLS_INPUTS = $(foreach state,$(states_list),../input/PCA_UA_Table_For_$(state).xls)
PCALONG_XLS_INPUTS = $(foreach state,$(states_list),../input/Primary_Census_Abstract_Urban_Aglomeration_Table_For_$(state).xlsx)
TOWNDIRECTORY_INPUTS = $(foreach state,$(states_list),../input/Town_directory_$(state)_Table_For_$(state).xls)

B9_OUTPUTS = $(foreach state,$(states_citylist),../output/B_9_City_$(state).xls)
C8_OUTPUTS = $(foreach state,$(states_list),../output/C_8_$(state).xls)
C8_CITY_OUTPUTS = $(foreach state,$(states_citylist),../output/C_8_City_$(state).xls)
PCA_CSV_OUTPUTS = $(foreach state,$(states_partiallist2),../output/PCA_UA_Table_For_$(state).csv)
PCA_XLS_OUTPUTS = $(foreach state,$(states_list),../output/PCA_UA_Table_For_$(state).xls)
PCALONG_XLS_OUTPUTS = $(foreach state,$(states_list),../output/Primary_Census_Abstract_Urban_Aglomeration_Table_For_$(state).xlsx)
TOWNDIRECTORY_OUTPUTS = $(foreach state,$(states_list),../output/Town_directory_$(state)_Table_For_$(state).xls)

input_shp_file_ext := shp shx dbf qpj prj
shp_file_ext := shp shx dbf prj

VILLAGES = $(foreach villa,$(shell seq 1 6) $(shell seq 8 35), ../output/village_2011_2001_$(villa).csv)

INPUT=\
	$(B9_INPUTS) $(C8_CITY_INPUTS) $(C8_INPUTS) \
	$(PCA_XLS_INPUTS) $(PCA_CSV_INPUTS) $(PCALONG_XLS_INPUTS) \
	$(TOWNDIRECTORY_INPUTS) \
	../input/B_9_City_india.xls \
	../input/C_8_City_India.xls \
	../input/C_8_India.xls \
	../input/mCensus11_Stru.xls \
	../input/village_2011_2001_7.csv

INPUT_SHP = $(foreach ext,$(input_shp_file_ext),../input/india_sub_districts_epsg32644.$(ext))

OUTPUT=\
	../output/B_9_City_india.xls \
	../output/C_8_City_India.xls \
	../output/C_8_India.xls \
	../output/mCensus11_Stru.xls \
	../output/admin_level3_urban.xls \
	../output/admin_level3.xls \
	../output/town_2011_2001.csv \
	../output/subdistricts_directory.dta \
	$(B9_OUTPUTS) \
	$(C8_OUTPUTS) \
	$(C8_CITY_OUTPUTS) \
	$(PCA_CSV_OUTPUTS) \
	$(PCA_XLS_OUTPUTS) \
	$(PCALONG_XLS_OUTPUTS) \
	$(TOWNDIRECTORY_OUTPUTS) \
	$(foreach ext,$(shp_file_ext),../output/sub_districts.$(ext)) \
	../output/DDWCITY_B_09_0000.xlsx \
	../output/DDWCT_0000C_08.xlsx \
	../output/F152001.v4b_web.stable_lights.avg_vis.tif \
	../output/F182011.v4c_web.stable_lights.avg_vis.tif \
	../output/village_2011_2001_7.csv \
	$(VILLAGES)

#Recipes
all: $(FOLDERS) $(INPUT) $(OUTPUT)

$(FOLDERS):
	mkdir $@

$(INPUT): 
	unzip ../input/India_Excel_files.zip -d ../input
$(INPUT_SHP):
	unzip ../input/india_sub_districts_epsg32644.zip -d ../input
../input/subdistricts_directory.dta:
	unzip ../input/subdistricts_directory.dta.zip -d ../input

# outputs retrieved from the web
../output/F152001.v4b_web.stable_lights.avg_vis.tif: | ../output/
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F152001.v4.tar" -O ../input/F152001.v4.tar
	tar -C ../output/ -xvf ../input/F152001.v4.tar
	gunzip ../output/F152001.v4b_web.stable_lights.avg_vis.tif.gz
../output/F182011.v4c_web.stable_lights.avg_vis.tif: | ../output/
	wget "https://ngdc.noaa.gov/eog/data/web_data/v4composites/F182011.v4.tar" -O ../input/F182011.v4.tar
	tar -C ../output/ -xvf ../input/F182011.v4.tar
	gunzip ../output/F182011.v4c_web.stable_lights.avg_vis.tif.gz
$(VILLAGES): | ../output/
	wget "http://egovstandards.gov.in/sites/default/files/$(@F)" -O $@
../output/DDWCITY_B_09_0000.xlsx:
	wget "http://censusindia.gov.in/2011census/B-series/DDWCITY-B-09-0000.xlsx" -O ../output/DDWCITY_B_09_0000.xlsx
../output/DDWCT_0000C_08.xlsx:
	wget "http://censusindia.gov.in/2011census/C-series/DDWCT-0000C-08.xlsx" -O ../output/DDWCT_0000C_08.xlsx

# produced outputs
../output/sub_districts.shp: $(INPUT_SHP)
	if command -v sbatch > /dev/null ; then sbatch -W run_modify.sbatch; else Rscript modify.R; fi

# outputs from source
$(B9_OUTPUTS) $(C8_OUTPUTS) $(C8_CITY_OUTPUTS) ../output/B_9_City_india.xls ../output/C_8_India.xls ../output/C_8_City_India.xls:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/india_sub_districts_epsg32644.%:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/mCensus11_Stru.xls ../output/NCO_2004_subdivisions.dta:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
$(PCA_CSV_OUTPUTS) $(PCA_XLS_OUTPUTS) $(PCALONG_XLS_OUTPUTS):
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/town%:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/Town%:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/admin_level3_urban.xls ../output/admin_level3.xls:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/subdistricts_directory.dta: ../input/subdistricts_directory.dta
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
../output/village_2011_2001_7.csv:
	if [ -e ../input/$(@F) ] ; then ln -s ../input/$(@F) ../output/ ; else exit 1; fi
