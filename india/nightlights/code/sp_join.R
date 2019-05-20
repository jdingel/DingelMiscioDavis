############################################################################################################
# Objective: Apply DMD Lights at Night Toolbox
# Input: Contour line polygons of raster + Administrative Shapefile
# Output: Metro assignment to constituent unit (csv+shp)
############################################################################################################

########################
# Computing resources
########################

#Clean directory
rm(list=ls())

# define functions
source("functions_sp_join.R")

# retrieve command line arguments
args <- commandArgs(trailingOnly=TRUE)
aea_proj4 <- as.character(args[1])
year			<- as.numeric(args[2])
bright    <- as.numeric(args[3])
if (length(args)!=3) {
	stop(paste0(length(args)," command-line argument(s) argument provided. ",
							"Three are required: projection, year, brightness."))
}

sp_join(contourpoly=paste0("../output/nightlight_contour_",year,"_",bright,".shp"),
        adminpoly="../input/sub_districts.shp",
        proj4=aea_proj4,
        out=paste0("mapping_sub_districts_",year,"_NTL",bright))
