# Definitions
folders=slurmlogs ../input ../output

input=../input/census_popmun_1872-2010.xls

output=\
	../output/BR_municipio_geoid.dta \
	../output/BR_MUNICIPIO_POP.dta

# Recipes
all: $(folders) $(input) $(output)

$(folders):
	mkdir $@

../input/census_popmun_1872-2010.xls: | ../input
	if [ -e ../../initialdata/output/$(@F) ] ; then ln -s ../../initialdata/output/$(@F) ../input/ ; else exit 1; fi

$(output): $(input) calls.do programs.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; fi
