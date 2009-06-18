blpConnect <- function(iface="COM", timeout = 12000,
                       show.days = "week", na.action = "na",
                       periodicity = "daily"){
                          
  if (iface == 'COM') {
     conn <- try(comCreateObject("Bloomberg.Data.1"), silent=TRUE)
     
     SHOWDAYS <- c(trading=0, week=64, all=128)
     NAACTION <- c(bloomberg.handles=0, previous.days=256, na=512)
     PERIODICITY <- c(daily=1, weekly=6, monthly=7, annual=9)
     
     if (class(conn) == 'try-error') {
        stop(paste("Seems like this is not a Bloomberg Workstation: ", conn))
     }
     
     conn[["Timeout"]] <- timeout
     conn[["DisplayNonTradingDays"]] <- SHOWDAYS[show.days]
     conn[["NonTradingDayValue"]] <- NAACTION[na.action]
     conn[["Periodicity"]] <- PERIODICITY[periodicity]
        
     return(conn)
     
  } else if (iface == 'C') {
     stop("The C interface is not yet implemented.")
     
  } else {
     stop("iface must be 'COM' or 'C'!")
  }
}
