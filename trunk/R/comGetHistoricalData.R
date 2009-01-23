comGetHistoricalData <- function(conn, securities, fields, start, end=NULL, barsize=NULL, barfields=NULL){
  conn <- conn$COMIDispatch
  start <- as.COMDate(start[1])
  if(!is.null(end))
    end <- as.COMDate(end[1])
  x <- list(securities=securities, fields=fields, start=start, end=end, barsize=barsize, barfields=barfields)
  if(!is.null(barsize))
    if(!is.numeric(barsize) | barsize < 0)
      stop("barsize must be NULL, 0, or a positive iteger.")
  if(is.null(barsize)){
    if(is.null(end))
      x$data <- conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=start)
    else
      x$data <- conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=start, EndDate=end)
    class(x) <- "comBlpDaysData"
  }else if(barsize == 0){
    if(!all(bitmask <- data.intraday(fields)))
      warning(paste("not intraday field(s):", paste(fields[!bitmask], collapse=",")))
    if(is.null(end))
      x$data <- conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=start, BarSize=as.integer(0))
    else
      x$data <- conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=start, EndDate=end, BarSize=as.integer(0))
    class(x) <- "comBlpTickData"
  }else{
    ValidBF <- c("OPEN","HIGH","LOW","LAST_PRICE","NUMBER_TICKS","VOLUME")
    if(!all(bitmask <- data.intraday(fields)))
      warning(paste("not intraday field(s):", paste(fields[!bitmask], collapse=",")))
    if(is.null(barfields[1]))
      stop("barfields must be passed a non-null value when barsize > 0.")
    if(!toupper(barfields[1]) %in% ValidBF)
      stop(paste("barfields must be one or more of:", paste(ValidBF, collapse=",")))
    if(is.null(end))
      x$data <- conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=start, 
                                          BarSize=as.integer(barsize), BarFields=barfields)
    else
      x$data <- conn$BLPGetHistoricalData(Security=securities, Fields=fields, StartDate=start,
                                          EndDate=end, BarSize=as.integer(barsize), BarFields=barfields)
    class(x) <- "comBlpBarsData"
  }
  x
}

ColumnMaker <- function(x, index, security, field, namestyle="field", doc.errors=TRUE){
  err.codes <- c("#N/A Fld","#N/A Tim","#N/A Com","#N/A Auth",
                 "#N/A Security","#N/A Intraday","#N/A History","#N/A N.A.",
                 "#N/A N Ap","#N/A Neg","#N/A Sec","#N/A Trd",
                 "#N/A RI Tim","#N/A RI Perm","#N/A Dberr","#N/A Sec Tp",
                 "#N/A Limit","#N/A MD Limit","#N/A Dly Lmt","#N/A Mth Lmt",
                 "#N/A Sls Auth","#N/A Unknown","#N/A Hist Fld","#N/A Rte",
                 "#N/A RTbl","#N/A InvalidReq","#N/A Restart","#N/A DBTimeOut")
  y <- c()
  Replacer <- function(x){
    x <- unlist(x)
    if(is.null(x)){
      if(doc.errors)
        y <<- c(y, "NULL")
      return(NA)
    }
    if(x %in% err.codes){
      if(doc.errors)
        y <<- c(y, x)
      return(NA)
    }
    x
  }
  index <- as.chron.COMDate(index)
  z <- matrix(unlist(lapply(x, Replacer)), ncol=1)
  if(namestyle == "field")
    colnames(z) <- field
  else if(namestyle == "security")
    colnames(z) <- security
  else ## style 'both'
    colnames(z) <- paste(security, field, sep=".")
  z <- zoo(z, order.by=index)
  if(doc.errors)
    if(any(is.na(z)))
      attr(z, "BloombergErrors") <- data.frame(Index=index[is.na(z)], Security=security, Field=field, ErrorCode=y)
  z
}

as.zoo.comBlpDaysData <- function(x, doc.errors=TRUE, ...){
  if(length(unique(dataType(x$fields))) > 1)
    stop("all fields must share the same data type")
  if(length(x$securities) > 1 & length(x$fields) > 1)
    namestyle <- "both"
  else if(length(x$securities) > 1)
    namestyle <- "security"
  else
    namestyle <- "field"
  z <- NULL
  Errors <- c()
  for(i in 1:length(x$securities)){
    for(j in 1:length(x$fields)){
      y <- ColumnMaker(x$data[[1+j]][[i]], x$data[[1]][[i]], x$securities[i], x$fields[j], namestyle, doc.errors)
      if(is.null(z))
        z <- y
      else
        z <- merge(z, y, all=TRUE, fill=NA)
      if(doc.errors)
        if(!is.null(attr(y, "BloombergErrors")))
          Errors <- rbind(Errors, attr(y, "BloombergErrors"))
    }
  }
  if(doc.errors)
    if(length(Errors) > 0)
      attr(z, "BloombergErrors") <- Errors
  z
}

as.zoo.comBlpTickData <- function(x, doc.errors=TRUE, ...){
  ## !! CODE ME !!
}

as.zoo.comBlpBarsData <- function(x, doc.errors=TRUE, ...){
  ## !! CODE ME !!
}

