# draw contour or polygon lines from clipped/clumped raster
contour_lines <- function(rasta,
                          thresh=30,
                          shapeout,
                          proj4="+init=epsg:4326") {

  system(paste0("rm -r ../output/",shapeout,"*"))

  # create contour lines (SpatialLines) file; read back in
  gdalUtils::gdal_contour(src_filename=paste0("../output/",rasta,".tif"),
                          dst_filename=paste0("../output/",shapeout,"_lines.shp"),
                          fl=as.character(thresh),
                          verbose=T)

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

  ### dissolve holes
  # if polygons are few, this will run fairly quickly
  if (length(sdf_polygon) < 2e3){

    check_dissolve <- function(shp) {
      sapply(1:(length(shp)),function(i)sum(rgeos::gWithin(shp[i,],shp[-i,],byid=T)))
    }

    sdf_polygon_set <- check_dissolve(sdf_polygon)
    sdf_polygon_dissolved <- sdf_polygon[which(sdf_polygon_set==0),]

  # otherwise, we are best to use partitions to spatially index polygons
  } else {

    # set up parameters
    n_parts <- 4                                            # number of partitions
    raster_bbox  <- raster::extent(sdf_polygon)              # full bounding box
    x_width  <- (raster_bbox[2]-raster_bbox[1])/n_parts       # moving window

    # moving window for partitions
    for (i in 1:n_parts){
      assign(
        paste("box",i,sep="_"),
        as(raster::extent(max(raster_bbox[2]-(n_parts-i+1)*x_width,raster_bbox[1]),
                          min(raster_bbox[2]-(n_parts-i)*x_width,raster_bbox[2]),
                          raster_bbox[3],
                          raster_bbox[4]),"SpatialLines")
      )
    }

    # assign projections to windows
    og_proj <- sp::CRS(sp::proj4string(sdf_polygon))
    sp::proj4string(box_1) <- og_proj
    sp::proj4string(box_2) <- og_proj
    sp::proj4string(box_3) <- og_proj
    sp::proj4string(box_4) <- og_proj

    # this will tighten up any self-intersections if they exist
    while (rgeos::gIsValid(sdf_polygon)!=TRUE) {
      sdf_polygon <- rgeos::gBuffer(sdf_polygon,byid=T,width=0)
    }

    for (i in 1:n_parts){
      assign(
        paste("part",i,sep="_"),
        raster::crop(sdf_polygon,eval(parse(text=paste("box",i,sep="_"))))
      )
    }

    # create N partitions + leftover where result_N includes N partition's leftovers
    for (i in 1:n_parts){
      assign(
        paste("result",i,sep="_"),
        eval(parse(text=paste("part",i,sep="_")))
      )
    }
    leftover <- rbind(part_1[which(rgeos::gIntersects(box_1,part_1,byid=T)), ],
                      part_2[which(rgeos::gIntersects(box_2,part_2,byid=T)), ],
                      part_3[which(rgeos::gIntersects(box_3,part_3,byid=T)), ],
                      part_4[which(rgeos::gIntersects(box_4,part_4,byid=T)), ])

    # call functions
    check_for_holes <- function(shp){
      sapply(1:(length(shp)),function(i)
        sum(rgeos::gWithin(shp[i,],shp[-i,],byid=T))
      )
    }
    check_for_holes2 <- function(shp1,shp2){
      sapply(1:(length(shp)),
        function(i)j_i <- shp1[i,]@data$ntl_id,
        function(i)sum(rgeos::gWithin(shp1[i,],shp2[-(j_i),],byid=T)),
      )
    }

    for (i in 1:n_parts) {
      assign(paste0("sdf_hole_set",i),check_for_holes(eval(parse(text=paste("result",i,sep="_")))))
    }
    sdf_hole_left <- check_for_holes(leftover)

    keep_ids <- rbind(result_1[which(sdf_hole_set1==0),]@data,
                      result_2[which(sdf_hole_set2==0),]@data,
                      result_3[which(sdf_hole_set3==0),]@data,
                      result_4[which(sdf_hole_set4==0),]@data,
                      leftover[which(sdf_hole_left==0),]@data)

    sdf_polygon_dissolved <- sdf_polygon[ sdf_polygon@data$ntl_id %in% unique(keep_ids$ntl_id) ,]

  }

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
