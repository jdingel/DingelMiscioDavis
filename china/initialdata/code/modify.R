# Load libraries
packages = c("dplyr","sf","lwgeom")
for (i in packages){
  if (require(i,character.only=TRUE)==FALSE){
    install.packages(i,repos='http://cran.us.r-project.org')
  }
  else{
    require(i,character.only=TRUE)
  }
}
library(dplyr)
library(sf)
library(lwgeom)
# write townships file with no duplicates for use
sf_townships_2010 <- sf::st_read("../input/all_China_townships_2010_epsg4326.shp")
sf_townships_2010_valid <- lwgeom::st_make_valid(sf_townships_2010)
sf_townships_2010_nodup <- dplyr::distinct(sf_townships_2010_valid,.keep_all=TRUE)
sf_townships_2010_out   <- sf::st_cast(sf_townships_2010_nodup,"MULTIPOLYGON")
sf::st_write(sf_townships_2010_out,"../output/townships_2010_epsg4326.shp",delete_dsn=TRUE)
