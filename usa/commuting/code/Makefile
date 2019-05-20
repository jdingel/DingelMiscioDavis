# Definitions
folders=../input ../output slurmlogs

input=../input/acs_commute_flows_table1.xlsx

output=\
	../output/US_counties_commuting.dta \
	$(foreach flow,$(shell seq 10 35),$(foreach class,steps mapping,../output/Duranton_$(class)_$(flow).dta))

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/acs_commute_flows_table1.xlsx:
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

../output/US_counties_commuting.dta: $(input) prep_commuting.do prep.sbatch  | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W prep.sbatch; else stata-se -e prep_commuting.do; fi

$(foreach flow,$(shell seq 10 35),$(foreach class,steps mapping,../output/Duranton_$(class)_$(flow).dta)): ../output/US_counties_commuting.dta programs.do duranton_parallel.do duranton_parallel.sbatch duranton_serial.do
	if command -v sbatch > /dev/null ; then sbatch -W duranton_parallel.sbatch; else stata-se -e duranton_serial.do; fi
