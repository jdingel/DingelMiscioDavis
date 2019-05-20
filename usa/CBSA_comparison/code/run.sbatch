#!/bin/sh

#SBATCH --partition=broadwl
#SBATCH --job-name=CBSA_comparison
#SBATCH --output=slurmlogs/CBSA_comparison_%j.out
#SBATCH --error=slurmlogs/CBSA_comparison_%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b CBSA_comparison.do
