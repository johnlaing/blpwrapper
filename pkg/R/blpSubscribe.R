blpSubscribe <- function(conn, securities, fields, override_fields = NULL, overrides = NULL){
  lst <- conn$BlpSubscribe(Security=securities, Fields=fields, OverrideFields = override_fields, Overrides = overrides);
  if(length(securities) == 0 || length(fields) == 0){
    stop("Need at least one security and one field")
  }
  class(lst) <- "BlpCOMReturn"
  attr(lst,"securities") <- securities
  attr(lst,"fields") <- fields
  attr(lst, "override_fields") <- override_fields
  attr(lst, "overrides") <- overrides
  attr(lst,"num.of.date.cols") <- 0
  return(lst)
}
