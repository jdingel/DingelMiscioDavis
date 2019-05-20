# draw contour lines from prepped raster
contour_lines <- function(rasta,
                          thresh=30,
                          shapeout,
                          proj4) {

  system(paste0("rm -r ../output/",shapeout,"*"))

  # create contour lines (SpatialLines) file; read back in
  gdalUtils::gdal_contour(src_filename=paste0("../output/",rasta,".tif"),
                          dst_filename=paste0("../output/",shapeout,"_lines.shp"),
                          fl=thresh)

  # SpatialLines -> SpatialPolygons
  sl_contour <- rgdal::readOGR(paste0("../output/",shapeout,"_lines.shp"))
  ps_contour <- maptools::SpatialLines2PolySet(sl_contour)
  sp_polygon <- maptools::PolySet2SpatialPolygons(ps_contour,close_polys=T)

  # set up vector IDs
  library(dplyr)
  df <- vector()
  for (i in 1:length(sp_polygon)) {
    df[i] <- i
  }
  df <- as.matrix(df) %>% data.frame()
  names(df) <- "ntl_id"

  # attach to SpatialPolygonsDataFrame
  sdf_polygon <- sp::SpatialPolygonsDataFrame(sp_polygon,data=as.data.frame(df))

  # re-assign projection
  if ( is.na(sp::proj4string(sp_polygon)) ) {
    sp::proj4string(sdf_polygon) <- sp::CRS(proj4)
  }

  # dissolve hole polygons
  check_dissolve <- function(shp){
    sapply(1:(length(shp)),function(i)sum(rgeos::gWithin(sdf_polygon[i,],sdf_polygon[-i,],byid=T)))
  }
  sdf_polygon_set <- check_dissolve(sdf_polygon)
  sdf_polygon_dissolved <- sdf_polygon[which(sdf_polygon_set==0),]

  print(paste0(
    length(sl_contour)," contour lines drawn. ",
    length(sdf_polygon)," polygons formed. ",
    length(sdf_polygon)-length(sdf_polygon_dissolved)," holes found. ",
    length(sdf_polygon_dissolved)," connected spaces produced."
  ))

  # write output
  rgdal::writeOGR(sdf_polygon_dissolved,
                  dsn="../output/",
                  layer=shapeout,
                  driver='ESRI Shapefile',
                  overwrite=TRUE)


# end of function
}
