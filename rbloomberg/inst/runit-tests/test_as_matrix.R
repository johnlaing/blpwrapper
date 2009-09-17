test.2d.invalid <- function() {
   checkException(
      check.2d.matrix(2, 2, 1:6)
   )
   
   check.2d.matrix(2, 2, 1:4)
}

test.3d.invalid <- function() {
   checkException(
      check.3d.matrix(2, 3, 2, 1:14)
   )
   
   check.3d.matrix(2, 3, 2, 1:12)
}

test.numeric.to.timedate <- function() {
   ntd <- numeric.to.timeDate
   checkEquals(ntd(39479), timeDate("2008-02-01"))
   checkEquals(ntd(39482), timeDate("2008-02-04"))
   checkEquals(ntd(1201824000), timeDate("2008-02-01"))
   checkEquals(ntd(1202083200), timeDate("2008-02-04"))
}

test.as.matrix.non.historical <- function() {
   conn <- blpConnect()
   
   securities <- c("RYA ID EQUITY", "OCN US EQUITY")
   fields <- c("NAME", "COUNTRY")
   
   x <- c("RYANAIR HOLDINGS PLC", "OCWEN FINANCIAL CORP", "IR", "US")
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   attr(x, "num.of.date.cols") <- 0
   attr(x, "class") <- "BlpRawReturn"
   
   actual <- blp(conn, securities, fields, retval="raw")
   checkEquals(actual, x)
   
   expected <- array(x, c(2,2))
   actual <- as.matrix.BlpRawReturn(x)
   
   checkEquals(actual, expected)
}

test.as.matrix.non.historical.2 <- function() {
   conn <- blpConnect()
   
   securities <- c("RYA ID EQUITY", "OCN US EQUITY", "MSFT US EQUITY")
   fields <- c("NAME")
   
   x <- c("RYANAIR HOLDINGS PLC", "OCWEN FINANCIAL CORP", "MICROSOFT CORP")
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   attr(x, "num.of.date.cols") <- 0
   attr(x, "class") <- "BlpRawReturn"
   
   actual <- blp(conn, securities, fields, retval="raw")
   checkEquals(actual, x)
   
   expected <- array(x, c(3,1))
   actual <- as.matrix.BlpRawReturn(x)
   
   checkEquals(actual, expected)
}

test.as.matrix.multiple.securities.historical <- function() {
   conn <- blpConnect()

   securities <- c("RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
   fields <- c("CUR_MKT_CAP")
   start <- timeDate("2008-02-01")
   end <- timeDate("2008-02-04")
   
   x <- c(39479, 39482, 39479, 39482, 39479, 39482, 5366.891, 5277.443, 390.1707, 408.3037, 37928.28, 39197.90)
   attr(x, "num.of.date.cols") <- 3
   attr(x, "start") <- start
   attr(x, "end") <- end
   attr(x, "class") <- "BlpRawReturn"
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   
   actual <- blp(conn, securities, fields, start=start, end=end, retval="raw")
   checkEquals(actual, x, tolerance = 0.0005)

   actual <- as.matrix.BlpRawReturn(x)
   
   x <- c("2008-02-01", "2008-02-04", 5366.891, 5277.443, 390.1707, 408.3037, 37928.28, 39197.90)
   expected <- array(x, c(2,4))
   checkEquals(actual, expected, tolerance = 0.0005)
}

test.as.matrix.multiple.fields.historical <- function() {
   conn <- blpConnect()

   securities <- c("RYA ID EQUITY")
   fields <- c("CUR_MKT_CAP", "PX_LAST")
   start <- timeDate("2008-02-01")
   end <- timeDate("2008-02-04")
   
   x <- c(39479, 39482, 5366.891, 5277.443, 3.600, 3.540)
   attr(x, "num.of.date.cols") <- 1
   attr(x, "start") <- start
   attr(x, "end") <- end
   attr(x, "class") <- "BlpRawReturn"
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   
   actual <- blp(conn, securities, fields, start=start, end=end, retval="raw")
   checkEquals(actual, x, tolerance = 0.0005)

   actual <- as.matrix.BlpRawReturn(x)
   
   x <- c("2008-02-01", "2008-02-04", 5366.891, 5277.443, 3.600, 3.540)
   attr(x, "num.of.date.cols") <- 1
   attr(x, "start") <- start
   attr(x, "end") <- end
   attr(x, "class") <- "BlpRawReturn"
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   expected <- array(x, c(2,3))
   checkEquals(actual, expected, tolerance = 0.0005)
}

test.as.matrix.3d <- function() {
   conn <- blpConnect()
   
   securities <- c("RYA ID EQUITY", "OCN US EQUITY", "MSFT US EQUITY")
   fields <- c("PX_LAST", "CUR_MKT_CAP")
   start <- timeDate("2009-01-05")
   end <- timeDate("2009-01-07")
   
   x <- c(39818, 39819, 39820, 39818, 39819, 39820, 39818, 39819, 39820, 3.24, 3.205, 3.168, 5.5109, 5.5109, 5.5049, 20.52, 20.76, 19.51, 4772.671, 4721.114, 4666.612, 573.8562, 573.8562, 573.2291, 182537.2, 184672.1, 173552.61231110000)
   attr(x, "num.of.date.cols") <- 3
   attr(x, "start") <- start
   attr(x, "end") <- end
   attr(x, "class") <- "BlpRawReturn"
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   
   actual <- blp(conn, securities, fields, start=start, end=end, retval="raw")
   checkEquals(actual, x, tolerance = 0.0000005)
   
   y <- as.matrix.BlpRawReturn(x)
   print(y)
   
   expected <- c("2009-01-05", "2009-01-06", "2009-01-07", 3.24, 3.205, 3.168, 5.5109, 5.5109, 5.5049, 20.52, 20.76, 19.51, "2009-01-05", "2009-01-06", "2009-01-07", 4772.671, 4721.114, 4666.612, 573.8562, 573.8562, 573.2291, 182537.2, 184672.1, 173552.61231110000)
   expected <- array(expected, c(3,4,2))

   checkEquals(y, expected, tolerance = 0.0000005)
}
