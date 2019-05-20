# prepare raster: crop, recode 255 (zero-cloud-free-obs) pixels to zero, project to equal distance for contour
prep_raster <- function(rasta,
                        boundary,
                        proj4="+init=epsg:4326",
                        country,
                        histo=FALSE) {

  raw   <- raster::raster(paste0("../input/",rasta,".tif"))
  crop  <- raster::crop(raw,boundary)
  topcode <- raster::reclassify(crop,cbind(255,Inf,0),right=TRUE)
  project <- raster::projectRaster(from=topcode,
                                   crs=proj4,
                                   method="ngb")

  raster::writeRaster(project,paste0("../output/",rasta,"_",country,".tif"),overwrite=T)

  if (histo==TRUE){
    pdf(paste0("../output/histogram_",rasta,"_",country,".pdf"))
    raster::hist(project,
                 maxpixels=1e5,
                 main="Density of 100k pixels",
                 xlab="Pixel value",
                 ylab="Number of pixels")
    dev.off()
  }
}

# retrieve proj4string
args <- commandArgs(trailingOnly=TRUE)
aeqd_proj4 <- as.character(args[1])

# call function
prep_raster(rasta="F152000.v4b_web.stable_lights.avg_vis",
            proj4=aeqd_proj4,
            country="China",
            boundary=c(69,140,15,58))
prep_raster(rasta="F182010.v4d_web.stable_lights.avg_vis",
            proj4=aeqd_proj4,
            country="China",
            boundary=c(69,140,15,58))
