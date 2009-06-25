## Bloomberg WAPI reference: "Appendix G: Error Codes", #APX007
as.matrix.BlpRawReturn <- function(x){
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
    ## This code should enable 3-dimensional support
    ## There is no support at this time for converting dates back to chron
    ## objects for 3D arrays since zoo only supports 2D data and currently
    ## zoo handles date converstion for the matrix retval.
    d3 <- length(flds) + 1
    d2 <- length(secs) 
    d1 <- length(vec) / (d2 * d3)
    dim(vec) <- c(d1,d2,d3)
    dimnames(vec) <- list(NULL,secs,c("DATETIME",flds))

    if (!is.null(attr(x, "end")) && (attr(x, "start") == attr(x, "end"))){
      # We are only returning a single date. Get rid of this date and treat
      # remaining data as a 2D array.
      vec <- vec[,,-1]
      return (vec)
    } else {
      return(vec)
    }
  }
  
  # convert to 2D matrix
  if (length(secs) > 1 && ndat > 0) {
    # We have multiple securities and only 1 field.
    cols <- secs
  } else {
    # We have multiple fields and only 1 security.
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
    cols <- c("DATETIME", cols)
  }else{
    rownames(mtx) <- secs
  }
  colnames(mtx) <- cols
  return(mtx)
}
