blpGetData <- function(x, ...) {
  cat("blpGetData is deprecated, please update your code to call blp() instead. blpGetData will be removed in an upcoming version of RBloomberg.\n")
  blp(x, ...)
}

### @export "blp-definition"
blp <- function(conn, securities, fields, start=NULL, end=NULL,
                                barsize=NULL, barfields=NULL, retval=NULL, 
                                override_fields = NULL, overrides = NULL, currency = NULL) {
### @end

   if (is.null(conn) || is.null(securities) || is.null(fields)) {
     stop("conn, securities, and fields are all required parameters.")
   }
   
   if (!is.null(end) && is.null(start)) {
     stop("You must pass a date to the start parameter.")
   }
   
   # TODO clarify whether there are multiple retvals allowed and clean up
   if (!is.null(retval[1])) {
      allowed <- c("matrix","data.frame","zoo","raw")
      stopmsg <- paste("retval must be one of ", paste(allowed, collapse=", "))
     if (!retval[1] %in% allowed) {
       stop(stopmsg)
     }
   }
   
   if (!is.null(barsize)) {
     if (barsize > 0) {
        allowed <- c("OPEN", "HIGH","LOW", "LAST_PRICE","VOLUME","NUMBER_TICKS")
        stopmsg <- paste("barfields must be one or more of ", paste(allowed, collapse=", "))
        # TODO replace with !is.null(barfields) & all(barfields %in% allowed) ?
        if (!prod(c(barfields %in% allowed, !is.null(barfields)))) {
         stop(stopmsg)
       }
     }
   }
   
   UseMethod("blp", conn)
}

blp.default <- function(x, ...) {
  stop(paste("no blp method found for class", class(x)))
}

# Must leave NULL defaults in these function definitions or else the local
# variables are undefined.
blp.JavaObject <- function(conn, securities, fields, start=NULL, end=NULL, barsize=NULL, barfields=NULL, 
      retval=NULL, override_fields=NULL, overrides=NULL, currency=NULL) {

  request <- prepare_request(conn$service, securities, fields)
  submit_request(conn$session, request)

  read_events_stream_to_string(conn$session)
}

blp.COMObject <- function(conn, securities, fields, start=NULL, end=NULL, barsize=NULL, barfields=NULL, 
      retval=NULL, override_fields=NULL, overrides=NULL, currency=NULL) {

   # Changing these does not persist, so have to put them here for now instead of blp() why?
   securities <- toupper(securities)
   fields <- toupper(fields)
   if(!is.null(barfields)){
     barfields <- toupper(barfields)
   }
   
   
  if(!is.null(start)){
    BLP <- blpGetHistoricalData(conn, securities, fields, start, end,
                       barsize, barfields, currency)
  }else{
    BLP <- blpSubscribe(conn, securities, fields, override_fields, overrides)
  }
  
  # If not specified, default to a data frame, or zoo for time series.
  if (is.null(retval[1])) {
    if (!is.null(start)) {
      retval <- "zoo"
    } else {
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

