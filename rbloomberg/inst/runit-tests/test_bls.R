test.dvd.hist <- function() {
  conn <- blpConnect("Java")
  security <- c("BKIR ID Equity")
  field <- c("DVD_HIST")

  result <- bls(conn, security, field)
}

test.combine.multiple.bls <- function() {
  conn <- blpConnect("Java")
  securities <- c("UKX Index", "SPX Index")
  field <- c("INDX_MEMBERS", "INDX_MEMBERS2")

  result <- bls(conn, securities, field)
}
