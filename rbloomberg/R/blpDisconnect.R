blpDisconnect <- function(conn) {
  conn$close()
  gc(verbose=FALSE)
}
