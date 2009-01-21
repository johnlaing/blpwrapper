as.COMDate <- function(x, date1904 = FALSE){
  as.COMDate.chron(as.chron(x), date1904)
}

as.COMDate.chron <- function(x, date1904 = FALSE){
  orig0 <- attr(x, "origin")
  orig1 <- as.Date(ISOdate(orig0[3], orig0[1], orig0[2]))
  if (date1904)
    dif <- orig1 - as.Date("1903-12-31") + 1
  else
    dif <- orig1 - as.Date("1900-01-01") + 2
  y <- as.numeric(x) + as.numeric(dif)
  class(y) <- "COMDate"
  y
}

