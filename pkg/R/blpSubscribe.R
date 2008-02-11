blpSubscribe <- function(conn, securities, fields){
  lst <- conn$BlpSubscribe(Security=securities, Fields=fields);
  if(length(securities) == 0 || length(fields) == 0){
    stop("Need at least one security and one field")
  }
  class(lst) <- "BlpCOMReturn"
  attr(lst,"securities") <- securities
  attr(lst,"fields") <- fields
  attr(lst,"num.of.date.cols") <- 0
  return(lst)
}
