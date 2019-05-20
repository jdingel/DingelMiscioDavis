# prepare raster: crop, recode 255 (zero-cloud-free-obs) pixels to zero, project to equal distance for contour
prep_raster <- function(rasta,
                        boundary, # (x_min,x_max,y_min,y_max)
                        proj4,
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

# define projection
args <- commandArgs(trailingOnly=TRUE)
aeqd_proj4 <- as.character(args[1])

# call function
prep_raster(rasta="F182010.v4d_web.stable_lights.avg_vis",
            country="Brazil",
            boundary=c(-75,-31,-35,7), # Brazil
            proj4=aeqd_proj4)
