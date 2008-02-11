blpGetData <- function(x, ...){
  UseMethod("blpGetData", x)
}

blpGetData.default <- function(x, ...){
  blpGetData.BlpCOMConnect(x, ...)
}

blpGetData.BlpCOMConnect <- function(x, securities, fields, start=NULL, end=NULL,
                                     barsize=NULL, barfields=NULL, retval=NULL, ...){
  ## x is an RDCOM object, after all..
  class(x) <- "COMIDispatch"
  ## Is call ok?
  if(is.null(securities) || is.null(fields)){
    stop("x, securities, and fields are all required parameters.")
  }
  if(!is.null(end) && is.null(start)){
    stop("You must pass a date to the start parameter.")
  }
  if(!is.null(retval[1])){
    if(!retval[1] %in% c("matrix","data.frame","zoo","raw")){
      stop("retval must be matrix, data.frame, zoo, or raw")
    }
  }
  ## Make sure all fields and securities are in upper case
  securities <- toupper(securities)
  fields <- toupper(fields)
  if(!is.null(barfields)){
    barfields <- toupper(barfields)
  }
  ## intraday-specific conditions
  if(!is.null(barsize)){
    if(barsize > 0){
      allowed <- c("OPEN", "HIGH","LOW", "LAST_PRICE","VOLUME","NUMBER_TICKS")
      if(!prod(c(barfields %in% allowed, !is.null(barfields)))){
        stop(paste("barfields must be one or more of OPEN, HIGH, LOW, LAST_PRICE, NUMBER_TICKS, or VOLUME"))
      }
    }
  }
  ## Make the underlying call to COM
  if(!is.null(start)){
    BLP <- blpGetHistoricalData(x, securities, fields, start, end,
                       barsize, barfields)
  }else{
    BLP <- blpSubscribe(x, securities, fields)
  }
  ## Coerce to desired mode
  if(is.null(retval[1])){
    if(!is.null(start)){
      retval <- "zoo"
    }else{
      retval <- "data.frame"
    }
  }
  if(retval[1] == "matrix"){
    y <- as.matrix.BlpCOMReturn(BLP)
  }else if(retval[1] == "data.frame"){
    y <- as.data.frame.BlpCOMReturn(BLP)
  }else if(retval[1] == "zoo"){
    y <- as.zoo.BlpCOMReturn(BLP)
  }else if(retval[1] == "raw"){
    y <- BLP
  }
  return(y)
}

