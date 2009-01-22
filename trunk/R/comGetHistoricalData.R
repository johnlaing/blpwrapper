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

BloombergErrors2NA <- function(x){
  err.codes <- c("#N/A Fld","#N/A Tim","#N/A Com","#N/A Auth",
                 "#N/A Security","#N/A Intraday","#N/A History","#N/A N.A.",
                 "#N/A N Ap","#N/A Neg","#N/A Sec","#N/A Trd",
                 "#N/A RI Tim","#N/A RI Perm","#N/A Dberr","#N/A Sec Tp",
                 "#N/A Limit","#N/A MD Limit","#N/A Dly Lmt","#N/A Mth Lmt",
                 "#N/A Sls Auth","#N/A Unknown","#N/A Hist Fld","#N/A Rte",
                 "#N/A RTbl","#N/A InvalidReq","#N/A Restart","#N/A DBTimeOut")
  y <- x$data
  for(i in 1:length(x$securities)){
    z <- c()
    Errors <- c()
    for(j in 1:length(x$fields)){
      if(length(y[[1+j]][[i]]) != length(unlist(y[[1+j]][[i]]))) ## any NULLs?
        y[[1+j]][[i]] <- lapply(y[[1+j]][[i]], function(x){if(is.null(unlist(x))) return(NA) else return(unlist(x))})
    }
    if(any(unlist(y[[1+j]][[i]]) %in% err.codes))              ## any bloomberg errors?
      for(k in which(unlist(y[[1+j]][[i]]) %in% err.codes)){
        Errors <- rbind(Errors, data.frame(Index=format(as.chron.COMDate(unlist(y[[1]][[i]][[k]]))), 
                                           Security=x$securities[i],
                                           Field=x$fields[j],
                                           ErrorCode=unlist(y[[1+j]][[i]][[k]])))
        y[[1+j]][[i]][[k]] <- NA
      }
  }
  x$data <- y
  if(length(Errors) == 0)
    Errors <- NULL
  else
    rownames(Errors) <- 1:nrow(Errors)
  x$errors <- Errors
  x
}

as.matrix.comBlpDaysData <- function(x, ...){
  dTypes <- dataType(x$fields)
  if(length(unique(dTypes)) > 1)
    stop("all fields must share the same data type")
  x <- BloombergErrors2NA(x)
  if(ncol(m <- matrix(unlist(x$data[[1]]), ncol=length(x$data[[1]]))) > 1) ## if indices don't match convert via "safe" dataframe method
    if(sum(diff(t(m))) != 0)
      return(as.matrix(as.data.frame.comBlpDaysData(x, ...)))
  y <- matrix(unlist(x$data[-1]), ncol=(length(x$securities) * length(x$fields))) 
  rownames(y) <- format(as.chron.COMDate(m[, 1]))
  if(length(x$securities) > 1 & length(x$fields) > 1){ ## add colnames
    cnames <- expand.grid(x$securities, x$fields)
    colnames(y) <- paste(cnames[[1]], cnames[[2]], sep=".")
  }else if(length(x$securities) > 1){
    colnames(y) <- x$securities
  }else{
    colnames(y) <- x$fields
  }
  attr(y, "BloombergErrors") <- x$errors
  y
}

as.data.frame.comBlpDaysData <- function(x, ...){
  x <- BloombergErrors2NA(x)
  for(i in 1:length(x$securities)){
    Indx <- as.chron.COMDate(unlist(x$data[[1]][[i]]))
    y <- c()
    for(j in 1:length(x$fields))
      y <- cbind(y, unlist(x$data[[1+j]][[i]]))
    if(i == 1)
      z <- zoo(y, order.by=Indx)
    else
      z <- merge(z, y, all = TRUE, fill = NA, retclass="data.frame")
  }
  if(length(x$securities) > 1 & length(x$fields) > 1){ ## add colnames
    cnames <- expand.grid(x$securities, x$fields)
    colnames(z) <- paste(cnames[[1]], cnames[[2]], sep=".")
  }else if(length(x$securities) > 1){
    colnames(z) <- x$securities
  }else{
    colnames(z) <- x$fields
  }
  attr(z, "BloombergErrors") <- x$errors
  z
}

as.matrix.comBlpTickData <- function(x, ...){
  ## !! CODE ME !!
}

as.data.frame.comBlpTickData <- function(x, ...){
  ## !! CODE ME !!
}

as.matrix.comBlpBarsData <- function(x, ...){
  ## !! CODE ME !!
}

as.data.frame.comBlpBarsData <- function(x, ...){
  ## !! CODE ME !!
}
