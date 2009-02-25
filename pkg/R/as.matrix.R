## Bloomberg WAPI reference: "Appendix G: Error Codes", #APX007
as.matrix.BlpCOMReturn <- function(x, ...){
  vec <- replaceBloombergErrors(x, suppress=TRUE)
  ## get object properties
  secs <- attr(x, "securities")
  flds <- attr(x, "fields")
  blds <- attr(x, "barfields")
  ndat <- attr(x, "num.of.date.cols")
  if(!"character" %in% dataType(flds)){
    vec <- as.numeric(vec)
  }
  if(!is.null(blds)){
    f <- c()
    for(i in blds){
      f <- c(f, paste(flds, i, sep="."))
    }
    flds <- f
  }
  if(length(secs) > 1 && length(flds) > 1 && ndat > 0){
    stop("3-dimensional return values currently unsupported.")
    ## This code should enable 3-dimensional support
    ## d3 <- length(flds) + 1
    ## d2 <- length(secs) 
    ## d1 <- length(vec) / (d2 * d3)
    ## dim(vec) <- c(d1,d2,d3)
    ## dimnames(vec) <- list(NULL,secs,c("[DATETIME]",flds))
    ## return(vec)
  }
  ## convert to matrix
  if(length(secs) > 1 && ndat > 0){
    cols <- secs
  }else{
    cols <- flds
  }
  nc <- length(cols) + ndat
  nr <- length(vec) / nc
  mtx <- matrix(vec, nrow=nr, ncol=nc)
  ## remove redundant date columns
  if(ndat > 1){
    mtx <- matrix(mtx[, length(cols):(length(cols) * 2)],
                  ncol=(length(cols) + 1))
  }
  ## dimnames
  if(ndat > 0){
    cols <- c("[DATETIME]", cols)
  }else{
    rownames(mtx) <- secs
  }
  colnames(mtx) <- cols
  return(mtx)
}
