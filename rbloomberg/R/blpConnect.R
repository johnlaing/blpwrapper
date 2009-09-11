blpConnect <- function(iface="COM", timeout = 12000,
                       show.days = "week", na.action = "na",
                       periodicity = "daily"){

  valid.interfaces <- c('COM', 'rcom', 'Java')
  future.interfaces <- c('C')
  
  if (iface %in% future.interfaces) {
     stop(paste("Requested interface", iface, "is not yet implemented."))
  }
  
  if (!(iface %in% valid.interfaces)) {
     msg <- paste(
        "Requsted interface", 
        iface, 
        "is not valid! Valid interfaces are ", 
        do.call("paste", as.list(valid.interfaces))
      )
     stop(msg)
  }
  
  fn.name <- paste("blpConnect", iface, sep=".")
  fn.call <- call(fn.name, timeout, show.days, na.action, periodicity)
  eval(fn.call)
}

blpConnect.rcom <- function(timeout, show.days, na.action, periodicity) {
   library(rcom)
   conn <- comCreateObject("Bloomberg.Data.1")

   SHOWDAYS <- c(trading=0, week=64, all=128)
   NAACTION <- c(bloomberg.handles=0, previous.days=256, na=512)
   PERIODICITY <- c(daily=1, weekly=6, monthly=7, annual=9)

   conn[["Timeout"]] <- timeout
   conn[["DisplayNonTradingDays"]] <- SHOWDAYS[show.days]
   conn[["NonTradingDayValue"]] <- NAACTION[na.action]
   conn[["Periodicity"]] <- PERIODICITY[periodicity]
   
   return(conn)
}

# RDCOMClient
blpConnect.COM <- function(timeout, show.days, na.action, periodicity) {
   library(RDCOMClient)
   conn <- COMCreate("Bloomberg.Data.1")

   SHOWDAYS <- c(trading=0, week=64, all=128)
   NAACTION <- c(bloomberg.handles=0, previous.days=256, na=512)
   PERIODICITY <- c(daily=1, weekly=6, monthly=7, annual=9)

   conn[["Timeout"]] <- timeout
   conn[["DisplayNonTradingDays"]] <- SHOWDAYS[show.days]
   conn[["NonTradingDayValue"]] <- NAACTION[na.action]
   conn[["Periodicity"]] <- PERIODICITY[periodicity]
   
   return(conn)
}

blpConnect.Java <- function(timeout, show.days, na.action, periodicity) {
   java_init() # Start the JVM, load Bloomberg API classes.
   conn <- create_session_and_service()
}