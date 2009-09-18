check.blp <- function(expected, securities, fields, override_fields = NULL, overrides = NULL, ...) {
   connections <- list(blpConnect("COM"), blpConnect("rcom"))
   actual <- lapply(connections, "blp", securities, fields, override_fields = override_fields, overrides = overrides, ...)
   lapply(actual, checkEquals, expected, tolerance = 0.000005)
   lapply(connections, "blpDisconnect")
}

test.basic <- function() {
  securities <- c("RYA ID EQUITY", "OCN US EQUITY")
  fields <- c("NAME", "COUNTRY")
  
  mtx <- array(c("RYANAIR HOLDINGS PLC", "OCWEN FINANCIAL CORP", "IR", "US"), c(2,2))
  colnames(mtx) <- fields
  rownames(mtx) <- securities
  
  expected <- data.frame(mtx, stringsAsFactors = FALSE)
  
  check.blp(expected, securities, fields, retval="data.frame")
  check.blp(expected, securities, fields)
}

test.CUST_TRR_RETURN_HOLDING_PER <- function() {
  securities <- c("RYA ID EQUITY", "OCN US EQUITY")
  fields <- c("CUST_TRR_RETURN_HOLDING_PER")
  override_fields <- c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY")
  overrides <- c("20080103", "20080110", "PRC")
  
  m <- array(c(-9.8266, -17.2962), c(2,1))
  rownames(m) <- securities
  colnames(m) <- fields
  expected <- data.frame(m)

  check.blp(expected, securities, fields, override_fields, overrides)
}

test.LT_DEBT_TO_COM_EQY <- function() {
   securities <- c("RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
   fields <- c("LT_DEBT_TO_COM_EQY")
   override_fields <- c("EQY_FUND_DT")
   overrides <- c("20051231")
   
   
   m <- array(c(76.53, 44.42, 8.76), c(3,1))
   rownames(m) <- securities
   colnames(m) <- fields
   expected <- data.frame(m)
   
   check.blp(expected, securities, fields, override_fields, overrides)
}
