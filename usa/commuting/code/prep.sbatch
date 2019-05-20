#!/bin/sh

#SBATCH --partition=covert-dingel
#SBATCH --job-name=prep_commuting
#SBATCH --output=slurmlogs/prep_commuting_%j.out
#SBATCH --error=slurmlogs/cprep_ommuting_%j.err
#SBATCH --time=0:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b prep_commuting.do
