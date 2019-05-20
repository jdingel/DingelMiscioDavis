#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/MSAs_2001.dta \
	../input/town_2001.dta \
	../input/town_edu_count.dta \
	../input/town_edu_count_4Groups.dta

output=\
	../output/binassignments.dta \
	../output/weights_edu_4group.dta \
	../output/pairwise_edu_4group_0.tex \
	../output/pairwise_edu_4group_0.dta

#Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/town_2001.dta ../input/MSAs_2001.dta ../input/town_edu_count.dta ../input/town_ind_count.dta ../input/town_occ_count.dta:
	if [ -e ../../town_MSA_loaddata/output/$(@F) ] ; then ln -s ../../town_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi
../input/town_edu_count_%.dta:
	if [ -e ../../town_MSA_loaddata/output/$(@F) ] ; then ln -s ../../town_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
