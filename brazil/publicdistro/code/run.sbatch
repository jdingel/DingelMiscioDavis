#!/bin/sh

#SBATCH --job-name=clean
#SBATCH --output=slurmlogs/clean_%j.out
#SBATCH --error=slurmlogs/clean_%j.err
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b clean.do
