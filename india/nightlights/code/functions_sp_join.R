# spatial join between administrative shapefile and contour lights shapefile
sp_join <- function(contourpoly,
                    adminpoly,
                    out,
                    proj4){

  # load shapefiles
  sf_admin  <- sf::st_read(adminpoly)
  sf_light  <- sf::st_read(contourpoly)

  # set up polygons for intersection-area calculations
  sf_admin_proj <- sf::st_transform(sf_admin,proj4)
  sf_light_proj <- sf::st_transform(sf_light,proj4)

  # validate polygons
  if ( sum(sf::st_is_valid(sf_admin_proj)) != nrow(sf_admin_proj) ) {
    sf_admin_proj <- lwgeom::st_make_valid(sf_admin_proj)
  }
  if ( sum(sf::st_is_valid(sf_light_proj)) != nrow(sf_light_proj) ) {
    sf_light_proj <- lwgeom::st_make_valid(sf_light_proj)
  }

  # spatial join
  df_join <- sf::st_join(sf_admin_proj,sf_light_proj,largest=T)

  # re-project out
  base_proj <- sf::st_crs(sf_admin)$proj4string
  sf_out <- sf::st_transform(df_join,base_proj)

  # export town-MSA csv
  sf::st_write(sf_out,paste0("../output/",out,".csv"),delete_dsn=TRUE)
  # export town-MSA shapefile
  sf::st_write(sf_out,paste0("../output/",out,".shp"),delete_dsn=TRUE)

# end of function
}
