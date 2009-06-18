# Test to show how you can access Bloomberg just using rcom calls. (needs RUnit for checkEquals)
test.bloomberg <- function() {
  # Connect to Bloomberg via COM API
  conn <- comCreateObject("Bloomberg.Data.1")
  
  # Optional, set a timeout.
  comSetProperty(conn, "Timeout", 12000)
  
  # Basic "Hello, World!"
  comGetProperty(conn, "BLPSubscribe", "RYA ID Equity", "TODAY_DT")
  
  # These all work too...
  comGetProperty(conn, "BLPSubscribe", c("RYA ID Equity"), c("TODAY_DT"))
  comGetProperty(conn, "BLPSubscribe", Security = "RYA ID Equity", Fields = "TODAY_DT")

  blp_data <- comGetProperty(conn, "BLPSubscribe", Security=c("RYA ID Equity"), Fields=c("NAME", "COUNTRY", "PX_LAST"))
  checkEquals("rcomdata", class(blp_data))
  
  # Get historical data with various periodicities.
  # Try both ways of setting properties.
  comSetProperty(conn, "Periodicity", 1)
  daily_hist <- comGetProperty(conn, "BLPGetHistoricalData", Security=c("RYA ID Equity"), Fields=c("PX_LAST"), StartDate=as.POSIXct("2008-01-01"))

  conn[["Periodicity"]] <- 6
  weekly_hist <- comGetProperty(conn, "BLPGetHistoricalData", Security=c("RYA ID Equity"), Fields=c("PX_LAST"), StartDate=as.POSIXct("2008-01-01"))
  
  comSetProperty(conn, "Periodicity", 7)
  monthly_hist <- comGetProperty(conn, "BLPGetHistoricalData", Security=c("RYA ID Equity"), Fields=c("PX_LAST"), StartDate=as.POSIXct("2008-01-01"))
  
  # Tests to ensure periodicity property is being respected.
  checkEquals(4.5, length(daily_hist) / length(weekly_hist), tolerance = 0.5)
  checkEquals(20, length(daily_hist) / length(monthly_hist), tolerance = 3)
  
}
