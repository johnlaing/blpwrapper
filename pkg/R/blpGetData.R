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
   
   if (!is.null(retval)) {
      allowed <- c("matrix","data.frame","zoo","raw")
      stopmsg <- paste("retval must be one of ", paste(allowed, collapse=", "))
     if (!retval %in% allowed) {
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
   
   securities <- toupper(securities)
   fields <- toupper(fields)
   if (!is.null(barfields)) {
     barfields <- toupper(barfields)
   }
   
   fn.name <- paste("blp", class(conn), sep=".")
   fn.call <- call(fn.name, conn, securities, fields, start, end, barsize, barfields, retval, override_fields, overrides, currency)
   lst <- eval(fn.call)
   
   class(lst) <- "BlpRawReturn"
   attr(lst, "securities") <- securities
   attr(lst, "fields") <- fields
   attr(lst, "override_fields") <- override_fields
   attr(lst, "overrides") <- overrides
   
   # If not specified, default to a data frame, or zoo for time series.
   if (is.null(retval)) {
      if (!is.null(start)) {
       retval <- "zoo"
     } else {
       retval <- "data.frame"
     }
   }
   
   return(convert.to.retval(lst, retval))
}

blp.JavaObject <- function(conn, securities, fields, start, end, barsize, barfields, 
      retval, override_fields, overrides, currency) {

  request <- prepare_request(conn$service, securities, fields)
  submit_request(conn$session, request)

  read_events_stream_to_string(conn$session)
}

blp.COMObject <- function(conn, securities, fields, start, end, barsize, barfields, 
      retval, override_fields, overrides, currency) {
         
  if (!is.null(start)) {
    blpGetHistoricalData(conn, securities, fields, start, end, barsize, barfields, currency)
  } else {
    blpSubscribe(conn, securities, fields, override_fields, overrides)
  }
}

convert.to.retval <- function(x, retval) {
   fn.name <- paste("as", retval, class(x), sep =".") 
   eval(call(fn.name, x))
}

as.raw.BlpRawReturn <- function(x) {
   return(x)
}
