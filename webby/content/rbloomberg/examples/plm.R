library(RBloomberg)
conn <- blpConnect()

Sys.setenv(TZ="GMT")
start.date <- as.POSIXct("2009-01-01")
end.date <- as.POSIXct("2009-01-07")

library(plm)
df <- bdh(conn, c("AMZN US Equity", "OCN US Equity"), c("PX_LAST", "BID"), start.date, end.date)
ps <- pdata.frame(df)
as.matrix(ps$PX_LAST)
as.matrix(ps$PX_LAST, idbyrow=FALSE)

blpDisconnect(conn)
