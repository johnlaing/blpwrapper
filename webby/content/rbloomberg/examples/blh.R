library(RBloomberg)
conn <- blpConnect()

bdh(conn, "GOLDS Comdty", "PX_LAST", "20090101", "20090107")

Sys.setenv(TZ="GMT")
start.date <- as.POSIXct("2009-01-01")
end.date <- as.POSIXct("2009-01-07")

bdh(conn, "GOLDS Comdty", "PX_LAST", start.date, end.date)

bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)

library(zoo)
result <- bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)
zoo(result, order.by = rownames(result))

bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 366, 
    option_names = "periodicitySelection", option_values = "MONTHLY")

bdh(conn, c("AMZN US Equity", "GOOG US Equity"), c("PX_LAST", "BID"), start.date, end.date)

bdh(conn, c("AMZN US Equity"), c("PX_LAST", "BID"), start.date, end.date, 
    always.display.tickers = TRUE)

bdh(conn, c("AMZN US Equity"), c("PX_LAST", "BID"), start.date, end.date, 
    always.display.tickers = TRUE, dates.as.row.names = FALSE)

blpDisconnect(conn)
