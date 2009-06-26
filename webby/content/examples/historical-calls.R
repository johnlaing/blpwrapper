source("init.R")

sink("basic-intraday.out")
### @export "basic-intraday"
blp(conn, "RYA ID Equity", "PX_LAST", Sys.Date() - 10)
blp(conn, "RYA ID Equity", "PX_LAST", "2009-01-01", "2009-01-07")
### @end
sink()
