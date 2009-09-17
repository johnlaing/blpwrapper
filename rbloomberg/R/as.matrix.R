check.2d.matrix <- function(d1, d2, vec) {
   if (d1 * d2 != length(vec)) {
      stop(paste("matrix dimensions", d1, ",", d2, "do not match vector length", length(vec)))
   }
}

check.3d.matrix <- function(d1, d2, d3, vec) {
   if (d1 * d2 * d3 != length(vec)) {
      stop(paste("matrix dimensions", d1, ",", d2, ",", d3, "do not match vector length", length(vec)))
   }
}

matrix.page <- function(i, m) {
   m[,,i]
}

matrix.from.column <- function(col, m, d1, d2) {
   v <- m[,col]
   matrix(v, c(d1,d2))
}

prepend.column <- function(col, m, data) {
   v <- m[[col]]
   y <- append(data, v)
   
   d1 <- dim(v)[1]
   d2 <- dim(v)[2]
   array(y, c(d1, d2 + 1))
}

numeric.to.timeDate <- function(x) {
   x <- as.numeric(x)
   # TODO make iface available here directly instead of guessing?
   
   # TODO This only tests first element of x if x is a vector, and it raises a warning. Probably okay in practice but better to fix.
   if (x < 100000) {
      excel.date.to.timeDate(x)
   } else {
      timeDate("1970-01-01") + x
   }
}

# We convert everything to a vector, then reshape it into a matrix.
as.matrix.BlpRawReturn <- function(x){
  vec <- replaceBloombergErrors(x, suppress=TRUE)

  securities <- attr(x, "securities")
  fields <- attr(x, "fields")
  barfields <- attr(x, "barfields")
  num.of.date.cols <- attr(x, "num.of.date.cols")
  
  is.not.historical <- (num.of.date.cols == 0)
  is.not.bar <- is.null(barfields)
  
  if ((!"character" %in% dataType(fields)) && (num.of.date.cols == 0)) {
    vec <- as.numeric(vec)
  }
  
  # Determine shape of data. Calculate required matrix dimensions.
  # Coerce to that shape. Do any other special processing.
  if (is.not.historical) {
     # 2 Dimensional Matrix, rows are securities, columns are fields
     d1 <- length(securities)
     d2 <- length(fields) + num.of.date.cols
     check.2d.matrix(d1, d2, vec)
     mtx <- array(vec, c(d1, d2))
     
  } else {
     if (is.not.bar) {
        if (length(securities) == 1 && length(fields) >= 1) {
           # 2 Dimensional Matrix, rows are dates, columns are fields
           if (num.of.date.cols > 1) stop(paste("Should only be 1 date col with 1 security! There are", num.of.date.cols))
           
           d2 <- length(fields) + 1
           d1 <- length(vec) / d2
           check.2d.matrix(d1, d2, vec)
           mtx <- array(vec, c(d1, d2))
           mtx[,1] <- format(numeric.to.timeDate(mtx[,1]))
           
        } else if (length(securities) >= 1 && length(fields) == 1) {
           # 2 Dimensional Matrix, rows are dates, columns are securities
           
           d1 <- length(securities) + num.of.date.cols
           d2 <- length(vec) / d1
           check.2d.matrix(d1, d2, vec)
           mtx <- array(vec, c(d2, d1))

           # Remove excess dates
           mtx <- mtx[,-(1:(num.of.date.cols-1))]
           # TODO Convert dates to timeDate class
           mtx[,1] <- format(numeric.to.timeDate(mtx[,1]))
           
        } else {
           # 3 Dimensional Matrix, rows are dates, columns are securities, pages are fields
           
           if (length(securities) == 1) stop("should have more than 1 security here!")
           if (length(fields) == 1) stop("should have more than 1 field here!")
           
           d3 <- length(fields) + 1 # fields
           d2 <- length(securities) # securities
           d1 <- length(vec) / (d2 * d3) # dates
           check.3d.matrix(d1, d2, d3, vec)
           
           mtx <- array(vec, c(d2*d3,d1))
           dates <- format(numeric.to.timeDate(mtx[,1][1:d1]))
           
           mtx <- mtx[,-1] # drop dates from mtx, will add them back in later
           
           d1 <- length(dates)
           d2 <- length(securities) + 1
           d3 <- length(fields)
           final <- array(rep(NA, d1*d2*d3), c(d1, d2, d3))
           
           for (i in 1:d3) {
              v <- append(dates, mtx[,i])
              final[,,i] <- array(v, c(d1, d2))
           }
           
           mtx <- final
        }
     } else {
        stop("bar data not implemented")

        f <- c()
        for (i in barfields) {
          f <- c(f, paste(fields, i, sep="."))
        }
        fields <- f
     }
  }

  return(mtx)
}
