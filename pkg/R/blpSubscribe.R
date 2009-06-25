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
  
  class(lst) <- "BlpRawReturn"
  attr(lst, "securities") <- securities
  attr(lst, "fields") <- fields
  attr(lst, "override_fields") <- override_fields
  attr(lst, "overrides") <- overrides
  attr(lst, "num.of.date.cols") <- 0
  
  return(lst)
}
