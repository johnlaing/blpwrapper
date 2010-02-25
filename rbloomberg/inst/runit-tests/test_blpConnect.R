test.invalid.iface <- function() {
   checkException(
      blpConnect("rubbish")
   )
}

test.future.iface <- function() {
   checkException(
      blpConnect("C")
   )
}

test.default.iface <- function() {
   conn <- blpConnect()
   blpDisconnect(conn)
}

test.java.iface <- function() {
   conn <- blpConnect("Java")
   blpDisconnect(conn)
}
