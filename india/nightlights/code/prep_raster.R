# prepare raster: crop, recode 255 (zero-cloud-free-obs) pixels to zero, project to equal distance for contour
prep_raster <- function(rasta,
                        boundary,
                        country,
                        proj4="+init=epsg:4326",
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
#end of function

# define projection
args <- commandArgs(trailingOnly=TRUE)
aeqd_proj4 <- as.character(args[1])
# prep raster
prep_raster(rasta="F152001.v4b_web.stable_lights.avg_vis",
            country="India",
            boundary=c(67,98,6,38),
            proj4=aeqd_proj4)
prep_raster(rasta="F182011.v4c_web.stable_lights.avg_vis",
            country="India",
            boundary=c(67,98,6,38),
            proj4=aeqd_proj4)
