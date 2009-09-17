blpGetData <- function(x, ...) {
  cat("blpGetData is deprecated, please update your code to call blp() instead. blpGetData will be removed in an upcoming version of RBloomberg.\n")
  blp(x, ...)
}

### @export "blp-definition"
blp <- function(conn, securities, fields, start = NULL, end = NULL,
                                barsize = NULL, barfields = NULL, retval = NULL, 
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
        if (length(securities) > 1) {
           stop("Bar data can only be requested for one security at a time.")
        }
        
        allowed <- c("OPEN", "HIGH","LOW", "LAST_PRICE","VOLUME","NUMBER_TICKS")
        allowed_barfields_msg <- paste("barfields must be one or more of ", paste(allowed, collapse=", "))
        
        if (is.null(barfields) || !all(barfields %in% allowed)) {
         stop(allowed_barfields_msg)
       }
     }
   }
   
   securities <- toupper(securities)
   fields <- toupper(fields)

   if (!is.null(barfields)) {
     barfields <- toupper(barfields)
   }

   if (!is.null(start)) {
     start <- timeDate(start)
   }

   if (!is.null(end)) {
     end <- timeDate(end)
   }
   
   fn.name <- paste("blp", class(conn), sep=".")
   fn.call <- call(fn.name, conn, securities, fields, start, end, barsize, barfields, retval, override_fields, overrides, currency)
   lst <- eval(fn.call)
   
   # Everything comes back in the same format, BlpRawReturn, regardless of how it's obtained.
   class(lst) <- "BlpRawReturn"
   attr(lst, "securities") <- securities
   attr(lst, "fields") <- fields
   attr(lst, "override_fields") <- override_fields
   attr(lst, "overrides") <- overrides
   
   if (is.null(attr(lst, "num.of.date.cols"))) {
      attr(lst, "num.of.date.cols") <- 0
   }
   
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

convert.to.retval <- function(x, retval) {
   fn.name <- paste("as", retval, class(x), sep =".") 
   eval(call(fn.name, x))
}

as.raw.BlpRawReturn <- function(x) {
   return(x)
}

# blp methods for individual classes called by blp()
blp.JavaObject <- function(conn, securities, fields, start, end, barsize, barfields, 
      retval, override_fields, overrides, currency) {

  if (!is.null(override_fields)) {
     stop("overrides not implemented!")
  }
  
  request <- prepare_request(conn$service, securities, fields, start, end)
  submit_request(conn$session, request)

  lst <- process_event(conn$session, "RESPONSE")
  if (!is.null(start)) attr(list, "num.of.date.cols") <- 1
  return(lst)
}

# These are identical. Handling is done in blpSubscribe and blpGetHistoricalData.
blp.COMIDispatch <- function(conn, securities, fields, start, end, barsize, barfields, 
      retval, override_fields, overrides, currency) {
         
  if (!is.null(start)) {
    comGetHistoricalData(conn, securities, fields, start, end, barsize, barfields, currency)
  } else {
    comSubscribe(conn, securities, fields, override_fields, overrides)
  }
}

blp.COMObject <- function(conn, securities, fields, start, end, barsize, barfields, 
      retval, override_fields, overrides, currency) {
         
  if (!is.null(start)) {
    comGetHistoricalData(conn, securities, fields, start, end, barsize, barfields, currency)
  } else {
    comSubscribe(conn, securities, fields, override_fields, overrides)
  }
}