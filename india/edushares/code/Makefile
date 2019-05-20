#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/town_edu_count_AllPop_4Groups.dta \
	../input/town_edu_count_AllPop_state.dta \
	../input/town_2001.dta \
	../input/MSAs_2001.dta

output=../output/edu_shares_UA.tex

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/town_2001.dta ../input/MSAs_2001.dta ../input/town_edu_count_AllPop_4Groups.dta ../input/town_edu_count_AllPop_state.dta:
	if [ -e ../../town_MSA_loaddata/output/$(@F) ] ; then ln -s ../../town_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
