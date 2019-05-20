#Definitions
folders= slurmlogs ../input ../output

states_citylist  := Andhra_Pradesh Assam Bihar Chandigarh Chhattisgarh Delhi Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Orissa Puducherry Punjab Rajasthan Tamil_Nadu Tripura Uttar_Pradesh Uttarakhand West_Bengal
states_partiallist2 := Andhra_Pradesh Assam Bihar Chhattisgarh Delhi Goa Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Madhya_Pradesh Maharashtra Manipur Meghalaya Orissa Puducherry Punjab Rajasthan Tamil_Nadu Uttar_Pradesh Uttarakhand West_Bengal
states_list := Andaman_and_Nicobar_Islands Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh Chhattisgarh Dadra_and_Nagar_Haveli Daman_and_Diu Delhi Goa Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Lakshadweep Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Orissa Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Tripura Uttar_Pradesh Uttarakhand West_Bengal

B9_INPUTS  = $(foreach state,$(states_citylist),../input/B_9_City_$(state).xls)
C8_CITY_INPUTS = $(foreach state,$(states_citylist),../input/C_8_City_$(state).xls)

PCA_CSV_INPUTS = $(foreach state,$(states_partiallist2),../input/PCA_UA_Table_For_$(state).csv)


C8_INPUTS = $(foreach state,$(states_list),../input/C_8_$(state).xls)
PCA_XLS_INPUTS = $(foreach state,$(states_list),../input/PCA_UA_Table_For_$(state).xls)
TOWNDIRECTORY_INPUTS = $(foreach state,$(states_list),../input/Town_directory_$(state)_Table_For_$(state).xls)

INPUT= \
 	../input/DDWCT_0000C_08.xlsx \
 	../input/DDWCITY_B_09_0000.xlsx \
 	../input/India_subdistricts_2001.dta \
 	../input/B_9_City_india.xls \
 	../input/C_8_City_India.xls \
 	../input/C_8_India.xls \
	$(B9_INPUTS) \
	$(PCA_CSV_INPUTS) \
	$(C8_CITY_INPUTS) \
	$(C8_INPUTS) \
	$(PCA_XLS_INPUTS) \
	$(TOWNDIRECTORY_INPUTS) \

output=\
	$(foreach pairing,within cross,../output/mapping_towns_urban_agglomerations_2001_$(pairing).dta) \
	$(foreach pairing,within cross,../output/urban_agglomerations_2001_$(pairing).dta) \
	../output/town_edu_count_AllPop_4Groups_2011.dta \
	../output/town_edu_count_AllPop_2011.dta \
	../output/all_India_series_C8City_2011.dta \
	../output/town_edu_count_4Groups_2011.dta \
	../output/town_edu_count_2011.dta \
	../output/all_India_series_B9City_2011.dta \
	../output/town_edu_count_AllPop_4Groups.dta \
	../output/town_edu_count_AllPop_state.dta \
	../output/all_India_series_C8.dta \
	../output/town_edu_count_AllPop.dta \
	../output/all_India_series_C8City.dta \
	../output/town_edu_count_4Groups.dta \
	../output/town_edu_count.dta \
	../output/all_India_series_B9City.dta \
	../output/district_pop_allages.dta \
	../output/district_pop.dta \
	../output/MSAs_2001.dta \
	../output/town_2001.dta

#Recipes
all: $(folders) $(INPUT) $(output)

$(folders):
	mkdir $@

$(PCA_CSV_INPUTS) $(PCA_XLS_INPUTS) $(TOWNDIRECTORY_INPUTS):
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/B_9%.xls:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/C_8%.xls:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/DDWCITY_B_09_0000.xlsx ../input/DDWCT_0000C_08.xlsx:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi
../input/India_subdistricts_2001.dta:
	if [ -e ../../SDT_MSA_loaddata/output/$(@F) ] ; then ln -s ../../SDT_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(INPUT) calls.do programs_2001.do programs_2011.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
