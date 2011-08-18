library(RBloomberg)
conn <- blpConnect(log.level = "finest")
tick(conn, "RYA ID Equity", "TRADE", "2011-08-16 09:30:00.000", "2011-08-16 09:40:00.000")

tick(conn, "RYA ID Equity", c("TRADE", "BID_BEST"), "2011-08-16 09:00:00.000", "2011-08-16 09:10:00.000")

