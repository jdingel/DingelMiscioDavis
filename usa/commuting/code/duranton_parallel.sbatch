#!/bin/sh

#SBATCH --job-name=commuting_duranton_USA
#SBATCH --output=slurmlogs/commuting_duranton_USA_job_%A_%a.out
#SBATCH --error=slurmlogs/commuting_duranton_USA_job_%A_%a.err
#SBATCH --array=10-35
#SBATCH --partition=covert-dingel
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --mail-type=END,FAIL

######################
# Begin work section #
######################

module load stata
stata-se duranton_parallel.do ${SLURM_ARRAY_TASK_ID}
