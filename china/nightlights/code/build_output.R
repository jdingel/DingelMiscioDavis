############################################################################################################
# Objective: Apply DMD Lights at Night Toolbox
# Input: Metro assignment files, Night-light raster, administrative shapefile, night-light polygon shapefile
# Output: Final geo-msa normalized output and Figure 1 (three panels)
############################################################################################################

########################
# Computing resources
########################

#Clean directory
rm(list=ls())

# define functions
source("functions_build_output.R")

## write normalized output

# individual brightness threshold files
data_join(infile="mapping_townships_2000_NTL",
          id="gbcode",join=F,
          outfile="townships_2000_NTL")
data_join(infile="mapping_townships_2010_NTL",
          id="gbcode",join=F,
          outfile="townships_2010_NTL")
data_join(infile="mapping_counties_2000_NTL",
          id="GBCNTY",join=F,
          outfile="counties_2000_NTL")
data_join(infile="mapping_counties_2010_NTL",
          id="GbCounty",join=F,
          outfile="counties_2010_NTL")

# write the joined files
data_join(infile="mapping_townships_2000_NTL",
          id="gbcode",join=T,
          outfile="allNTL_townships_2000")
data_join(infile="mapping_townships_2010_NTL",
          id="gbcode",join=T,
          outfile="allNTL_townships_2010")
data_join(infile="mapping_counties_2000_NTL",
          id="GBCNTY",join=T,
          outfile="allNTL_counties_2000")
data_join(infile="mapping_counties_2010_NTL",
          id="GbCounty",join=T,
          outfile="allNTL_counties_2010")

## Figure 1

# define color
raster_blues <- colorRampPalette(c(RColorBrewer::brewer.pal(9,"Blues"),"black"))
# retrieve equal area projection
args <- commandArgs(trailingOnly=TRUE)
aea_proj4 <- as.character(args[1])
# define bounding box
Shanghai_box <- c(119,122.5,30.25,32.75)

# Figure 1A: Raster layer masked on Shanghai land area
map_raw_raster(rasterfile = "../output/F152000.v4b_web.stable_lights.avg_vis_China.tif",
               shapefile = "../input/townships_2000_epsg4326.shp",
               proj4=aea_proj4,
               image_out="nightlight_raster_township_2000_map_uncropped",
               scheme=rev(raster_blues(63)),
               breakvals=seq(0,63,1),
               zoom_box=Shanghai_box,
               zoom=TRUE)

# Figure 1B: Polygon shapefile overlayed on administrative shapefile with scalebar
map_light_shp(admin_shapefile = "../input/townships_2000_epsg4326.shp",
              light_shapefile = "../output/nightlight_contour_2000_30.shp",
              image_out="radar_map_townships_2000_30_uncropped",
              proj4=aea_proj4,
              zoom_box=Shanghai_box,
              scale_loc=c(121.55,30.45),
              zoom=TRUE)

#Figure 1C: Maps of township-metro assignment
map_metros(metro_shapefile = "../output/mapping_townships_2000_NTL30.shp",
           image_out="assignment_map_townships_2000_metros_NTL30_uncropped",
           proj4=aea_proj4,
           zoom_box=Shanghai_box,
           zoom=TRUE)
