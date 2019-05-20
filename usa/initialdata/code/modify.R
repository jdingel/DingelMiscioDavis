# Load libraries
library(sf)
library(dplyr)
# write shapefiles for contiguous and island states
sf_us <- sf::st_read("../output/tl_2010_us_county10.shp")
sf_continental <- sf_us[ -( which(sf_us$STATEFP10 %in% c("02","15","72")) ) ,	] # Drop AK,HI,PR
sf_alaska 		 <- sf_us[    which(sf_us$STATEFP10 %in%   "02"),	   ]            # select AK
sf_hawaii 		 <- sf_us[    which(sf_us$STATEFP10 %in%   "15"),	   ]            # select HI
# write
sf::st_write(sf_us,"../output/tl_2010_us_county10.csv",delete_dsn=TRUE)         # write counties normfile
sf::st_write(sf_continental,"../output/tl_2010_us_county10_continental_US.shp",delete_dsn=TRUE)
sf::st_write(sf_alaska,"../output/tl_2010_us_county10_alaska.shp",delete_dsn=TRUE)
sf::st_write(sf_hawaii,"../output/tl_2010_us_county10_hawaii.shp",delete_dsn=TRUE)
