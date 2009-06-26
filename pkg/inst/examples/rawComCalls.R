conn <- comCreateObject("Bloomberg.Data.1")

# Optional, set a timeout.
comSetProperty(conn, "Timeout", 12000)

# Basic "Hello, World!"
comGetProperty(conn, "BLPSubscribe", "RYA ID Equity", "TODAY_DT")

# These all work too...
comGetProperty(conn, "BLPSubscribe", c("RYA ID Equity"), c("TODAY_DT"))
comGetProperty(conn, "BLPSubscribe", Security = "RYA ID Equity", Fields = "TODAY_DT")

comGetProperty(conn, "BLPSubscribe", Security=c("RYA ID Equity"), 
   Fields=c("NAME", "COUNTRY", "PX_LAST"))

# Get historical data with various periodicities.
# Try both ways of setting properties.
comSetProperty(conn, "Periodicity", 1)
comGetProperty(conn, "BLPGetHistoricalData", Security=c("RYA ID Equity"), Fields=c("PX_LAST"), 
   StartDate=as.POSIXct("2008-01-01"))

conn[["Periodicity"]] <- 6
comGetProperty(conn, "BLPGetHistoricalData", Security=c("RYA ID Equity"), Fields=c("PX_LAST"), 
   StartDate=as.POSIXct("2008-01-01"))

comSetProperty(conn, "Periodicity", 7)
comGetProperty(conn, "BLPGetHistoricalData", Security=c("RYA ID Equity"), Fields=c("PX_LAST"), 
   StartDate=as.POSIXct("2008-01-01"))

# Examples of fetching prices in different currencies using BLPGetHistoricalData2
comGetProperty(conn, "BLPGetHistoricalData", Security = "RYA ID Equity", Fields = "PX_LAST", 
   StartDate = as.POSIXct("2009-01-01"), EndDate = as.POSIXct("2009-02-01"))
comGetProperty(conn, "BLPGetHistoricalData2", Security = "RYA ID Equity", Fields = "PX_LAST", 
   StartDate = as.POSIXct("2009-01-01"), Currency = "USD", EndDate = as.POSIXct("2009-02-01"))

# Intraday tick example.
comGetProperty(conn, "BLPGetHistoricalData", Security="ED1 Comdty", Fields=c("BID","ASK"), 
   StartDate=Sys.time() - 3600, EndDate = Sys.time(), BarSize=as.integer(0))
