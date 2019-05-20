#!/bin/sh

#SBATCH --partition=broadwl
#SBATCH --job-name=cbsa
#SBATCH --output=slurmlogs/cbsa_%j.out
#SBATCH --error=slurmlogs/cbsa_%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
