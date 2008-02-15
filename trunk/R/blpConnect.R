blpConnect <- function(iface="COM", timeout = 12000,
                       show.days = "week", na.action = "na",
                       periodicity = "daily"){
  if(!iface %in% c("COM","C")){
    stop("iface must be 'COM' or 'C'.")
  }
  if(iface == "C"){
    ## Class: BlpCConnect
    stop("The C interface is not yet impliemented.")
  }
  conn <<- try(conn <- COMCreate("Bloomberg.Data.1"), silent=TRUE);
  SHOWDAYS <- c(trading=0, week=64, all=128)
  NAACTION <- c(bloomberg.handles=0, previous.days=256, na=512)
  PERIODICITY <- c(daily=1, weekly=6, monthly=7, annual=9)
  if (class(conn) == "try-error") {
    warning(paste("Seems like this is not a Bloomberg Workstation: ", conn));
  } else {
    conn[["Timeout"]] <<- timeout;
    conn[["DisplayNonTradingDays"]] <<- SHOWDAYS[show.days];
    conn[["NonTradingDayValue"]] <<- NAACTION[na.action];
    conn[["Periodicity"]] <<- PERIODICITY[periodicity];
  }
  class(conn) <- c("BlpCOMConnect")
  return(conn)
}

