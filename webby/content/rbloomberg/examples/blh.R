library(Rbbg)
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

df <- bdh(conn, c("AMZN US Equity", "GOOG US Equity", "MSFT US Equity"), 
    c("PX_LAST", "BID"), start.date, end.date)
df
na.omit(df)

bdh(conn, c("AMZN US Equity"), c("PX_LAST", "BID"), start.date, end.date, 
    always.display.tickers = TRUE)

bdh(conn, c("AMZN US Equity"), c("PX_LAST", "BID"), start.date, end.date, 
    always.display.tickers = TRUE, dates.as.row.names = FALSE)

bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090401", "20090410")

# We should get NULL back when there's no data...
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405")

# To return rows for all requested dates, even when they have no data...
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405", 
    include.non.trading.days = TRUE)

# This is equivalent to...
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405",
    option_names = c("nonTradingDayFillOption", "nonTradingDayFillMethod"),
    option_values = c("ALL_CALENDAR_DAYS", "NIL_VALUE"))

# Consult API documentation for other available option values.
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405",
    option_names = c("nonTradingDayFillOption", "nonTradingDayFillMethod"),
    option_values = c("ALL_CALENDAR_DAYS", "PREVIOUS_VALUE"))

blpDisconnect(conn)
