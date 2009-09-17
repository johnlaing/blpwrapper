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
   checkEquals(as.character(class(conn)), "COMIDispatch")
}

test.com.iface <- function() {
   conn <- blpConnect("COM")
   checkEquals(as.character(class(conn)), "COMIDispatch")
}

test.rcom.iface <- function() {
   conn <- blpConnect("rcom")
   checkEquals(class(conn), "COMObject")
}

test.java.iface <- function() {
   conn <- blpConnect("Java")
   checkEquals(class(conn), "JavaObject")
}