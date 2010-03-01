library(RBloomberg)
conn <- blpConnect()
tick(conn, "RYA ID Equity", "TRADE", "2010-03-01 09:00:00.000", "2010-03-01 09:10:00.000")

