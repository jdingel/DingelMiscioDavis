#!/bin/sh

#SBATCH --partition=covert-dingel
#SBATCH --job-name=NTL_USA_contour_lines
#SBATCH --output=slurmlogs/Nightlights_USA_contour_lines%j.out
#SBATCH --error=slurmlogs/Nightlights_USA_contour_lines%j.err
#SBATCH --array=30-62:2
#SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R

Rscript contour_lines.R "$(cat ../input/proj4string_continental.txt | sed 's/aea/eqdc/' | cut -d " " -f 1-3,5-)" \
                        "$(cat ../input/proj4string_alaska.txt | sed 's/aea/aeqd/' | sed 's/+lat\_0=50/+lat\_ts=60/' | cut -d " " -f 1,4-)" \
                        "$(cat ../input/proj4string_hawaii.txt | sed 's/aea/aeqd/' | cut -d " " -f 1,4-)" \
                        ${SLURM_ARRAY_TASK_ID} \
> contour_lines.log
