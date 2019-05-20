
data_join <- function(infile,
                      id,
                      threshes=seq(30,62,by=2),
                      join=T,
                      outfile){

  count <- 0
  for (i in threshes){

    count <- count+1

    # read files in df_30 df_32 ... for each region
    for (geo in c("continental","alaska","hawaii")) {
      assign(
        paste("df",geo,i,sep="_"), # e.g. df_continental_30
        data.table::fread(input=paste0("../output/",infile,geo,"_NTL",i,".csv"))
      )
    }

    # concatenate lower 48 and AK/HI
    df_us <- eval(parse(text=paste0("df_continental_",i)))
    library(dplyr)
    # to ensure arbitrary light polygon IDs do not overlap across areas, use addition
    # AK
    ntl_max   <- max(df_us$ntl_id,na.rm=T) + 1 # add 1 because polygon ID might be 0
    df_alaska <- eval(parse(text=paste0("df_alaska_",i))) %>% dplyr::mutate(ntl_id = ntl_id + ntl_max)
    df_us     <- rbind(df_us, df_alaska)
    # HI
    ntl_max   <- max(df_us$ntl_id,na.rm=T) + 1
    df_hawaii <- eval(parse(text=paste0("df_hawaii_",i))) %>% dplyr::mutate(ntl_id = ntl_id + ntl_max)
    df_us     <- rbind(df_us, df_hawaii)

    # rename metro ID
    data.table::setnames(df_us,"ntl_id",paste0("msa_night_",i))
    # write output
    data.table::fwrite(df_us,file=paste0("../output/",outfile,i,".csv"),append=F,quote="auto")

    # write final table with all thresholds
    if (join==T) {
      if (count==1) {
        df_out <- df_us
      } else {
        df_out <- dplyr::left_join(df_out,dplyr::select(df_us,paste0("msa_night_",i),id),by=id)
      }
    }
  }
  data.table::fwrite(df_out,file="../output/US_county_2010_nightlights.csv",append=F,quote="auto")
}



## Figure 1

# Panel A: map two raw input files together
map_raw_raster <- function(rasterfile,
                           shapefile,
                           image_out,
                           proj4="+init=epsg:4326",
                           scheme=inferno(9),
                           lcol="black",
                           lwidth=0.8,
                           breakvals=c(0,1,10,20,30,40,50,60,63),
                           mask=TRUE,
                           zoom=TRUE,
                           zoom_box){

  df_raster <- raster::raster(rasterfile)
  sdf_shape <- rgdal::readOGR(shapefile)
  # project shapefile
  sdf_shape <- sp::spTransform(sdf_shape,sp::CRS(proj4))
  if (rgeos::gIsValid(sdf_shape)!=TRUE) {
    sdf_shape <- rgeos::gBuffer(sdf_shape,byid=T,width=0)
  }
  # project raster
  df_raster <- raster::projectRaster(from=df_raster,
                                     crs=proj4,
                                     method="ngb")

  # project bounding box in equal area
  if (proj4!="+init=epsg:4326") {
    d=data.frame(lon=c(zoom_box[1],zoom_box[2]),lat=c(zoom_box[3],zoom_box[4]))
    sp::coordinates(d) <- c("lon","lat")
    sp::proj4string(d) <- sp::CRS("+init=epsg:4326")
    zoom_box <- sp::spTransform(d,sp::CRS(proj4))
  }

  if (zoom==FALSE) {
    boundary <- raster::extent(sdf_shape)
  } else {
    boundary <- zoom_box
  }

  #raster data manipulation
  df_raster <- raster::crop(df_raster,boundary)
  sdf_shape <- raster::crop(sdf_shape,boundary)
  if (mask==TRUE) df_plot <- raster::mask(x=df_raster,mask=sdf_shape) #maskvalue=0

  # plot
  png(paste0("../output/",image_out,".png"))
  par(mar=c(0,0,0,1),oma=c(0,0,0,0),mgp=c(0,0,0))

  raster::plot(sdf_shape,border="black",lwd=0.8)
  raster::plot(df_plot,legend.width=1,alpha=0.85,
              breaks=breakvals,
              axis.args=list(at=seq(0,60,10),
                         labels=c("0","10","20","30","40","50","60+")),
              col=scheme,
              axes=F,ylab=NA,xlab=NA,add=TRUE,
              xaxs="i",yaxs="i")
  dev.off()
}


