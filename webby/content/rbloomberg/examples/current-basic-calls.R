source("init.R")

sink("current-basic-calls-output.txt")
### @export "minimal"
blp(conn, "RYA ID Equity", "PX_LAST")
### @export "lists"
blp(conn, c("IBM US Equity", "MSFT US Equity"), c("NAME", "PX_LAST"))
### @export "variables"
securities <- "ED1 Comdty"
fields <- c("NAME", "PX_LAST", "OPEN")
blp(conn, securities, fields)
### @end
sink()