library(RBloomberg)
conn <- blpConnect()


security <- c("BKIR ID Equity")
field <- c("DVD_HIST")

bls(conn, security, field)[1:5,]

security <- "TYA Comdty"
field <- "FUT_DELIVERABLE_BONDS"

bls(conn, security, field)[1:5,]

security <- "UKX Index"
field <- "INDX_MEMBERS"

bls(conn, security, field)[1:5,]

securities <- c("UKX Index", "SPX Index")
fields <- c("INDX_MEMBERS", "INDX_MEMBERS2", "INDX_MEMBERS3")

bls(conn, securities, fields)[c(1:5, 350:355),]

