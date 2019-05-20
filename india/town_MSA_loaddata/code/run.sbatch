#!/bin/sh

#SBATCH --job-name=town_MSA_loaddata
#SBATCH --output=slurmlogs/town_MSA_loaddata_%j.out
#SBATCH --error=slurmlogs/town_MSA_loaddata_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
