blpConnect <- function(iface="Java", log.level = "finest", blpapi.jar.file = "C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar"){
  valid.interfaces <- c('Java')
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
  fn.call <- call(fn.name, log.level, blpapi.jar.file)
  eval(fn.call)
}

blpConnect.Java <- function(log.level, blpapi.jar.file) {
  library(rJava)
  .jinit()
  .jaddClassPath(blpapi.jar.file)
  .jaddClassPath(file.path(.Library, "RBloomberg", "java", "blpwrapper.jar"))
  
  java.logging.levels = J("java/util/logging/Level")

  java.log.level <- switch(log.level,
    finest = java.logging.levels$FINEST,
    fine = java.logging.levels$FINE,
    info = java.logging.levels$INFO,
    warning = java.logging.levels$WARNING,
    stop(paste("log level ", log.level, "not recognized"))
  )

  conn <- .jnew("org/findata/blpwrapper/Connection", java.log.level)

  return(conn)
}
