library(RBloomberg)
conn <- blpConnect()

sink("basic-intraday.out")
### @export "basic-intraday"
blpGetData(conn, "RYA ID Equity", "PX_LAST", Sys.Date() - 10)
blpGetData(conn, "RYA ID Equity", "PX_LAST", "2009-01-01", "2009-01-07")
### @end
sink()


sink("intraday-overrides.out")
### @export "intraday-overrides"
blpGetData(conn, "RYA ID Equity", "PX_LAST", 
   "2009-01-01", "2009-01-07", 
   override_fields = c("EQY_FUND_CRNCY"), overrides = c("GBP")
)
### @end
sink()
