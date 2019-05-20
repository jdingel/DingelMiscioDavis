#!/bin/sh

#SBATCH --job-name=compute_municipio_wages
#SBATCH --output=slurmlogs/compute_municipio_wages_%j.out
#SBATCH --error=slurmlogs/compute_municipio_wages_%j.err
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do
