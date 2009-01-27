comSubscribe <- function(conn, securities, fields, override_fields = NULL, overrides = NULL){
  conn <- conn$COMIDispatch
  x <- list(securities=securities, fields=fields, override_fields = override_fields, overrides = overrides)
  if(is.null(override_fields))
    x$data <- conn$BlpSubscribe(Security=securities, Fields=fields)
  else
    x$data <- conn$BlpSubscribe(Security=securities, Fields=fields, OverrideFields = override_fields, Overrides = overrides)
  class(x) <- "comBlpSubscribe"
  x
}

as.data.frame.comBlpSubscribe <- function(x, doc.errors=TRUE, ...){
  err.codes <- c("#N/A Fld","#N/A Tim","#N/A Com","#N/A Auth",
                 "#N/A Security","#N/A Intraday","#N/A History","#N/A N.A.",
                 "#N/A N Ap","#N/A Neg","#N/A Sec","#N/A Trd",
                 "#N/A RI Tim","#N/A RI Perm","#N/A Dberr","#N/A Sec Tp",
                 "#N/A Limit","#N/A MD Limit","#N/A Dly Lmt","#N/A Mth Lmt",
                 "#N/A Sls Auth","#N/A Unknown","#N/A Hist Fld","#N/A Rte",
                 "#N/A RTbl","#N/A InvalidReq","#N/A Restart","#N/A DBTimeOut")
  errs <- data.frame()
  for(i in 1:length(x$fields)){
    y <- unlist(x$data[[i]])
    n <- which(y %in% err.codes)
    if(length(n) > 0)
      errs <- rbind(errs, data.frame(Security=x$securities[n], Field=x$fields[i], ErrorCode=y[n]))
    y[n] <- NA
    y <- data.frame(do.call(paste("as", dataType(x$fields[i]), sep="."), list(y)))
    if(i == 1)
      z <- y
    else
      z <- cbind(z, y)
  }
  colnames(z) <- x$fields
  rownames(z) <- x$securities
  if(doc.errors)
    if(nrow(errs) > 0)
      attr(z, "BloombergErrors") <- errs
  z
}
