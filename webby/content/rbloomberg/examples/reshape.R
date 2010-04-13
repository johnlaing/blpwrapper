library(RBloomberg)
conn <- blpConnect()

Sys.setenv(TZ="GMT")
start.date <- as.POSIXct("2009-01-01")
end.date <- as.POSIXct("2009-01-07")

df <- bdh(conn, c("AMZN US Equity", "OCN US Equity"), c("PX_LAST", "BID"), start.date, end.date)
df

t <- unstack(df, PX_LAST~ticker)
rownames(t) <- unique(df$date)
t

t <- unstack(df, BID~ticker)
rownames(t) <- unique(df$date)
t

reshape(df, direction="wide", timevar="date", idvar="ticker")
reshape(df, direction="wide", timevar="date", idvar="ticker", drop="BID", new.row.names=unique(df$ticker))

blpDisconnect(conn)
