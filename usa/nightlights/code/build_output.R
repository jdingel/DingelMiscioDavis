############################################################################################################
# Objective: Apply DMD Lights at Night Toolbox
# Input: Metro assignment files
# Output: Final geo-msa normalized output
############################################################################################################

########################
# Computing resources
########################

#Clean directory
rm(list=ls())

# define functions
source("functions_build_output.R")

# individual brightness threshold files
data_join(infile="mapping_counties_2010_",
          id="GEOID10",join=T,
          outfile="US_counties_2010_NTL")
