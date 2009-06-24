test.java.basic <- function() {
  conn <- blpConnect("Java")
  
  blp(conn, "RYA ID Equity", "NAME")
}
