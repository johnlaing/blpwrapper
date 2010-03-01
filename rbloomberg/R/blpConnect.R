blpConnect <- function(iface="Java"){
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
  fn.call <- call(fn.name)
  eval(fn.call)
}

blpConnect.Java <- function() {
  library(rJava)
  .jinit()
  .jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
  .jaddClassPath("C:\\blpwrapper\\rbloomberg\\java\\blpwrapper.jar")

  conn <- .jnew("org.findata/blpwrapper/Connection")
  conn$connect()

  return(conn)
}
