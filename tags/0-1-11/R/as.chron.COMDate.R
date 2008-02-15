as.chron.COMDate <- function(x, date1904 = FALSE, ...) {
  if(date1904){
    orig <- c(month=12, day=31, year=1903);
    off <- 0;
  }
  else {
    orig <- c(month=12, day=31, year=1899);
    off <- 1;
  }
  y <- chron(as.numeric(x) - off,
             origin = c(month=12, day=31, year=1899))
  chron(y, origin = c(month=1, day=1, year=1970))
}

