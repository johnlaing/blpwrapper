as.zoo.BlpCOMReturn <- function(x, suppress=TRUE, bbfields=.bbfields, ...){
  mtx <- as.matrix.BlpCOMReturn(x)
  cols <- colnames(mtx)[2:ncol(mtx)]
  if(attr(x,"num.of.date.cols") != 0){
    dtime <- as.chron.COMDate(mtx[,1])
    mtx <- matrix(mtx[,2:ncol(mtx)], ncol=ncol(mtx) - 1)
  }else{
    stop("No date column.. cannot convert to zoo.")
  }
  z <- zoo(mtx, order.by=dtime)
  colnames(z) <- cols
  return(z)
}
