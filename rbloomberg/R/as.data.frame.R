# as.data.frame converts each column into the appropriate data type.
# By contrast, as.matrix converts all non-date columns to numeric values.
# as.data.frame does not support 3D data since data frames are 2D.
as.data.frame.BlpRawReturn <- function(x, row.names = NULL, optional =
                                       FALSE, ...){
  bbfields <- .bbfields
  lst <- list()
  mtx <- as.matrix.BlpRawReturn(x)
  
  cols <- colnames(mtx)
  flds <- attr(x, "fields")
  secs <- attr(x, "securities")
  blds <- attr(x, "barfields")
  ndat <- attr(x, "num.of.date.cols")
  
  # Nasty 6pm Friday hack to change num.of.date.cols to 0 if we have a single
  # historical date. Otherwise 1st data column is converted to a date which
  # we don't want.
  if (!is.null(attr(x, "end")) && (attr(x, "end") == attr(x, "start"))) {
    ndat <- 0
  }
  
  ## convert all other columns to appropriate datatype
  if(!is.null(blds)){
    fields <- blds
  }else{
    fields <- flds
  }
  typ <- dataType(fields, bbfields)
  for(n in seq(1, ncol(mtx))){
    vec <- mtx[,n]
    if(typ[n] == "character"){
      lst <- append(lst, list(as.character(vec)))
    }else if(typ[n] == "double"){
      lst <- append(lst, list(as.numeric(vec)))
    }else if(typ[n] == "logical"){
      lst <- append(lst, list(as.logical(vec)))
    }else if(typ[n] == "datetime"){
      lst <- append(lst, list(timeDate(vec)))
    }
  }
  if(ndat != 0){
    df <- as.data.frame.list(lst)
    colnames(df) <- cols
  }else{
    df <- as.data.frame.list(lst)
    colnames(df) <- flds
    rownames(df) <- secs
  }
  return(df)
}
