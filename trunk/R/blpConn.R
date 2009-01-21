## ISSUE: why can't we read four of the BloombergData control's properties? Not an RDCOMClient issue
## because we get it with VBA too, eg the following:
##  Dim objDataControl As BLP_DATA_CTRLLib.BlpData
##  Set objDataControl = New BlpData
##  Debug.Print objDataControl.DisplayNonTradingDays
##  Debug.Print objDataControl.NonTradingDayValue
##  Debug.Print objDataControl.Periodicity
##  Debug.Print objDataControl.ReverseChronological
## returns a compile error "Invalid use of property".. but works for all other props.
## Maybe bloomberg makes these write-only?

blpConn <- function(conn.name=".blpConn"){  
  if(exists(conn.name, envir=.GlobalEnv))
    return(invisible(eval(as.name(conn.name))))
  conn <- COMCreate("Bloomberg.Data.1")
   conn <- list(COMIDispatch=COMCreate("Bloomberg.Data.1"))
  conn$LocalProperties$ActivateRealtime      <- conn$COMIDispatch[["ActivateRealtime"]]    ## TRUE
  conn$LocalProperties$AutoRelease           <- conn$COMIDispatch[["AutoRelease"]]         ## TRUE
  conn$LocalProperties$DataOnlyInEvent       <- conn$COMIDispatch[["DataOnlyInEvent"]]     ## FALSE
  conn$LocalProperties$DisplayNonTradingDays <- 0     ## WRITE-ONLY? (Omit = 0 Week = 64 AllCalendar = 128)
  conn$LocalProperties$NonTradingDayValue    <- 512   ## WRITE-ONLY? (PreviousDays = 256 ShowNoNumber = 512)
  conn$LocalProperties$NumberPoints          <- conn$COMIDispatch[["NumberPoints"]]        ## 99999
  conn$LocalProperties$Periodicity           <- 1     ## WRITE-ONLY? (bbDaily = 1 bbWeekly = 6 bbMonthly = 7 bbQuarterly = 8 bbYearly=9)
  conn$LocalProperties$PollingTime           <- conn$COMIDispatch[["PollingTime"]]         ## 1000
  conn$LocalProperties$Port                  <- conn$COMIDispatch[["Port"]]                ## 8194
  conn$LocalProperties$QueueEvents           <- conn$COMIDispatch[["QueueEvents"]]         ## FALSE
  conn$LocalProperties$QuoteGPA              <- conn$COMIDispatch[["QuoteGPA"]]            ## FALSE
  conn$LocalProperties$RetryCount            <- conn$COMIDispatch[["RetryCount"]]          ## 0 
  conn$LocalProperties$ReverseChronological  <- FALSE ## WRITE-ONLY 
  conn$LocalProperties$SendQueueSize         <- conn$COMIDispatch[["SendQueueSize"]]       ## 50
  conn$LocalProperties$ShowHistoricalDates   <- conn$COMIDispatch[["ShowHistoricalDates"]] ## TRUE
  conn$LocalProperties$ShowYields            <- conn$COMIDispatch[["ShowYields"]]          ## TRUE
  conn$LocalProperties$StartTime             <- conn$COMIDispatch[["StartTime"]]           ## READ-ONLY
  conn$LocalProperties$SubscriptionMode      <- conn$COMIDispatch[["SubscriptionMode"]]    ## 0
  conn$LocalProperties$Timeout               <- conn$COMIDispatch[["Timeout"]]             ## 12000
  class(conn) <- "blpConn"
  if(!is.null(conn.name))
    assign(conn.name, conn, envir=.GlobalEnv)
  invisible(conn)
}

blpConnClose <- function(conn.name=".blpConn", verbose=TRUE){
  if(exists(conn.name)){
    rm(list=conn.name, envir = .GlobalEnv)
    gc(verbose = verbose)
    return(TRUE)
  }
  FALSE
}

##
## Methods
##

print.blpConn <- function(x){
  print(unclass(x)$LocalProperties)
}

