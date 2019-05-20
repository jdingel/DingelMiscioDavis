#!/bin/sh

#SBATCH --job-name=NTL_Brazil_contour_lines
#SBATCH --output=slurmlogs/Nightlights_Brazil_contour_lines%j.out
#SBATCH --error=slurmlogs/Nightlights_Brazil_contour_lines%j.err
#SBATCH --array=10-60:10
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=END,FAIL

module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R

Rscript contour_lines.R "$(cat ../input/proj4string.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" ${SLURM_ARRAY_TASK_ID} > contour_lines.log
