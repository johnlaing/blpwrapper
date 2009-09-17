check.blp <- function(expected, securities, fields, override_fields = NULL, overrides = NULL, ...) {
   connections <- list(blpConnect("COM"), blpConnect("rcom"))
   actual <- lapply(connections, "blp", securities, fields, override_fields = override_fields, overrides = overrides, ...)
   print(actual) # TODO remove
   lapply(actual, checkEquals, expected, tolerance = 0.000005)
   lapply(connections, "blpDisconnect")
}

test.basic <- function() {
  securities <- c("RYA ID Equity", "OCN US Equity")
  fields <- c("NAME", "COUNTRY")
  
  expected <- data.frame(
    NAME=c("RYANAIR HOLDINGS PLC", "OCWEN FINANCIAL CORP"), 
    COUNTRY=c("IR", "US"),
    row.names = c("RYA ID EQUITY", "OCN US EQUITY")
  )
  
  check.blp(expected, securities, fields)
}

test.3d.historic <- function() {
   conn1 <- blpConnect("COM")
   conn2 <- blpConnect("rcom")
   
   securities <- c("RYA ID Equity", "OCN US Equity", "MSFT US Equity")
   fields <- c("PX_LAST", "CUR_MKT_CAP")
   
   cat("2009")
   print(blp(conn1, securities, fields, start="2009-01-05", end="2009-01-07", retval="matrix"))
   print(blp(conn2, securities, fields, start="2009-01-05", end="2009-01-07", retval="matrix"))
   
   cat("2008")
   print(blp(conn1, securities, fields, start="2008-02-01", end="2008-02-04", retval="raw"))
   print(blp(conn2, securities, fields, start="2008-02-01", end="2008-02-04", retval="raw"))
}

test.historical.numeric <- function() {
   conn1 <- blpConnect()
   conn2 <- blpConnect("rcom")
   
  securities <- c("RYA ID Equity", "OCN US Equity", "YHOO US Equity")
  fields <- c("CUR_MKT_CAP")
  #   
  # expected <- data.matrix(data.frame(
  #   "DATETIME" = c(1201824000, 1202083200),
  #   "RYA ID EQUITY" = c(5366.891, 5277.443),
  #   "OCN US EQUITY" = c(390.1707, 408.3037),
  #   "YHOO US EQUITY" = c(37928.28, 39197.90),
  #   check.names = FALSE
  # ))
  
  start <- "2008-02-01"
  end <- "2008-02-04"
  
  
  result1 <- blp(conn1, securities, fields, start=start, end=end)
  result2 <- blp(conn2, securities, fields, start=start, end=end)

  # check.blp(expected, securities, fields, start="2008-02-01", end="2008-02-04", retval="matrix")
}

test.CUST_TRR_RETURN_HOLDING_PER <- function() {
  securities <- c("RYA ID Equity", "OCN US Equity")
  fields <- c("CUST_TRR_RETURN_HOLDING_PER")
  override_fields <- c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY")
  overrides <- c("20080103", "20080110", "PRC")

  expected <- data.frame(
     CUST_TRR_RETURN_HOLDING_PER=c(-9.8266, -17.2962), 
     row.names = c("RYA ID EQUITY", "OCN US EQUITY")
   )

  check.blp(expected, securities, fields, override_fields, overrides)
}

# EQY_FUND_DT, on its own, gives you the value at the end of the fiscal year
# which the date, in this case 20051231, falls into. So, if you call this
# for companies with different fiscal year ends, you will get results
# relating to different dates.
test.LT_DEBT_TO_COM_EQY <- function() {
   securities <- c("RYA ID Equity", "OCN US Equity", "YHOO US Equity")
   fields <- c("LT_DEBT_TO_COM_EQY")
   override_fields <- c("EQY_FUND_DT")
   overrides <- c("20051231")
   
   expected <- data.frame(
     LT_DEBT_TO_COM_EQY=c(76.53, 44.42, 8.76), 
     row.names = c("RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
   )
   
   check.blp(expected, securities, fields, override_fields, overrides)
}
