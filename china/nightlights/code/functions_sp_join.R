# spatial join between administrative shapefile and polygonized lights shapefile
sp_join <- function(contourpoly,
                    adminpoly,
                    out,
                    proj4="+init=epsg:4326",
                    sf=TRUE) {

  if (sf==TRUE) {

  # sf methods

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

  # end of sf methods
  } else {

  # sp methods

    # load shapefiles
    sdf_admin <- rgdal::readOGR(adminpoly)
    sdf_light <- rgdal::readOGR(contourpoly)
    
    # prepare the export data frame with ID
    df_out <- dplyr::mutate(sdf_admin@data,id=as.numeric(rownames(sdf_admin@data))+1)

    # set up polygons for intersection-area calculations
    china_equal_area <- sp::CRS(proj4)
    sdf_admin_proj <- sp::spTransform(sdf_admin,china_equal_area)
    sdf_light_proj <- sp::spTransform(sdf_light,china_equal_area)
    # trick to tighten up the boundaries
    if (rgeos::gIsValid(sdf_admin_proj)!=TRUE) {
      sdf_admin_proj <- rgeos::gBuffer(sdf_admin_proj,byid=T,width=0)
    }
    if (rgeos::gIsValid(sdf_light_proj)!=TRUE) {
      sdf_light_proj <- rgeos::gBuffer(sdf_light_proj,byid=T,width=0)
    }

    # spatial join
    # returnList=TRUE returns a "list" of all intersections by admin id
    # minDim=2 returns matches with overlap area only
    list_join <- rgeos::overGeomGeom(sdf_admin_proj,
                                     sdf_light_proj,
                                     returnList=TRUE,
                                     minDimension=2)

    # write the list to output
    lapply(list_join,write,paste0("../output/",out,".txt"),append=TRUE,ncolumns=1000)

    # replace edge cases according to largest overlap
    ntl_id <- vector() # fill vector with matches
    for (i in 1:length(list_join)) {
      match_count    <- length(list_join[[i]])
      unique_matches <- length(unique(list_join[[i]]))
      if (match_count==0) {
        ntl_id[i] <- NA # return NA value for units with no match
      }
      if (match_count==1) {
        ntl_id[i] <- list_join[[i]][[1]] # return first match if single match
      }
      if (match_count>1) {
        areas <- numeric(unique_matches) # set up numeric vector of length matches
        for (j in 1:unique_matches) {
          light_id <- as.numeric(unique(list_join[[i]])[[j]]) # unique list of polygon IDs
          areas[j] <- rgeos::gArea(rgeos::gIntersection(      # area of intersection between
                        sdf_admin_proj[i,],                   # administrative unit boundary and
                        sdf_light_proj[light_id,]             # matching light polygon boundaries
                      ))
        }
        ntl_id[i] <- list_join[[i]][[which(areas==max(areas))]] # return unique max
      }
    }

    # export town-MSA csv
    df_out  <- cbind(df_out, ntl_id)
    data.table::fwrite(df_out,file=paste0("../output/",out,".csv"),append=FALSE,quote="auto")

    # export town-MSA shapefile
    sdf_out <- sdf_admin
    sdf_out@data <- cbind(sdf_out@data,ntl_id)
    rgdal::writeOGR(sdf_out,dsn="../output/",layer=out,driver='ESRI Shapefile',overwrite=TRUE)

  # end of sp methods
  }
# end of function
}
