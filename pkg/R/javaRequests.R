prepare_request <- function(service, securities, fields, start = NULL, end = NULL) {
   # Choose the appropriate type of request depending on parameters passed.
   if (is.null(start)) {
      request_type <- "ReferenceDataRequest"
   } else {
      request_type <- "HistoricalDataRequest"
   }
   
   request <- .jcall(service, returnSig = "Lcom/bloomberglp/blpapi/Request;", method="createRequest", request_type)
   
   requested_securities <- getElement("securities", request)
   sapply(securities, append_value_to_element, requested_securities)

   requested_fields <- getElement("fields", request)
   sapply(fields, append_value_to_element, requested_fields)
   
   if (!is.null(start)) set_request_parameter(request, "startDate", start)
   if (!is.null(end)) set_request_parameter(request, "endDate", end)
   
   return(request)
}

submit_request <- function(session, request) {
   .jcall(session, returnSig="Lcom/bloomberglp/blpapi/CorrelationID;", method="sendRequest", request, .jnull(class = "com/bloomberglp/blpapi/CorrelationID") )
}
