#!/bin/sh

#SBATCH --job-name=census_microdata
#SBATCH --output=slurmlogs/census_microdata_%j.out
#SBATCH --error=slurmlogs/census_microdata_%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
