#Definitions
folders=slurmlogs
output=stata_packages.txt R_packages.txt

#Recipes

all: $(output)

$(folders):
	mkdir $@

$(output): calls.do run.sbatch | $(folders)
	if command -v sbatch > /dev/null ; then sbatch -W run.sbatch; else stata-se -e calls.do; Rscript -e calls.R; fi
