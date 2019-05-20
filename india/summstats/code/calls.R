
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
# define projection
args <- commandArgs(trailingOnly=TRUE)
aea_proj4 <- as.character(args[1])

geo_calc(shapefile="../input/sub_districts.shp",
         outfile="india_sub_districts_area",
         proj4=aea_proj4,
         details=T)
