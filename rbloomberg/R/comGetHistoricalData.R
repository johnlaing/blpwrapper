as.excel.date <- function(x, date1904 = FALSE){
  if (!is.timeDate(x)) {
     stop("as.COMDate is only valid for timeDate class!")
  }
  
  if (date1904) {
     y <- as.numeric(x - timeDate("1903-12-31")) + 1
  } else {
     y <- as.numeric(x - timeDate("1900-01-01")) + 2
  }

  class(y) <- "COMDate"
  return(y)
}

excel.date.to.timeDate <- function(x, date1904 = FALSE) {
   if (date1904) {
      y <- timeDate("1903-12-31") + (as.numeric(x) - 1) * 24 * 3600
   } else {
      y <- timeDate("1900-01-01") + (as.numeric(x) - 2) * 24 * 3600
   }
   
   reverse <- as.excel.date(y)

   if (abs(reverse - x) > 0.00001) {
      stop(cat("reverse excel date doesn't match", as.character(x), as.character(y), as.character(reverse)))
   }
   
   return(y)
}

is.timeDate <- function(obj) {
   as.character(class(obj)) == "timeDate"
}

comGetHistoricalData <- function(conn, securities, fields, start, end=NULL, barsize=NULL, barfields=NULL, currency = NULL) {
  classname <- as.character(class(conn))
  
  if (is.null(barsize)) { # historical

    if (is.null(end)) {
       if (is.null(currency)) {
          lst <- switch(classname,
               COMIDispatch = conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate = as.excel.date(start)),
               COMObject = comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=as.POSIXct(start)),
               stop(paste("class name", classname, "not supported!"))
         )
       } else {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData2(Security=securities, Fields=fields, StartDate = as.excel.date(start), Currency=currency),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=as.POSIXct(start), Currency=currency),
             stop(paste("class name", classname, "not supported!"))
         )
       }
    } else {
       if (is.null(currency)) {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=as.excel.date(start), EndDate=as.excel.date(end)),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=as.POSIXct(start), EndDate=as.POSIXct(end)),
             stop(paste("class name", classname, "not supported!"))
         )
       } else {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData2(Security=securities, Fields=fields, StartDate = as.excel.date(start), EndDate=as.excel.date(end), Currency=currency),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=as.POSIXct(start), EndDate=as.POSIXct(end), Currency=currency),
             stop(paste("class name", classname, "not supported!"))
         )
       }
    }

    num.of.date.cols <- length(securities)
    
  } else if (barsize == 0) { # intraday tick

    if (!is.null(barfields)) {
      stop("You are making an intraday *tick* call.. don't pass anything to barfields.")
    }
    
    if (is.null(end)) {
       if(is.null(currency)) {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate = as.excel.date(start), EndDate = as.excel.date(Sys.timeDate()), BarSize=as.integer(0)),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=as.POSIXct(start), EndDate=as.POSIXct(Sys.time()), BarSize=as.integer(0)),
             stop(paste("class name", classname, "not supported!"))
          )
       } else {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData2(Security=securities, Fields=fields, StartDate = as.excel.date(start), Currency=currency, EndDate = as.excel.date(Sys.timeDate()), BarSize=as.integer(0)),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=as.POSIXct(start), Currency=currency, EndDate=as.POSIXct(Sys.time()), BarSize=as.integer(0)),
             stop(paste("class name", classname, "not supported!"))
          )
       }
    } else {
       if(is.null(currency)) {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate = as.excel.date(start), EndDate = as.excel.date(end), BarSize=as.integer(0)),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=as.POSIXct(start), EndDate=as.POSIXct(end), BarSize=as.integer(0)),
             stop(paste("class name", classname, "not supported!"))
          )
       } else {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData2(Security=securities, Fields=fields, StartDate = as.excel.date(start), Currency=currency, EndDate = as.excel.date(end), BarSize=as.integer(0)),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=as.POSIXct(start), Currency=currency, EndDate=as.POSIXct(end), BarSize=as.integer(0)),
             stop(paste("class name", classname, "not supported!"))
          )
       }
    }
    
    num.of.date.cols <- length(fields)
    
  } else if (barsize > 0) { # intraday bars

    if (is.null(barfields)) {
      barfields <- c("OPEN","HIGH","LOW","LAST_TRADE","NUMBER_TICKS","VOLUME")
    }
    
    if (is.null(end)) {
       if(is.null(currency)) {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate = as.excel.date(start), EndDate = as.excel.date(Sys.timeDate()), BarSize=as.integer(barsize), BarFields = barfields),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=as.POSIXct(start), EndDate=as.POSIXct(Sys.timeDate()), BarSize=as.integer(barsize), BarFields=barfields),
             stop(paste("class name", classname, "not supported!"))
          )
       } else {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData2(Security=securities, Fields=fields, StartDate = as.excel.date(start), Currency=currency, EndDate = as.excel.date(Sys.timeDate()), BarSize=as.integer(barsize), BarFields = barfields),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=as.POSIXct(start), Currency=currency, EndDate=as.POSIXct(Sys.timeDate()), BarSize=as.integer(barsize), BarFields=barfields),
             stop(paste("class name", classname, "not supported!"))
          )
       }
    } else {
       if (is.null(currency)) {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate = as.excel.date(start), EndDate = as.excel.date(end), BarSize=as.integer(barsize), BarFields = barfields),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=as.POSIXct(start), EndDate=as.POSIXct(end), BarSize=as.integer(barsize), BarFields=barfields),
             stop(paste("class name", classname, "not supported!"))
          )
       } else {
          lst <- switch(classname,
             COMIDispatch = conn$BLPGetHistoricalData2(Security=securities, Fields=fields, StartDate = as.excel.date(start), Currency=currency, EndDate = as.excel.date(end), BarSize=as.integer(barsize), BarFields = barfields),
             COMObject = comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=as.POSIXct(start), Currency=currency, EndDate=as.POSIXct(end), BarSize=as.integer(barsize), BarFields=barfields),
             stop(paste("class name", classname, "not supported!"))
          )
       }
    }
    
    num.of.date.cols <- 1
  }
  
  if (is.null(lst)) {
     stop("Call to BLPGetHistoricalData did not return any data!")
  }
  
  while (is.list(lst)) {
     lst <- unlist(lst, recursive = TRUE)
  }
  
  lst <- as.vector(lst)
  
  attr(lst, "num.of.date.cols") <- num.of.date.cols
  
  if (!is.null(barfields)) {
    attr(lst,"barfields") <- barfields
  }
  if (!is.null(currency)) {
    attr(lst,"currency") <- currency
  }
  
  attr(lst, "start") <- start
  
  if (!is.null(end)) {
    attr(lst, "end") <- end
  }
  
  return(lst)
}
