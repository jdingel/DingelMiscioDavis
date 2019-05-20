#Definitions
folders=slurmlogs ../input ../output

input=\
	../input/town_edu_count_4Groups.dta \
	../input/MSAs_2001.dta \
	../input/town_2001.dta

output=\
	../output/edu_popelasticity_B9_4scheme_2001.tex \
	../output/edu_popelasticity_B9_4scheme_2001.txt

#Recipes
all: $(folders) $(input) $(output) ../output/edu_popelasticity_B9_4scheme_2001_clean.tex

$(folders):
	mkdir $@

../input/town_2001.dta ../input/MSAs_2001.dta ../input/town_edu_count_4Groups.dta:
	if [ -e ../../town_MSA_loaddata/output/$(@F) ] ; then ln -s ../../town_MSA_loaddata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi

../output/edu_popelasticity_B9_4scheme_2001_clean.tex: cleantable.sh ../output/edu_popelasticity_B9_4scheme_2001.tex
	bash cleantable.sh
