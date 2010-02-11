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

  expected <- c("1230768000", "1230854400", "1230768000", "1230854400", NA, "3.15", NA, "5.4868", NA, "4640.0972", NA, "571.3476")
  checkEquals(actual, expected)
}
