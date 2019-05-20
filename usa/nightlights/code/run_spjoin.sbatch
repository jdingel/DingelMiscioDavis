#!/bin/sh

#SBATCH --partition=covert-dingel
#SBATCH --job-name=NTL_USA_sp_join
#SBATCH --output=slurmlogs/Nightlights_USA_sp_join%j.out
#SBATCH --error=slurmlogs/Nightlights_USA_sp_join%j.err
#SBATCH --array=30-62:2
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

Rscript sp_join.R "$(cat ../input/proj4string_continental.txt)" \
                  "$(cat ../input/proj4string_alaska.txt | sed 's/+lat\_0=50/+lat\_0=60/')" \
                  "$(cat ../input/proj4string_hawaii.txt)" \
                  ${SLURM_ARRAY_TASK_ID} \
> sp_join.log
