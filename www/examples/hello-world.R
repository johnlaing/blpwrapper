### @export "library"
library(RBloomberg)
### @export "connect"
conn <- blpConnect()
### @export "basic-request"
blpGetData(conn, "RYA ID Equity", "NAME")