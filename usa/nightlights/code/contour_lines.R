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
continental_eqdc_proj4 <- as.character(args[1])
alaska_aeqd_proj4      <- as.character(args[2])
hawaii_aeqd_proj4      <- as.character(args[3])
bright                 <- as.numeric(args[4])
if (length(args)!=4) {
	stop(paste0(length(args)," command-line argument(s) argument provided. ",
							"Four are required: three projections and brightness."))
}

# Continental US
contour_lines(rasta="F182010.v4d_web.stable_lights.avg_vis_continental",
           		thresh=bright*10, #Necessary to address a bug in gdal_contour function in GDAL versions prior to 2.4.
           		proj4=continental_eqdc_proj4,
           		shapeout=paste0("nightlight_contour_2010_continental_",bright))

# Alaska
contour_lines(rasta="F182010.v4d_web.stable_lights.avg_vis_alaska",
           		thresh=bright*10, #Necessary to address a bug in gdal_contour function in GDAL versions prior to 2.4.
           		proj4=alaska_aeqd_proj4,
           		shapeout=paste0("nightlight_contour_2010_alaska_",bright))

# Hawaii
contour_lines(rasta="F182010.v4d_web.stable_lights.avg_vis_hawaii",
            	thresh=bright*10, #Necessary to address a bug in gdal_contour function in GDAL versions prior to 2.4.
            	proj4=hawaii_aeqd_proj4,
            	shapeout=paste0("nightlight_contour_2010_hawaii_",bright))
