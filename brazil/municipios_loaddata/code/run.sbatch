#!/bin/sh

#SBATCH --job-name=municipios_loaddata
#SBATCH --output=slurmlogs/municipios_loaddata_%j.out
#SBATCH --error=slurmlogs/municipios_loaddata_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
