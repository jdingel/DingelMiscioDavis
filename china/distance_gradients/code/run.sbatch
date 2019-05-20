#!/bin/sh

#SBATCH --job-name=distance_gradients
#SBATCH --output=slurmlogs/distance_gradients_%j.out
#SBATCH --error=slurmlogs/distance_gradients_%j.err
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
