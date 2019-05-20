################################################################################
# Objective: Apply DMD Lights at Night Toolbox
# Input: Raster input
# Output: Contour line polygons of raster
################################################################################

########################
# Computing resources
########################

#Clean directory
rm(list=ls())

# define functions
source("functions_contour_lines.R")

# retrieve command line arguments
args <- commandArgs(trailingOnly=TRUE)
aeqd_proj4 <- as.character(args[1])
bright     <- as.numeric(args[2])
if (length(args)!=2) {
  stop(paste0(length(args)," command-line argument(s) argument provided. ",
              "Two are required: projection and brightness."))
}

contour_lines(rasta="F182010.v4d_web.stable_lights.avg_vis_Brazil",
           		thresh=bright,
           		proj4=aeqd_proj4,
           		shapeout=paste0("nightlight_contour_2010_",bright))
