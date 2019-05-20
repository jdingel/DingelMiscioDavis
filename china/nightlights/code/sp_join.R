##########################################################
# Objective: Apply DMD Lights at Night Toolbox
# Input: Contour line polygons of raster + Administrative Shapefile
# Output: Metro assignment to constituent unit (csv+shp)
##########################################################

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
geo       <- as.character(args[2])
year      <- as.numeric(args[3])
bright    <- as.numeric(args[4])
if (length(args)!=4) {
  stop(paste0(length(args)," command-line argument(s) argument provided. ",
              "Four are required: projection, geography, year, brightness."))
}

if (geo=="counties") {

  sp_join(contourpoly=paste0("../output/nightlight_contour_",year,"_",bright,".shp"),
          adminpoly=paste0("../input/China_",year,"_counties.shp"),
          proj4=aea_proj4,
          out=paste0("mapping_counties_",year,"_NTL",bright))

}
if (geo=="townships") {

  sp_join(contourpoly=paste0("../output/nightlight_contour_",year,"_",bright,".shp"),
          adminpoly=paste0("../input/townships_",year,"_epsg4326.shp"),
          proj4=aea_proj4,
          out=paste0("mapping_townships_",year,"_NTL",bright))

}
