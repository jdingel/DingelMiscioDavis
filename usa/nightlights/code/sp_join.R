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
continental_aea_proj4 <- as.character(args[1])
alaska_aea_proj4      <- as.character(args[2])
hawaii_aea_proj4      <- as.character(args[3])
bright                <- as.numeric(args[4])
if (length(args)!=4) {
	stop(paste0(length(args)," command-line argument(s) argument provided. ",
							"Four are required: three projections and brightness."))
}

# Continental US
sp_join(contourpoly=paste0("../output/nightlight_contour_2010_continental_",bright,".shp"),
        adminpoly="../input/tl_2010_us_county10_continental_US.shp",
        proj4=continental_aea_proj4,
        out=paste0("mapping_counties_2010_continental_NTL",bright))

# Alaska
sp_join(contourpoly=paste0("../output/nightlight_contour_2010_alaska_",bright,".shp"),
        adminpoly="../input/tl_2010_us_county10_alaska.shp",
        proj4=alaska_aea_proj4,
        out=paste0("mapping_counties_2010_alaska_NTL",bright))

# Hawaii
sp_join(contourpoly=paste0("../output/nightlight_contour_2010_hawaii_",bright,".shp"),
        adminpoly="../input/tl_2010_us_county10_hawaii.shp",
        proj4=hawaii_aea_proj4,
        out=paste0("mapping_counties_2010_hawaii_NTL",bright))
