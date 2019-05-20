## Area calculation
geo_calc <- function(shapefile,
                     outfile,
                     year,
                     geounit,
                     proj4,
                     details=TRUE) {

  sf_admin      <- sf::st_read(shapefile)

  # write data
  sf_noz_admin  <- sf::st_zm(sf_admin,drop=T)
  sdf_out       <- as(sf_noz_admin,"Spatial")

  # project
  sf_admin_proj <- sf::st_transform(sf_admin,proj4)

  # calculate area_km2
  area_km2 <- vector()
  for (i in 1:length(sdf_out)){
    area_km2[i] <- units::set_units(sf::st_area(sf_admin_proj[i,]),km2)
  }
  sdf_out@data <- cbind(sdf_out@data,area_km2)

  sink(paste0("../output/",outfile,".tex"),append=FALSE)
  cat(paste0("In year ",year," definitions, the median ",geounit," had a land area of ",
              format(round(median(sdf_out@data$area_km2),digits=0),nsmall=0,big.mark=","),
              " km$^2$."
       ))
  sink()

  # attach centroids
  sdf_out@data$centroid <- geosphere::centroid(sdf_out)
  df_out <- sdf_out@data
  df_out$lon <- df_out$centroid[,1]
  df_out$lat <- df_out$centroid[,2]
  df_out <- dplyr::select(df_out,-centroid)

  # write
  data.table::fwrite(df_out,file=paste0("../output/",outfile,".csv"),append=FALSE,quote="auto")

  if (details==T) {

    details <- quantile(sdf_out@data$area_km2,probs=seq(0.05,0.95,0.45),na.rm=TRUE)

    sink(paste0("../output/",outfile,"_details.tex"),append=FALSE)
    cat(paste0("In year ",year," definitions, the 5$^{\\text{th}}$, 50$^{\\text{th}}$, and 95$^{\\text{th}}$ percentiles of ",geounit," land area were ",
                format(round(details[1],digits=0),nsmall=0,big.mark=","),", ",
                format(round(details[2],digits=0),nsmall=0,big.mark=","),", and ",
                format(round(details[3],digits=0),nsmall=0,big.mark=",")," km$^2$, respectively."
         ))
    sink()

  }

}