# Panel B: display light polygons bleeding through administrative shapefile
map_light_shp <- function(admin_shapefile,
                          light_shapefile,
                          image_out,
                          proj4="+init=epsg:4326",
                          bubble_fill="Red",
                          bubble_border="Green",
                          zoom=TRUE,
                          scale_loc,
                          zoom_box){

  sdf_admin <- rgdal::readOGR(admin_shapefile)
  sdf_light <- rgdal::readOGR(light_shapefile)

  # project shapefiles
  sdf_admin <- sp::spTransform(sdf_admin,sp::CRS(proj4))
  sdf_light <- sp::spTransform(sdf_light,sp::CRS(proj4))
  if (rgeos::gIsValid(sdf_admin)!=TRUE) {
    sdf_admin <- rgeos::gBuffer(sdf_admin,byid=T,width=0)
  }
  if (rgeos::gIsValid(sdf_light)!=TRUE) {
    sdf_light <- rgeos::gBuffer(sdf_light,byid=T,width=0)
  }

  if (proj4!="+init=epsg:4326") {

    if (zoom==T) {
      # project bounding box in equal area
      d=data.frame(lon=c(zoom_box[1],zoom_box[2]),lat=c(zoom_box[3],zoom_box[4]))
      sp::coordinates(d) <- c("lon","lat")
      sp::proj4string(d) <- sp::CRS("+init=epsg:4326")
      zoom_box <- sp::spTransform(d,sp::CRS(proj4))
    }
    # project scale location into equal area
    s=data.frame(lon=c(scale_loc[1]),lat=c(scale_loc[2]))
    sp::coordinates(s) <- c("lon","lat")
    sp::proj4string(s) <- sp::CRS("+init=epsg:4326")
    scale_loc <- sp::spTransform(s,sp::CRS(proj4))
  }

  if (zoom==FALSE) {
    boundary <- raster::extent(sdf_admin)
  } else {
    boundary <- zoom_box
  }

  sdf_admin <- raster::crop(sdf_admin,boundary)
  sdf_light <- raster::crop(sdf_light,boundary)

  png(paste0("../output/",image_out,".png"))
  #par(mar=c(1,1,1,1),oma=c(0.25,0,0.25,0),pty="s")

  raster::plot(sdf_admin,col="bisque",border="black",lwd=0.5,xaxs="i",yaxs="i",bg="lightblue") #xlim=c(boundary@coords[1],boundary@coords[2]),ylim=c(boundary@coords[3],boundary@coords[4]))
  raster::plot(sdf_light,col=adjustcolor(c(bubble_fill),alpha.f=0.4),border=bubble_border,lwd=0.5,add=TRUE)
  if (proj4=="+init=epsg:4326") {
    # lat/long
    maps::map.scale(x=scale_loc[1],
                    y=scale_loc[2],
                    ratio=FALSE,
                    relwidth=0.2)
  } else {
    # projected coordinates
    GISTools::map.scale(xc=scale_loc@coords[1],
                        yc=scale_loc@coords[2],
                        len=10e4,
                        ndivs=2,
                        subdiv=50,
                        units="km")
  }
  dev.off()
}


# Panel C: chloropleth map of metro ID
map_metros <- function(metro_shapefile,
                       image_out,
                       proj4="+init=epsg:4326",
                       zoom=TRUE,
                       zoom_box){

  sdf_metro <- rgdal::readOGR(metro_shapefile)
  # project admin shapefile
  sdf_metro <- sp::spTransform(sdf_metro,sp::CRS(proj4))
  if (rgeos::gIsValid(sdf_metro)!=TRUE) {
    sdf_metro <- rgeos::gBuffer(sdf_metro,byid=T,width=0)
  }

  # project bounding box in equal area
  if (proj4!="+init=epsg:4326") {
    d=data.frame(lon=c(zoom_box[1],zoom_box[2]),lat=c(zoom_box[3],zoom_box[4]))
    sp::coordinates(d) <- c("lon","lat")
    sp::proj4string(d) <- sp::CRS("+init=epsg:4326")
    zoom_box <- sp::spTransform(d,sp::CRS(proj4))
  }

  if (zoom==FALSE) {
    boundary <- raster::extent(sdf_metro)
  } else {
    boundary <- zoom_box
  }

  sdf_plot <- raster::crop(sdf_metro,boundary)

  png(paste0("../output/",image_out,".png"))
  par(mar=c(1,1,1,1),oma=c(0.25,0,0.25,0),mgp=c(0,0,0))

  # dissolve administrative units into metropolitan areas
  sdf_plot_dissolved <- rgeos::gUnaryUnion(sdf_plot,sdf_plot@data$ntl_id)
  # build coloring for metropolitan areas
  if ("try-error" %in% class(try(
      color_vector <- MapColoring::getOptimalContrast(x=sdf_plot_dissolved,col=c("#FF0000","#F2AD00","#00A08A","#9986A5"))
  ))){color_vector <- "red"}

  raster::plot(sdf_plot_dissolved,
               col=color_vector,
               border="black",
               lwd=0.8,xaxs="i",yaxs="i") # metro polygons
  raster::lines(sdf_plot,col="black",lwd=0.4) # administrative borders

  dev.off()
}
