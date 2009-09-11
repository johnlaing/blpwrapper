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
   checkEquals(class(conn)[1], "COMIDispatch")
}

test.com.iface <- function() {
   conn <- blpConnect("COM")
   checkEquals(class(conn)[1], "COMIDispatch")
}

test.rcom.iface <- function() {
   conn <- blpConnect("rcom")
   checkEquals(class(conn), "COMObject")
}

test.java.iface <- function() {
   conn <- blpConnect("Java")
   checkEquals(class(conn), "JavaObject")
}