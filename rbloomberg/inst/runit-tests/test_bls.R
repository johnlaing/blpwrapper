test.dvd.hist <- function() {
  conn <- blpConnect("Java")
  security <- c("BKIR ID Equity")
  field <- c("DVD_HIST")

  result <- bls(conn, security, field)
  print(result)
}

test.fut.deliverable.bonds <- function() {
  conn <- blpConnect("Java")
  security <- "TYA Comdty"
  field <- "FUT_DELIVERABLE_BONDS"

  result <- bls(conn, security, field)
  print(result)
}

test.index.members <- function() {
  conn <- blpConnect("Java")
  security <- "UKX Index"
  field <- "INDX_MEMBERS"

  result <- bls(conn, security, field)
  print(result)
}

test.combine.multiple.bls <- function() {
  conn <- blpConnect("Java")
  securities <- c("UKX Index", "SPX Index")
  field <- c("INDX_MEMBERS", "INDX_MEMBERS2")

  result <- bls(conn, securities, field)
  print(result)
}
