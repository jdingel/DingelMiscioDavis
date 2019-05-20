#!/bin/sh

#SBATCH --job-name=zipf
#SBATCH --output=slurmlogs/zipf_%j.out
#SBATCH --error=slurmlogs/zipf_%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
