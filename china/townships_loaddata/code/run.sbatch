#!/bin/sh

#SBATCH --job-name=townships_loaddata
#SBATCH --output=slurmlogs/townships_loaddata_%j.out
#SBATCH --error=slurmlogs/townships_loaddata_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
