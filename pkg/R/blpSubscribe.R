blpSubscribe <- function(conn, securities, fields, override_fields = NULL, overrides = NULL){
   if(length(securities) == 0 || length(fields) == 0){
     stop("Need at least one security and one field")
   }

  if (is.null(override_fields)) {
     lst <- comGetProperty(conn, "BLPSubscribe", Security=securities, Fields=fields)
  } else {
     if (is.null(overrides)) {
        stop("Overrides must be specified if override fields are.")
     }
     lst <- comGetProperty(conn, "BLPSubscribe", Security=securities, Fields=fields, OverrideFields = override_fields, Overrides = overrides)
  }
  
  if (is.null(lst)) {
     stop("Call to BLPSubscribe did not return any data!")
  }
  
  return(lst)
}
