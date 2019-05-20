#!/bin/sh

#SBATCH --job-name=populationelasticities
#SBATCH --output=slurmlogs/populationelasticities_%j.out
#SBATCH --error=slurmlogs/populationelasticities_%j.err
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
