library(RBloomberg)
conn <- blpConnect()

bdh(conn, "GOLDS Comdty", "PX_LAST", "20090101", "20090107")

start.date <- as.POSIXct("2009-01-01")
end.date <- as.POSIXct("2009-01-07")
bdh(conn, "GOLDS Comdty", "PX_LAST", start.date, end.date)

bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)

library(zoo)
result <- bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)
zoo(result, order.by = rownames(result))

blpDisconnect(conn)
