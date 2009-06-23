library(RBloomberg)
conn <- blpConnect()

sink("current-basic-calls-output.txt")
### @export "minimal"
blpGetData(conn, "RYA ID Equity", "PX_LAST")
### @export "lists"
blpGetData(conn, c("IBM US Equity", "MSFT US Equity"), c("NAME", "PX_LAST"))
### @export "variables"
securities <- "ED1 Comdty"
fields <- c("NAME", "PX_LAST", "OPEN")
blpGetData(conn, securities, fields)
### @end
sink()