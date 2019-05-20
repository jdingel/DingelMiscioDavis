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

# retrieve proj4string
args <- commandArgs(trailingOnly=TRUE)
aeqd_proj4 <- as.character(args[1])
year 			 <- as.numeric(args[2])
bright     <- as.numeric(args[3])
if (length(args)!=3) {
  stop(paste0(length(args)," command-line argument(s) argument provided. ",
              "Three are required: projection, year, brightness."))
}
if (year==2000){
contour_lines(rasta=paste0("F15",year,".v4b_web.stable_lights.avg_vis_China"),
           		thresh=bright,
           		proj4=aeqd_proj4,
           		shapeout=paste0("nightlight_contour_",year,"_",bright))
}
if (year==2010){
contour_lines(rasta=paste0("F18",year,".v4d_web.stable_lights.avg_vis_China"),
           		thresh=bright,
           		proj4=aeqd_proj4,
           		shapeout=paste0("nightlight_contour_",year,"_",bright))
}
