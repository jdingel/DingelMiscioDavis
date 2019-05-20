
data_join <- function(infile,
                      id,     # key
                      threshes=seq(10,60,10),
                      join=T,
                      outfile){

  for (i in threshes){
    # read files in df_10 df_20 ...
    assign(
      paste("df",i,sep="_"),
      data.table::fread(input=paste0("../output/",infile,i,".csv")) #drop=c("id")
    )
    if (join==T) {
      data.table::setnames(eval(parse(text=paste0("df_",i))),"ntl_id",paste0("ntl_",i)) # rename metro ID
    } else {
      data.table::setnames(eval(parse(text=paste0("df_",i))),"ntl_id","polygon_id") # satisfy counties/townships loaddata
      data.table::fwrite(eval(parse(text=paste0("df_",i))),file=paste0("../output/",outfile,i,".csv"),append=F,quote="auto")
    }
  }

  if (join==T) {
    df <- eval(parse(text=paste0("df_",threshes[1])))
    for (j in seq(threshes[2],threshes[length(threshes)],10)){
      df <- dplyr::left_join(df,dplyr::select(eval(parse(text=paste0("df_",j))),paste0("ntl_",j),id),by=id)
    }
    data.table::fwrite(df,file=paste0("../output/",outfile,".csv"),append=F,quote="auto")
  }


}
