library(RBloomberg)
conn <- blpConnect()


security <- c("BKIR ID Equity")
field <- c("DVD_HIST")

bds(conn, security, field)[1:5,]

security <- "TYA Comdty"
field <- "FUT_DELIVERABLE_BONDS"

bds(conn, security, field)[1:5,]

security <- "UKX Index"
field <- "INDX_MEMBERS"

bds(conn, security, field)[1:5,]

securities <- c("UKX Index", "SPX Index")
fields <- c("INDX_MEMBERS", "INDX_MEMBERS2", "INDX_MEMBERS3")

bds(conn, securities, fields)[c(1:5, 350:355),]

