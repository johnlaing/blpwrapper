test.basic <- function() {
  conn <- blpConnect("Java")
  securities <- c("RYA ID EQUITY", "OCN US EQUITY")
  fields <- c("NAME", "COUNTRY")

  mtx <- array(c("RYANAIR HOLDINGS PLC", "OCWEN FINANCIAL CORP", "IR", "US"), c(2,2))
  colnames(mtx) <- fields
  rownames(mtx) <- securities

  expected <- data.frame(mtx)
  actual <- blp(conn, securities, fields)
  checkEquals(actual, expected)
}

test.CUST_TRR_RETURN_HOLDING_PER <- function() {
  conn <- blpConnect("Java")
  securities <- c("RYA ID EQUITY", "OCN US EQUITY")
  fields <- c("CUST_TRR_RETURN_HOLDING_PER")
  override_fields <- c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY")
  overrides <- c("20080103", "20080110", "PRC")

  m <- array(c(-9.8266, -17.2962), c(2,1))
  rownames(m) <- securities
  colnames(m) <- fields
  expected <- data.frame(m)

  actual <- blp(conn, securities, fields, override_fields, overrides)
  checkEquals(actual, expected, tolerance = 0.000005)
}

test.LT_DEBT_TO_COM_EQY <- function() {
  conn <- blpConnect("Java")
  securities <- c("RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
  fields <- c("LT_DEBT_TO_COM_EQY")
  override_fields <- c("EQY_FUND_DT")
  overrides <- c("20051231")


  m <- array(c(76.53, 44.42, 8.76), c(3,1))
  rownames(m) <- securities
  colnames(m) <- fields
  expected <- data.frame(m)

  actual <- blp(conn, securities, fields, override_fields, overrides)
  checkEquals(actual, expected, tolerance = 0.000005)
}
