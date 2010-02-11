.First.lib <- function(libname,pkgname){
  if(version$os != "mingw32"){
    warning("RBloomberg currently supports only the COM API (windows-only).
Future support for platform independent API's is envisioned.")
  }else{
    bb <- try(blpReadFields())
    if(is.null(bb)){
      warning("I can't find your bbfields file.. see ?blpReadFields")
    }else{
      assign(".bbfields", bb, ".GlobalEnv")
      message("Contents of bbfields have been stored in .bbfields in the current workspace")
    }
    ovr <- try(read.ovr())
    if(is.null(ovr)){
      warning("I can't find your bloomberg overrides field.. see ?read.ovr")
    }else{
      assign(".ovr", ovr, ".GlobalEnv")
      message("Contents of bbfields.ovr have been stored in .ovr in the current workspace")
    }
    
    cat("\nChecking RBloomberg interfaces:")
    blpInterfaces()
    cat("\n")
  }
}

.Last.lib <- function(libpath){
  message("Removing variable .bbfields from the current workspace")
  rm(.bbfields, inherits=TRUE)
  message ("Removing variable .ovr from the current workspace")
  rm(.ovr, inherits=TRUE)
}
