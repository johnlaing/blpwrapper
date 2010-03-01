library(RBloomberg)
conn <- blpConnect()
bar(conn, "RYA ID Equity", "TRADE", "2010-03-01 09:00:00.000", "2010-03-01 15:00:00.000", "60")

