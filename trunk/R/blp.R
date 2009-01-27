blp <- function(securities, fields, start=NULL, end=NULL, barsize=NULL, barfields=NULL, override_fields=NULL, overrides=NULL,
                conn=blpConn(), doc.errors=TRUE){
  if(is.null(start))
    x <- as.data.frame(comSubscribe(conn, securities, fields, override_fields, overrides))
  else
    x <- as.zoo(comGetHistoricalData(conn, securities, fields, start, end, barsize, barfields), doc.errors=doc.errors)
  x
}
