library(RBloomberg)

conn <- blpConnect(throw.ticker.errors = FALSE)
bdp(conn, "THIS IS NOT A VALID TICKER", "NAME")

securities <- c("AMZN US Equity", "OCN US Equity", "123456 XX Equity")
fields <- c("NAME", "PX_LAST", "TIME", "SETTLE_DT")
bdp(conn, securities, fields)

blpDisconnect(conn)



conn <- blpConnect(throw.ticker.errors = TRUE)
try(bdp(conn, "THIS IS NOT A VALID TICKER", "NAME"))
blpDisconnect(conn)


