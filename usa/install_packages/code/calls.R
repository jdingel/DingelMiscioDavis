#Clean directory
rm(list=ls())

packages = c("bit64","CEoptim","data.table","devtools","doParallel","dplyr",
            "gdalUtils","GISTools","igraph","MapColoring","maps","maptools",
            "raster","rgdal","rgeos","sp","viridis","sf","units","lwgeom")

for (i in packages){
  if (require(i,character.only=TRUE)==FALSE){
    install.packages(i,repos='http://cran.us.r-project.org')
  }
  else{
    require(i,character.only=TRUE)
  }
}
devtools::install_github("hunzikp/MapColoring")

fileConn<-file("R_packages.txt")
writeLines(c("Package installation commands ran."), fileConn)
close(fileConn)
