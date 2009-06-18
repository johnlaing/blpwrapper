as.zoo.BlpCOMReturn <- function(x, suppress=TRUE, bbfields=.bbfields, ...){
  mtx <- as.matrix.BlpCOMReturn(x)
  if(!is.matrix(mtx)){
    # If mtx is not a matrix, this is most likely because it is 3D data.
    # Matrices, and hence zoo objects, can only be 2D.
    stop("3D data is not supported by zoo. Specify retval=\"matrix\" or \"raw\".")
  }
  cols <- colnames(mtx)[2:ncol(mtx)]
  if(attr(x,"num.of.date.cols") != 0){
    dtime <- as.POSIXct(mtx[,1], tz=Sys.timezone(), origin="1970-01-01")
    mtx <- matrix(mtx[,2:ncol(mtx)], ncol=ncol(mtx) - 1)
  }else{
    stop("No date column.. cannot convert to zoo.")
  }
  z <- zoo(mtx, order.by=dtime)
  colnames(z) <- cols
  return(z)
}
