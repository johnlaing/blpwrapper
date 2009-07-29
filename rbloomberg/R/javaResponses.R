process_message <- function(message, blp) {
   message_type <- toString(.jcall(message, returnSig="Lcom/bloomberglp/blpapi/Name;", method="messageType"))
   
   if (message_type == 'ReferenceDataResponse') {
      process_reference_data_response(message, blp)
   } else if (message_type == 'HistoricalDataResponse') {
      process_historical_data_response(message, blp)
   } else if (message_type == 'SessionStarted') {
      "SessionStarted"
   } else if (message_type == 'ServiceOpened') {
      "ServiceOpened"
   } else {
      stop(message_type)
   }
}

process_reference_data_response <- function(message, blp) {
   security_data <- getElement("securityData", message)
   securities <- getValuesAsElements(security_data)
   rbind(blp, aperm(sapply(securities, getFieldData)))
}

process_historical_data_response <- function(message, blp) {
   if (is.null(blp)) {
      blp <- vector("list")
   }
   
   # Returns data for 1 security at a time.
   security <- getElement("securityData", message)
   ticker <- .jcall(security, returnSig="S", "getElementAsString", "security")
   
   field_data_array <- getValuesAsElements(getElement("fieldData", security))
   
   blp[[ticker]] <- lapply(field_data_array, getValuesForFieldData)
   blp
}

process_event <- function(session, event_name) {
   continue <- TRUE
   data <- NULL
   
   while(continue) {
      event <- .jcall(session, returnSig="Lcom/bloomberglp/blpapi/Event;", method="nextEvent")
      event_type <- .jcall(event, returnSig="Lcom/bloomberglp/blpapi/Event$EventType;", method="eventType")
      
      message_iterator <- .jcall(event, returnSig="Lcom/bloomberglp/blpapi/MessageIterator;", method="messageIterator")

      while (hasNext(message_iterator)) {
         message <- .jcall(message_iterator, returnSig="Lcom/bloomberglp/blpapi/Message;", method="next")
         data <- process_message(message, data)
      }
      
      continue <- !(toString(event_type) == event_name)
   }
   
   return(data)
}
