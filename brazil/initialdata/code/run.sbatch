#!/bin/sh

#SBATCH --job-name=initialdata
#SBATCH --output=slurmlogs/initialdata_%j.out
#SBATCH --error=slurmlogs/initialdata_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=4g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b importfiles.do
stata-se -b data_relabeling.do
