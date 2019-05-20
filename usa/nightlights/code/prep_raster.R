# prepare raster: crop, recode 255 (zero-cloud-free-obs) pixels to zero, project to equal distance for contour
prep_raster <- function(rasta,
                        boundary,
                        proj4="+init=epsg:4326",
                        country,
                        histo=FALSE) {

  # read in raster
  raw   <- raster::raster(paste0("../input/",rasta,".tif"))
  # crop to bounds
  crop  <- raster::crop(raw,boundary)
  # recode pixels with 255 (with zero cloud-free observations) to 0
  topcode <- raster::reclassify(crop,cbind(255,Inf,0),right=TRUE)

  # optional histogram of raster to see data before scaling/projection
  if (histo==TRUE){
    pdf(paste0("../output/histogram_",rasta,"_",country,".pdf"))
    raster::hist(topcode,
                 maxpixels=1e5,
                 main="Density of 100k pixels",
                 xlab="Pixel value",
                 ylab="Number of pixels")
    dev.off()
  }
  # write cropped and re-coded raster for use later
  raster::writeRaster(topcode,paste0("../output/",rasta,"_",country,"_unscaled_unprojected.tif"),overwrite=T)

  # multiply raster values by 10 for gdal_contour
  tens <- topcode*10  #Necessary to address a bug in gdal_contour function in GDAL versions prior to 2.4.
  # project the raster
  project <- raster::projectRaster(from=tens,
                                   crs=proj4,
                                   method='ngb')

  raster::writeRaster(project,paste0("../output/",rasta,"_",country,".tif"),overwrite=T)

}

# retrieve proj4string
args <- commandArgs(trailingOnly=TRUE)
continental_eqdc_proj4 <- as.character(args[1])
alaska_aeqd_proj4      <- as.character(args[2])
hawaii_aeqd_proj4      <- as.character(args[3])

# call function
prep_raster(rasta="F182010.v4d_web.stable_lights.avg_vis",
            proj4=continental_eqdc_proj4,
            country="continental",
            boundary=c(-129,-62,20,50)) #Continental US
prep_raster(rasta="F182010.v4d_web.stable_lights.avg_vis",
            proj4=alaska_aeqd_proj4,
            country="alaska",
            boundary=c(-180,-129,50,72)) #Alaska
prep_raster(rasta="F182010.v4d_web.stable_lights.avg_vis",
            proj4=hawaii_aeqd_proj4,
            country="hawaii",
            boundary=c(-179,-153,8,30)) #Hawaii
