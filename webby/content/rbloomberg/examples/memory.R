library(RBloomberg)

add.equity.label <- function(ticker) {
  paste(ticker, "Equity")
}

conn <- blpConnect(jvm.params = c("-Xmx256m", "-Xloggc:rbloomberg.gc", "-XX:+PrintGCDetails"))

tickers <- bds(conn, "UKX Index", "INDX_MEMBERS")[,1]
tickers <- add.equity.label(tickers)

x <- bdp(conn, tickers, "PX_LAST")
blpDisconnect(conn)

