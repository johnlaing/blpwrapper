library(RBloomberg)
conn <- blpConnect()
bar(conn, "RYA ID Equity", "TRADE", "2011-08-16 09:00:00.000", "2011-08-16 15:00:00.000", "60")

