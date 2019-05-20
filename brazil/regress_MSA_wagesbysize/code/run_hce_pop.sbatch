#!/bin/sh

#SBATCH --job-name=regress_hcepop
#SBATCH --output=slurmlogs/regress_hcepop_%j.out
#SBATCH --error=slurmlogs/regress_hcepop_%j.err
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls_hce_pop.do
bash hce_pop_cleantable.sh
