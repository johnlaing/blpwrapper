library(RBloomberg)
conn <- blpConnect()

### @export "minimal"
blpGetData(conn, "RYA ID Equity", "PX_LAST")
### @export "lists"
blpGetData(conn, c("IBM US Equity", "MSFT US Equity"), c("NAME", "PX_LAST"))
### @export "variables"
securities <- "ED1 Comdty"
fields <- c("NAME", "DESCRIPTION", "PX_LAST", "OPEN")
blpGetData(conn, securities, fields)