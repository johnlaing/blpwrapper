library(RBloomberg)
conn <- blpConnect()

bdp(conn, "AMZN US Equity", "NAME")

securities <- c("AMZN US Equity", "OCN US Equity")
fields <- c("NAME", "PX_LAST", "TIME", "SETTLE_DT", "HAS_CONVERTIBLES") # Demo different return data types.
bdp(conn, securities, fields)

securities <- c("AMZN US Equity", "OCN US Equity")
fields <- c("CUST_TRR_RETURN_HOLDING_PER")
override_fields <- c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY")
overrides <- c("20090601", "20091231", "PRC")
bdp(conn, securities, fields, override_fields, overrides)

securities <- c("RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
fields <- c("LT_DEBT_TO_COM_EQY")
override_fields <- c("EQY_FUND_DT")
overrides <- c("20051231")
bdp(conn, securities, fields, override_fields, overrides)

override_fields <- c("EQY_FUND_DT")
overrides <- c("20061231")
bdp(conn, securities, fields, override_fields, overrides)

bdp(conn, "/SEDOL1/2292612 EQUITY", "NAME")

blpDisconnect(conn)

