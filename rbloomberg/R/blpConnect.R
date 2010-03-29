blpConnect <- function(iface="Java", log.level = "warning", blpapi.jar.file = NULL){
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
  cat(R.version.string, "\n")
  cat("rJava Version", read.dcf(system.file("DESCRIPTION", package="rJava"))[1, "Version"], "\n")
  cat("RBloomberg Version", read.dcf(system.file("DESCRIPTION", package="RBloomberg"))[1, "Version"], "\n")

  library(rJava)
  .jinit()

  if (is.null(blpapi.jar.file)) {
    cat("Looking for most recent blpapi3.jar file...\n")
    version.dir <- sort(list.files("C:\\blp\\API\\APIv3\\JavaAPI", "^v"), decreasing=TRUE)[1]
    if (is.na(version.dir))
      blpapi.jar.file <- paste("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar", sep="")
    else
      blpapi.jar.file <- paste("C:\\blp\\API\\APIv3\\JavaAPI\\", version.dir, "\\lib\\blpapi3.jar", sep="")
    end
  }

  if (file.exists(blpapi.jar.file)) {
    .jaddClassPath(blpapi.jar.file)
  } else {
    stop(paste("blpapi jar file not found at", blpapi.jar.file, "please locate this file and pass correct location to blpConnect as blp.jar.file parameter. This might be a bug, if so please report it."))
  }

  blpwrapper.jar.file = system.file("java", "blpwrapper.jar", package="RBloomberg")

  if (file.exists(blpwrapper.jar.file)) {
    .jaddClassPath(blpwrapper.jar.file)
  } else {
    stop(paste("blpwrapper jar file not found at", blpwrapper.jar.file, "please report this as a bug"))
  }
  
  java.logging.levels = J("java/util/logging/Level")

  java.log.level <- switch(log.level,
    finest = java.logging.levels$FINEST,
    fine = java.logging.levels$FINE,
    info = java.logging.levels$INFO,
    warning = java.logging.levels$WARNING,
    stop(paste("log level ", log.level, "not recognized"))
  )

  conn <- .jnew("org/findata/blpwrapper/Connection", java.log.level)
  cat("Bloomberg API Version", J("com.bloomberglp.blpapi.VersionInfo")$versionString(), "\n")

  return(conn)
}
