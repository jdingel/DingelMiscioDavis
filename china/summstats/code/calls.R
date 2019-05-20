
########################
# Computing resources
########################

#Clean directory
rm(list=ls())

# Load libraries
packages = c("sf","units","data.table","rgdal","rgeos","sp","geosphere","dplyr")
for (i in packages){
  if (require(i,character.only=TRUE)==FALSE){
    install.packages(i,repos='http://cran.us.r-project.org')
  }
  else{
    require(i,character.only=TRUE)
  }
}

source("functions.R")
args <- commandArgs(trailingOnly=TRUE)
aea_proj4 <- as.character(args[1])

#townships 2000
geo_calc(shapefile="../input/townships_2000_epsg4326.shp",
         outfile="china_townships_area_2000",
         proj4=aea_proj4,
         details=T,
         year=2000,
         geounit="township")
#counties 2000
geo_calc(shapefile="../input/China_2000_counties.shp",
         outfile="china_counties_area_2000",
         proj4=aea_proj4,
         details=T,
         year=2000,
         geounit="county")
#townships 2010
geo_calc(shapefile="../input/townships_2010_epsg4326.shp",
         outfile="china_townships_area_2010",
         proj4=aea_proj4,
         details=T,
         year=2010,
         geounit="township")
#counties 2010
geo_calc(shapefile="../input/China_2010_counties.shp",
         outfile="china_counties_area_2010",
         proj4=aea_proj4,
         details=T,
         year=2010,
         geounit="county")
