# write municipios file with no islands and z-layer for use
library(sf)
library(sp)
library(rgdal)
sf_admin      <- sf::st_read("../input/all_Municipios_epsg4326.shp")
sf_noz_admin  <- sf::st_zm(sf_admin,drop=T)
sdf_out       <- as(sf_noz_admin,"Spatial")
  # drop islands: Lagoa Dos Patos + Lagoa Mirim
sdf_municipios_2010  <- sdf_out[(which(!(sdf_out@data$CD_GEOCODM %in% c(4300001,4300002)))), ]
rgdal::writeOGR(sdf_municipios_2010,dsn="../output/",
                                    layer="municipios_2010",
                                    driver='ESRI Shapefile',
                                    overwrite=TRUE)
