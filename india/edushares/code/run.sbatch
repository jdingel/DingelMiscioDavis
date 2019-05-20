#!/bin/sh

#SBATCH --job-name=edushares
#SBATCH --output=slurmlogs/edushares_%j.out
#SBATCH --error=slurmlogs/edushares_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
