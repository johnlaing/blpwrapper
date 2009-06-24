test.java.basic <- function() {
  conn <- blpConnect("Java")
  
  blp(conn, "RYA ID Equity", "NAME")
  
  # This works, it's just slow:
  # blp(conn, "SPX INDEX", "INDX_MEMBERS")
}
