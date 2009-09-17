check.comSubscribe <- function(expected, securities, fields, override_fields = NULL, overrides = NULL, ...) {
   connections <- list(blpConnect("COM"), blpConnect("rcom"))
   actual <- lapply(connections, "comSubscribe", securities, fields, override_fields = override_fields, overrides = overrides, ...)
   lapply(actual, checkEquals, expected, tolerance = 0.000005)
   lapply(connections, "blpDisconnect")
}

test.comSubscribe.basic.character.results <- function() {
  securities <- c("RYA ID Equity", "OCN US Equity")
  fields <- c("NAME", "COUNTRY")

  expected <- c("RYANAIR HOLDINGS PLC", "OCWEN FINANCIAL CORP", "IR", "US")
  
  check.comSubscribe(expected, securities, fields)
}

test.comSubscribe.numeric.with.overrides <- function() {
   securities <- c("RYA ID Equity", "OCN US Equity", "YHOO US Equity")
   fields <- c("LT_DEBT_TO_COM_EQY")
   override_fields <- c("EQY_FUND_DT")
   overrides <- c("20051231")

   expected <- c(76.53, 44.42, 8.76)
   
   check.comSubscribe(expected, securities, fields, override_fields, overrides)
}
