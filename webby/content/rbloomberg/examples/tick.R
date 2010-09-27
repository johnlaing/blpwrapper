library(RBloomberg)
conn <- blpConnect(log.level = "finest")
tick(conn, "RYA ID Equity", "TRADE", "2010-09-21 09:00:00.000", "2010-09-21 09:10:00.000")

tick(conn, "RYA ID Equity", c("TRADE", "BID_BEST"), "2010-09-21 09:00:00.000", "2010-09-21 09:10:00.000")

