### @export "library"
library(RBloomberg)
### @export "connect"
conn <- blpConnect()
### @export "basic-request"
blp(conn, "RYA ID Equity", "NAME")