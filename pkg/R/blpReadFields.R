blpReadFields <- function(path = "C:/blp/API"){
  path <- paste(path, "/bbfields.tbl", sep="")
  cnames <- c("category","category.name","subcategory","subcategory.name",
          "field.id","field.name","field.mnemonic","mkt.bitmask",
          "data.bitmask","data.type")
  df <- try(read.table(path, sep="|", col.names=cnames,
                       fill=TRUE, as.is=TRUE, quote=""), 
                       silent=TRUE)
  if(!class(df)=="try-error"){
    return(df)
  }else{
    return(NULL)
  }
}
