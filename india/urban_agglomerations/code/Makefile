#Definitions
FOLDERS= slurmlogs ../input ../output

states := Andaman_and_Nicobar_Islands Andhra_Pradesh Arunachal_Pradesh Assam Bihar Chandigarh Chhattisgarh Dadra_and_Nagar_Haveli Daman_and_Diu Delhi Goa Gujarat Haryana Himachal_Pradesh Jammu_and_Kashmir Jharkhand Karnataka Kerala Lakshadweep Madhya_Pradesh Maharashtra Manipur Meghalaya Mizoram Nagaland Orissa Puducherry Punjab Rajasthan Sikkim Tamil_Nadu Tripura Uttar_Pradesh Uttarakhand West_Bengal

INPUT= $(foreach state,$(states),../input/Primary_Census_Abstract_Urban_Aglomeration_Table_For_$(state).xlsx)

output=\
	../output/Towns_notbelongtoUAs.dta \
	../output/Towns_thatbelongtoUAs.dta \
	../output/UAs.dta

#Recipes
all: $(FOLDERS) $(INPUT) $(output)

$(FOLDERS):
	mkdir $@

../input/Primary_Census_Abstract_Urban_Aglomeration_Table%.xlsx:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(INPUT) calls.do programs.do run.sbatch | $(FOLDERS)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
