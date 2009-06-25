test.java.basic <- function() {
  conn <- blpConnect("Java")
  blp(conn, c("IBM US Equity", "MSFT US Equity"), c("PX_LAST", "NAME"), retval="raw")
}
