blpDisconnect <- function(conn){
  ## Garbage collection needed, otherwise COM object is not really
  ## released, preventing any new Bloomberg connection.
  rm(conn, envir=.GlobalEnv);
  gc(verbose=FALSE);
}
