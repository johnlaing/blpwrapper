# runTestFile("blpGetDataTest.R")

test.basic <- function() {
  conn <- blpConnect()
  
  # Fetch static data for multiple securities and multiple fields.
  checkEquals(
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity"), c("NAME", "COUNTRY")),
    data.frame(
      NAME=c("RYANAIR HOLDINGS PLC", "BEAR STEARNS COMPANIES INC"), 
      COUNTRY=c("IR", "US"),
      row.names = c("RYA ID EQUITY", "BSC US EQUITY")
    )
  )
  
  checkEquals(
    # We are cheating here and returning a "matrix" since that is easier for
    # us to construct than the default zoo return type.
    blpGetData(conn, c("RYA ID Equity", "BSC US Equity", "YHOO US Equity"), "CUR_MKT_CAP", 
    start=as.chron(as.POSIXct("2008-02-01", tz="GMT")), 
    end=as.chron(as.POSIXct("2008-02-04", tz="GMT")), retval="matrix"),
    
    data.matrix(data.frame(
      "[DATETIME]" = c(39479, 39482),
      "RYA ID EQUITY" = c(5366.891, 5277.443),
      "BSC US EQUITY" = c(12647.49, 12390.16),
      "YHOO US EQUITY" = c(37928.28, 39197.90),
      check.names = FALSE
    )),
    tolerance = 0.000005
  )
  
  blpDisconnect(conn)
}
