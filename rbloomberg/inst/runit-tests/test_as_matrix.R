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
   rownames(expected) <- securities
   colnames(expected) <- fields
   attr(expected, "num.of.date.cols") <- 0
   
   actual <- as.matrix.BlpRawReturn(x)
   
   checkEquals(actual, expected)
}

test.as.matrix.non.historical.dates <- function() {
   conn <- blpConnect()
   
   securities <- c("RYA ID EQUITY", "OCN US EQUITY")
   fields <- c("EQY_INIT_PO_DT", "COUNTRY")
   
   x <- c("05/29/1997", "09/24/1996", "IR", "US")
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   attr(x, "num.of.date.cols") <- 0
   attr(x, "class") <- "BlpRawReturn"
   
   actual <- blp(conn, securities, fields, retval="raw")
   checkEquals(actual, x)
   
   x <- c("1997-05-29", "1996-09-24", "IR", "US")
   attr(x, "securities") <- securities
   attr(x, "fields") <- fields
   attr(x, "num.of.date.cols") <- 0
   attr(x, "class") <- "BlpRawReturn"
   
   expected <- array(x, c(2,2))
   rownames(expected) <- securities
   colnames(expected) <- fields
   attr(expected, "num.of.date.cols") <- 0
   
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
   rownames(expected) <- securities
   colnames(expected) <- fields
   attr(expected, "num.of.date.cols") <- 0
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
   attr(expected, "num.of.date.cols") <- 1
   colnames(expected) <- c("DATETIME", "RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
   rownames(expected) <- c("2008-02-01", "2008-02-04")
   
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
   attr(expected, "num.of.date.cols") <- 1
   colnames(expected) <- c("DATETIME", "CUR_MKT_CAP", "PX_LAST")
   rownames(expected) <- c("2008-02-01", "2008-02-04")

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
   
   expected <- c("2009-01-05", "2009-01-06", "2009-01-07", 3.24, 3.205, 3.168, 5.5109, 5.5109, 5.5049, 20.52, 20.76, 19.51, "2009-01-05", "2009-01-06", "2009-01-07", 4772.671, 4721.114, 4666.612, 573.8562, 573.8562, 573.2291, 182537.2, 184672.1, 173552.61231110000)
   expected <- array(expected, c(3,4,2))
   dimnames(expected)[1] <- list(c("2009-01-05", "2009-01-06", "2009-01-07"))
   dimnames(expected)[2] <- list(c("DATETIME", "RYA ID EQUITY", "OCN US EQUITY", "MSFT US EQUITY"))
   dimnames(expected)[3] <- list(c("PX_LAST", "CUR_MKT_CAP"))
   attr(expected, "num.of.date.cols") <- 1
   
   checkEquals(y, expected, tolerance = 0.0000005)
}

test.as.matrix.bardata <- function() {
  conn <- blpConnect()
  securities <- c("AUD CURNCY")
  barfields <-  c("LAST_PRICE")
  start <- timeDate("2009-12-15 10:00")
  end <- timeDate("2009-12-15 11:00")
  
  x <- c(40162.416667, 40162.420139, 40162.423611, 40162.427083, 40162.430556, 40162.434028, 40162.437500, 40162.440972, 40162.444444, 40162.447917, 40162.451389, 40162.454861,
 0.906605, 0.907115, 0.906910, 0.907270, 0.908185, 0.908415, 0.908050, 0.907500, 0.907350, 0.907400, 0.907550, 0.907850)
  attr(x, "num.of.date.cols") <- 1
  attr(x, "barfields") <- barfields
  attr(x, "start") <- start
  attr(x, "end") <- end
  attr(x, "class") <- "BlpRawReturn"
  attr(x, "securities") <- securities
  attr(x, "fields") <- barfields

  actual <- blp(conn, securities, fields=barfields, start=start, end=end, barfields=barfields, barsize=5, retval="raw")
  
  checkEquals(actual, x, tolerance=0.0000005)

  expected <- c("2009-12-15 10:00:00", "2009-12-15 10:05:00", "2009-12-15 10:09:59", "2009-12-15 10:14:59", "2009-12-15 10:20:00", "2009-12-15 10:25:00", "2009-12-15 10:30:00", "2009-12-15 10:34:59", "2009-12-15 10:39:59", "2009-12-15 10:45:00", "2009-12-15 10:50:00", "2009-12-15 10:54:59",
 "0.906605", 0.907115, 0.906910, 0.907270, 0.908185, 0.908415, 0.908050, 0.907500, 0.907350, 0.907400, 0.907550, 0.907850)
  expected <- array(expected, c(12, 2))
  rownames(expected) <- c("2009-12-15 10:00:00", "2009-12-15 10:05:00", "2009-12-15 10:09:59", "2009-12-15 10:14:59", "2009-12-15 10:20:00", "2009-12-15 10:25:00", "2009-12-15 10:30:00", "2009-12-15 10:34:59", "2009-12-15 10:39:59", "2009-12-15 10:45:00", "2009-12-15 10:50:00", "2009-12-15 10:54:59")
  colnames(expected) <- c("DATETIME", "LAST_PRICE")
  attr(expected, "num.of.date.cols") <- 1

  y <- as.matrix.BlpRawReturn(x)
  checkEquals(y, expected, tolerance = 0.0000005)
}
