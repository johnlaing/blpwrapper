as.data.frame.BlpRawReturn <- function(x) {
  mtx <- as.matrix.BlpRawReturn(x)

  if (length(dim(mtx)) != 2) stop("data frames can only be created for 2 dimensions, should not be here!")
  
  fields <- attr(x, "fields")
  securities <- attr(x, "securities")
  barfields <- attr(x, "barfields")
  
  num.of.date.cols <- attr(mtx, "num.of.date.cols")
  if (num.of.date.cols > 1) stop("Should have at most 1 date column!")
  
  if (!is.null(barfields)) {
    fields <- barfields
  }

  column.data.types <- dataType(fields, .bbfields)
  
  if (num.of.date.cols > 0) {
     column.data.types <- append("datetime", column.data.types)
  }
  
  df <- as.data.frame(mtx)

  for (i in 1:ncol(df)) {
      type <- column.data.types[i]
      vec <- as.vector(df[,i])

     df[,i] <- switch(
             type,
             character = as.character(vec),
             double = as.numeric(vec),
             logical = as.logical(vec),
             datetime = timeDate(vec), # Here we are either processing a Bloomberg date string or our own date string created in as.matrix.
             stop(paste("conversion of column type", type, "not supported!"))
      )
  }
  
  return(df)
}
