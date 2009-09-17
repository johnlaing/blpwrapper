test.comGetHistoricalData.basic.character.results <- function() {
  conn1 <- blpConnect("COM")
  conn2 <- blpConnect("rcom")
  
  securities <- c("RYA ID Equity", "OCN US Equity")
  fields <- c("PX_LAST", "CUR_MKT_CAP")
  
  actual <- comGetHistoricalData(conn1, securities, fields, start = timeDate("2009-01-01"), end = timeDate("2009-01-02"))
  checkEquals(attr(actual, "num.of.date.cols"), 2)
  actual <- as.vector(actual)
  actual <- replaceBloombergErrors(actual)
  
  expected <- c("39814", "39815", "39814", "39815", NA, "3.15", NA, "5.4868", NA, "4640.0972", NA, "571.3476")
  checkEquals(actual, expected)
  
  actual <- comGetHistoricalData(conn2, securities, fields, start = timeDate("2009-01-01"), end = timeDate("2009-01-02"))
  checkEquals(attr(actual, "num.of.date.cols"), 2)
  actual <- as.vector(actual)
  actual <- replaceBloombergErrors(actual)

  expected <- c("1230764400", "1230854400", "1230768000", "1230854400", NA, "3.15", NA, "5.4868", NA, "4640.0972", NA, "571.3476")
  checkEquals(actual, expected)
}

test.3d.data <- function() {
   conn1 <- blpConnect("COM")
   conn2 <- blpConnect("rcom")
   
   securities <- c("RYA ID Equity", "OCN US Equity", "MSFT US Equity")
   fields <- c("PX_LAST", "CUR_MKT_CAP")
   
   start <- timeDate("2009-01-05")
   end <- timeDate("2009-01-07")
   
   
   comGetHistoricalData(conn1, securities, fields, start=start, end=end)
   comGetHistoricalData(conn2, securities, fields, start=start, end=end)
   
   # ]  39479.0000  39482.0000  39479.0000  39482.0000  39479.0000  39482.0000
   #  [7]      3.6000      3.5400      3.7583      3.9329     30.4498     30.1900
   # [13]   5366.8911   5277.4429    390.1707    408.3037 292439.2813 289944.1563
   # cat("2008")
   # print(blp(conn1, securities, fields, start="2008-02-01", end="2008-02-04", retval="raw"))
   # print(blp(conn2, securities, fields, start="2008-02-01", end="2008-02-04", retval="raw"))
   
}