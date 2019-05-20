#!/bin/sh

#SBATCH --job-name=MSA_traits
#SBATCH --output=slurmlogs/MSA_traits_%j.out
#SBATCH --error=slurmlogs/MSA_traits_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=15g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
