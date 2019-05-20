#!/bin/sh

#SBATCH --partition=broadwl
#SBATCH --job-name=county_to_MSA
#SBATCH --output=slurmlogs/county_to_MSA_%j.out
#SBATCH --error=slurmlogs/county_to_MSA_%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
