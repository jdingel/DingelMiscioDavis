#!/bin/sh

#SBATCH --job-name=install_packages
#SBATCH --output=slurmlogs/install_packages_%j.out
#SBATCH --error=slurmlogs/install_packages_%j.err
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=END,FAIL

module load stata
stata-se -b calls.do

module load python
module load geos/3.7.0
module load gdal/2.3.2
module load udunits/2.2
module load proj/4.9
module load R
Rscript calls.R
