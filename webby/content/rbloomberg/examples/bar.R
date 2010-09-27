library(RBloomberg)
conn <- blpConnect()
bar(conn, "RYA ID Equity", "TRADE", "2010-09-21 09:00:00.000", "2010-09-21 15:00:00.000", "60")

