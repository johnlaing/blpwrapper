library(RBloomberg)
conn <- blpConnect()

blh(conn, "GOLDS Comdty", "PX_LAST", "20090101", "20090107")
result <- blh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)

result

library(zoo)
zoo(result, order.by = rownames(result))

blpDisconnect(conn)
