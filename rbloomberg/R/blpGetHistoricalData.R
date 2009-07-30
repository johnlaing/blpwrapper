## INTRADAY CALLS
## For all intraday calls, fields is the timebar base field:
## LAST_PRICE, BID, or ASK. Intraday tick calls are made when
## barsize=0. Intraday interval calls are made when barsize > 0. This
## call needs to have passed to barfields one or more of these aspect
## fields: OPEN, HIGH, LOW, LAST_TRADE, NUMBER_TICKS, and VOLUME.

## Bloomberg WAPI Reference: FRP003, DP015, and timebarflds.

blpGetHistoricalData <- function(conn,securities,fields,start,end=NULL,barsize=NULL,barfields=NULL, currency = NULL){
  if(length(securities) == 0 || length(fields) == 0){
    stop("Need at least one security and one field")
  }
  
  # This shouldn't harm things that are already POSIXcts.
  # Important to convert since invalid dates make R GUI crash.
  start <- as.POSIXct(start, tz=system.timezone())
  if (!is.null(end)) {
     end <- as.POSIXct(end, tz=system.timezone())
  }
  
  if (is.null(barsize)) { # historical

    if (is.null(end)) {
       if (is.null(currency)) {
          lst <- comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=start)
       } else {
          lst <- comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=start, Currency=currency)
       }
    } else {
       if (is.null(currency)) {
          lst <- comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=start, EndDate=end)
       } else {
          lst <- comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=start, Currency=currency, EndDate=end)
       }
    }

    if (is.null(lst)) stop("Call to BLPSubscribe did not return any data!")
    attr(lst,"num.of.date.cols") <- 1
    
  } else if (barsize == 0) { # intraday tick
                                        
    if (!is.null(barfields)) {
      stop("You are making an intraday *tick* call.. don't pass anything to barfields.")
    }
    
    if (is.null(end)) {
       if(is.null(currency)) {
          # TODO why do we need to fudge a value for EndDate here?
          lst <- comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=start, EndDate=Sys.time(), BarSize=as.integer(0))
       } else {
          lst <- comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=start, Currency=currency, EndDate=Sys.time(), BarSize=as.integer(0))
       }
    } else {
       if(is.null(currency)) {
          lst <- comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields, StartDate=start, EndDate=end, BarSize=as.integer(0))
       } else {
          lst <- comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields, StartDate=start, Currency=currency, EndDate=end, BarSize=as.integer(0))
       }
    }
    
    if (is.null(lst)) stop("Call to BLPSubscribe did not return any data!")
    attr(lst,"num.of.date.cols") <- length(fields)
    
  } else if (barsize > 0) { # intraday bars

    if (is.null(barfields)) { # Nothing passed to barfields arg.. assume all fields
      barfields <- c("OPEN","HIGH","LOW","LAST_TRADE","NUMBER_TICKS","VOLUME")
    }
    
    if (is.null(end)) {
       if(is.null(currency)) {
          lst <- comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields,StartDate=start, EndDate=Sys.time(), BarSize=as.integer(barsize), BarFields=barfields)
       } else {
          lst <- comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields,StartDate=start, Currency=currency, EndDate=Sys.time(), BarSize=as.integer(barsize), BarFields=barfields)
       }
    } else {
       if (is.null(currency)) {
          lst <- comGetProperty(conn, "BLPGetHistoricalData", Security=securities, Fields=fields,StartDate=start, EndDate=end, BarSize=as.integer(barsize), BarFields=barfields)
       } else {
          lst <- comGetProperty(conn, "BLPGetHistoricalData2", Security=securities, Fields=fields,StartDate=start, EndDate=end, Currency=currency, BarSize=as.integer(barsize), BarFields=barfields)
       }
    }
    
    if (is.null(lst)) stop("Call to BLPSubscribe did not return any data!")
    attr(lst,"num.of.date.cols") <- 1
  }
  
  # Set attributes of BlpRawReturn object.
  if (length(securities) > 1 && length(fields) == 1) {
    attr(lst,"num.of.date.cols") <- length(securities)
  }

  if (!is.null(barfields)) {
    attr(lst,"barfields") <- barfields
  }
  
  attr(lst, "start") <- start
  if (!is.null(end)) {
    attr(lst, "end") <- end
  }

  return(lst)
}
