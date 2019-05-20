#!/bin/sh

#SBATCH --output=slurmlogs/%x_%j.out
#SBATCH --error=slurmlogs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=END,FAIL

$command1
$command2
