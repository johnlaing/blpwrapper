as.excel.date <- function(x, date1904 = FALSE){
  if (!is.timeDate(x)) {
     stop("as.COMDate is only valid for timeDate class!")
  }
  
  if (date1904) {
     y <- as.numeric(x - timeDate("1903-12-31")) + 1
  } else {
     y <- as.numeric(x - timeDate("1900-01-01")) + 2
  }

  class(y) <- "COMDate"
  return(y)
}

excel.date.to.timeDate <- function(x, date1904 = FALSE) {
   if (date1904) {
      y <- timeDate("1903-12-31") + (as.numeric(x) - 1) * 24 * 3600
   } else {
      y <- timeDate("1900-01-01") + (as.numeric(x) - 2) * 24 * 3600
   }
   
   reverse <- as.excel.date(y)

   if (any(abs(reverse - x) > 0.00001)) {
      stop(cat("reverse excel date doesn't match", as.character(x), as.character(y), as.character(reverse)))
   }
   
   return(y)
}

is.timeDate <- function(obj) {
   as.character(class(obj)) == "timeDate"
}

numeric.to.timeDate <- function(x) {
   x <- as.numeric(x)
   
   # TODO make iface available here directly somehow instead of guessing?
   all.excel <- all(x < 100000)
   all.unix <- all(x > 100000)
   
   if (!(all.excel || all.unix)) stop("inconsistent date type!")
   
   if (all.excel) {
      excel.date.to.timeDate(x)
   } else {
      timeDate("1970-01-01") + x
   }
}
