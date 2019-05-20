#!/bin/sh

#SBATCH --job-name=NTL_brazil_input
#SBATCH --output=slurmlogs/Br_NTL_modify_input%j.out
#SBATCH --error=slurmlogs/Br_NTL_modify_input%j.err
#SBATCH --time=0:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R

Rscript modify.R > modify.log
