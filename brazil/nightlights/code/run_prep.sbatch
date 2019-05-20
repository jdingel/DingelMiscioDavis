#!/bin/sh

#SBATCH --job-name=NTL_brazil_prep
#SBATCH --output=slurmlogs/Nightlights_Brazil_prep_raster%j.out
#SBATCH --error=slurmlogs/Nightlights_Brazil_prep_raster%j.err
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R

Rscript prep_raster.R "$(cat ../input/proj4string.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" > prep_raster.log
