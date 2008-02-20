## INTRADAY CALLS
## For all intraday calls, fields is the timebar base field:
## LAST_PRICE, BID, or ASK. Intraday tick calls are made when
## barsize=0. Intraday interval calls are made when barsize > 0. This
## call needs to have passed to barfields one or more of these aspect
## fields: OPEN, HIGH, LOW, LAST_TRADE, NUMBER_TICKS, and VOLUME.

## Bloomberg WAPI Reference: FRP003, DP015, and timebarflds.

blpGetHistoricalData <- function(conn,securities,fields,start,end=NULL,barsize=NULL,barfields=NULL){
  if(length(securities) == 0 || length(fields) == 0){
    stop("Need at least one security and one field")
  }
  
  # Convenience methods to convert, e.g., "2008-01-01" to a chron.
  # Not sure if GMT is appropriate everywhere, will this give the correct
  # date in a non-GMT environment?
  if (is.character(start)){
    start <- as.chron(as.POSIXct(start, tz="GMT"))
  }
  if (is.character(end)){
    end <- as.chron(as.POSIXct(end, tz="GMT"))
  }
  
  comStart <-  as.COMDate.chron(start);
  if(!is.null(end)){
    comEnd <- as.COMDate.chron(end);
  }
  ## Call COM
  if(is.null(barsize)){
                                        # historical
    if(is.null(end)){
      lst <- try(conn$BLPGetHistoricalData(Security=securities,
                                           Fields=fields,StartDate=comStart),silent=TRUE)
    }else{
      lst <- try(conn$BLPGetHistoricalData(Security=securities,
                                         Fields=fields,StartDate=comStart,EndDate=comEnd),silent=TRUE)
    }
    attr(lst,"num.of.date.cols") <- 1
  }else if(barsize == 0){
                                        # intraday tick
    if(!is.null(barfields)){
      stop("You are making an intraday *tick* call.. don't pass anything to barfields.")
    }
    if(is.null(end)){
      lst <- try(conn$BLPGetHistoricalData(Security=securities,
                                           Fields=fields,StartDate=comStart,
                                           BarSize=as.integer(0)),silent=TRUE)    
    }else{
      lst <- try(conn$BLPGetHistoricalData(Security=securities,
                                           Fields=fields,StartDate=comStart,
                                           EndDate=comEnd,BarSize=as.integer(0)),silent=TRUE)    
    }
    attr(lst,"num.of.date.cols") <- length(fields)
  }else if(barsize > 0){
                                        # intraday bars
    if(is.null(barfields)){
                                        # Nothing passed to barfields arg.. assume all fields
      barfields <- c("OPEN","HIGH","LOW","LAST_TRADE","NUMBER_TICKS","VOLUME")
    }
    if(is.null(end)){
      lst <- try(conn$BLPGetHistoricalData(Security=securities,
                                           Fields=fields,StartDate=comStart,
                                           BarSize=as.integer(barsize),BarFields=barfields),silent=TRUE)
    }else{
      lst <- try(conn$BLPGetHistoricalData(Security=securities,
                                           Fields=fields,StartDate=comStart,
                                           EndDate=comEnd,BarSize=as.integer(barsize),BarFields=barfields),silent=TRUE)
    }
    attr(lst,"num.of.date.cols") <- 1
  }
  ## Set more properties of the return value
  if(length(securities) > 1 && length(fields) == 1){
    attr(lst,"num.of.date.cols") <- length(securities)    
  }
  class(lst) <- "BlpCOMReturn"
  attr(lst,"securities") <- securities
  attr(lst,"fields") <- fields
  if(!is.null(barfields)){
    attr(lst,"barfields") <- barfields
  }
  attr(lst, "start") <- start
  if(!is.null(end)){
    attr(lst, "end") <- end
  }
  return(lst)
}


