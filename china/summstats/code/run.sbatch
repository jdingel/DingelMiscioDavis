#!/bin/sh

#SBATCH --job-name=China_summstats
#SBATCH --output=slurmlogs/China_summstats_%j.out
#SBATCH --error=slurmlogs/China_summstats_%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=END,FAIL

module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R

Rscript calls.R "$(cat ../input/proj4string.txt | sed 's/mm/m/')" > calls.log
