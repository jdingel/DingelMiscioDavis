library(rgdal)
library(sp)
# re-project shapefile into WGS84
sdf_admin <- rgdal::readOGR("../input/india_sub_districts_epsg32644.shp")
sdf_out   <- sp::spTransform(sdf_admin,sp::CRS("+init=epsg:4326"))
rgdal::writeOGR(sdf_out,dsn="../output/",
                        layer="sub_districts",
                        driver='ESRI Shapefile',
                        overwrite=TRUE)
