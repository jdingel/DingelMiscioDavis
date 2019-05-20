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

source("functions_sp_join.R")

# retrieve command line arguments
args <- commandArgs(trailingOnly=TRUE)
aea_proj4 <- as.character(args[1])
bright    <- as.numeric(args[2])
if (length(args)!=2) {
  stop(paste0(length(args)," command-line argument(s) argument provided. ",
              "Two are required: projection and brightness."))
}

sp_join(contourpoly=paste0("../output/nightlight_contour_2010_",bright,".shp"),
        adminpoly="../input/municipios_2010.shp",
        proj4=aea_proj4,
        out=paste0("mapping_municipios_2010_NTL",bright))
