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

# individual NTL XX brightness level output
data_join(infile="mapping_sub_districts_2001_NTL",
          id="GEOKEY",join=F,
          outfile="sub_districts_2001_NTL")
data_join(infile="mapping_sub_districts_2011_NTL",
          id="GEOKEY",join=F,
          outfile="sub_districts_2011_NTL")

# write the joined files
data_join(infile="mapping_sub_districts_2001_NTL",
          id="GEOKEY",join=T,
          outfile="allNTL_sub_districts_2001")
data_join(infile="mapping_sub_districts_2011_NTL",
          id="GEOKEY",join=T,
          outfile="allNTL_sub_districts_2011")
