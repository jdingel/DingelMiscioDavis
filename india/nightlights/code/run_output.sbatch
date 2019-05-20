#!/bin/sh

#SBATCH --job-name=NTL_India
#SBATCH --output=slurmlogs/Nightlights_India_build_output%j.out
#SBATCH --error=slurmlogs/Nightlights_India_build_output%j.err
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R

Rscript build_output.R > build_output.log
