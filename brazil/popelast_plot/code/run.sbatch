#!/bin/sh

#SBATCH --job-name=popelast_plot
#SBATCH --output=slurmlogs/popelast_plot_%j.out
#SBATCH --error=slurmlogs/popelast_plot_%j.err
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
