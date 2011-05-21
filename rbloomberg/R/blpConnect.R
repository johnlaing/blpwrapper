### @export "blpConnect-definition"
blpConnect <- function(iface="Java", log.level = "warning",
    blpapi.jar.file = NULL, throw.ticker.errors = TRUE,
    jvm.params = NULL)
### @end
{
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
  fn.call <- call(fn.name, log.level, blpapi.jar.file, throw.ticker.errors, jvm.params)
  eval(fn.call)
}

blpConnect.Java <- function(log.level, blpapi.jar.file, throw.ticker.errors, jvm.params) {
  cat(R.version.string, "\n")
  cat("rJava Version", read.dcf(system.file("DESCRIPTION", package="rJava"))[1, "Version"], "\n")
  cat("RBloomberg Version", read.dcf(system.file("DESCRIPTION", package="RBloomberg"))[1, "Version"], "\n")

  library(rJava)

  if (is.null(jvm.params)) {
    jinit_value <- try(.jinit())
  } else {
    cat("Using JVM parameters", jvm.params, "\n")
    jinit_value <- try(.jinit(parameters = jvm.params))
  }
  
  if (jinit_value == 0) {
    cat("Java environment initialized successfully.\n")
  } else if (class(jinit_value) == "try-error") {
    stop("Java environment not initialized. Please consult the rJava documentation. You may need to upgrade or install Java.")
  } else if (jinit_value < 0) {
    stop(paste("Error in creating Java environment. Status code", jinit_value))
  } else if (jinit_value > 0) {
    cat("Java environment started, but there may be some problems. Status code", jinit_value, "\n")
  } else {
    stop(paste("Should not be here. jinit_value is", jinit_value, "Please report this as a bug"))
  }

  if (is.null(blpapi.jar.file)) {
    cat("Looking for most recent blpapi3.jar file...\n")
    
    java_api_dir = "C:\\blp\\API\\APIv3\\JavaAPI"
    missing_java_api_dir_message = paste("Can't find", java_api_dir, "please confirm you have Bloomberg Version 3 Java API installed. If it's in a different location, please report this to RBloomberg package maintainer.")
    if (!file.exists(java_api_dir)) stop(missing_java_api_dir_message)

    version.dir <- sort(list.files(java_api_dir, "^v", ignore.case=TRUE), decreasing=TRUE)[1]
    if (is.na(version.dir))
      blpapi.jar.file <- paste(java_api_dir, "lib\\blpapi3.jar", sep="\\")
    else
      blpapi.jar.file <- paste(java_api_dir, version.dir, "lib\\blpapi3.jar", sep="\\")
    end

    if (!file.exists(blpapi.jar.file)){
      blpapi.jar.file <- "C:\\blp\\API\\blpapi3.jar" # Last resort - Bloomberg website downloads get installed here.
    }
  }

  if (file.exists(blpapi.jar.file)) {
    cat("Adding", blpapi.jar.file, "to Java classpath\n") 
    .jaddClassPath(blpapi.jar.file)
  } else {
    stop(paste("blpapi3.jar file not found at", blpapi.jar.file, "please locate blpapi3.jar file and pass location including full path to blpConnect as blpapi.jar.file parameter. This might be a bug, if so please report it. Or try reinstalling the Java API from UPGR or WAPI pages."))
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
  
  if (throw.ticker.errors) {
    throw.ticker.errors.java = .jnew("java/lang/Boolean", TRUE)$booleanValue()
  } else {
    throw.ticker.errors.java = .jnew("java/lang/Boolean", FALSE)$booleanValue()
  } 
  conn$setThrowInvalidTickerError(throw.ticker.errors.java)

  cat("Bloomberg API Version", J("com.bloomberglp.blpapi.VersionInfo")$versionString(), "\n")

  return(conn)
}