"$<-.blpConn" <- function(x, i, value){
  value <- value[1]
  CheckSwitch <- function(value, tags){
    if(value %in% names(tags))
      return(as.integer(tags[value]))
    else if(value %in% tags)
      return(value)
    else
      stop(paste("value must be one of:\n", paste(paste(names(tags), tags, sep=" = "), collapse="\n "))) 
  }
  if(i == "ActivateRealtime"){
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "AutoRelease"){           
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "DataOnlyInEvent"){       
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "DisplayNonTradingDays"){ ## WAPI Ref# FRP007
    value <- CheckSwitch(i, value, c(Omit = 0, Week = 64, AllCalendar = 128))
  }else if(i == "NonTradingDayValue"){ ## WAPI Ref# FRP008
    value <- CheckSwitch(i, value, c(PreviousDays = 256, ShowNoNumber = 512))
  }else if(i == "NumberPoints"){
    if(!is.numeric(value))
      stop("value must be numeric")
  }else if(i == "Periodicity"){ ## WAPI Ref# FRP011       
    value <- CheckSwitch(value, c(bbDaily = 1, bbWeekly = 6, bbMonthly = 7, bbQuarterly = 8, bbYearly = 9,
                                  bbActualDaily = 1342177281, bbActualWeekly = 1342177286, bbActualMonthly = 1342177287,
                                  bbActualQuarterly = 1342177288, bbActualSemiAnnually = 1342177285,
                                  bbActualAnnually = 1342177289, bbCalendarDaily = 1610612737, bbCalendarWeekly = 1610612742,
                                  bbCalendarMonthly = 1610612743, bbCalendarQuarterly = 1610612744,
                                  bbCalendarSemiAnnually = 1610612741, bbCalendarAnnually = 1610612745,
                                  bbFiscalQuarterly = 1879048200, bbFiscalSemiAnnually = 1879048197, bbFiscalAnnually = 1879048201))
  }else if(i == "PollingTime"){          
    if(!is.numeric(value))
      stop("value must be numeric")
  }else if(i == "Port"){
    if(!is.numeric(value))
      stop("value must be numeric")
  }else if(i == "QueueEvents"){           
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "QuoteGPA"){              
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "RetryCount"){
    if(!is.numeric(value))
      stop("value must be numeric")
  }else if(i == "ReverseChronological"){  
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "SendQueueSize"){         
    if(!is.numeric(value))
      stop("value must be numeric")
  }else if(i == "ShowHistoricalDates"){   
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "ShowYields"){            
    if(!is.logical(value))
      stop("value must be logical")
  }else if(i == "StartTime"){
    stop("StartTime is a read-only property.")
  }else if(i == "SubscriptionMode"){ ## WAPI Ref# FRP023
    value <- CheckSwitch(value, c(ByField = 0, ByRequest = 1, BySecurity = 2))
  }else if(i == "Timeout"){ 
    if(!is.numeric(value))
      stop("value must be numeric")
  }else{
    stop(paste(i, "is not a valid property"))
  }
  x[["COMIDispatch"]][[i]] <- value
  x[["LocalProperties"]][[i]] <- value
  x
}

"$.blpConn" <- function(x, i){
  ## Write-only properties?.. return local value instead
  if(i == "DisplayNonTradingDays")
    return(unclass(x)$LocalProperties$DisplayNonTradingDays)
  if(i == "NonTradingDayValue")
    return(unclass(x)$LocalProperties$NonTradingDayValue)
  if(i == "Periodicity")
    return(unclass(x)$LocalProperties$Periodicity)
  if(i == "ReverseChronological")
    return(unclass(x)$LocalProperties$ReverseChronological)
  ## .. otherwise
  if(i == "COMIDispatch")
    return(unclass(x)$COMIDispatch)
  else if(i %in% names(unclass(x)$LocalProperties))
    return(unclass(x)$COMIDispatch[[i]])
  else
    stop(paste("must be one of", names(unclass(x)$LocalProperties)))
}
