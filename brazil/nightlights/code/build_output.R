################################################################################
# Objective: Apply DMD Lights at Night Toolbox
# Input: Metro assignment files
# Output: Final geo-msa normalized output
################################################################################

########################
# Computing resources
########################

#Clean directory
rm(list=ls())

# define functions
source("functions_build_output.R")

## write final output
# individual NTL XX brightness threshold files
data_join(infile="mapping_municipios_2010_NTL",
          id="CD_GEOCODM",join=F,
          outfile="municipios_2010_NTL")

# write the joined files
data_join(infile="mapping_municipios_2010_NTL",
          id="CD_GEOCODM",join=T,
          outfile="allNTL_municipios_2010")
