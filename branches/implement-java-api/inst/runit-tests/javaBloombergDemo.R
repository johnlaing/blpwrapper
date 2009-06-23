java_init()

session <- create_bloomberg_session()
service <- create_bloomberg_service(session)

request <- prepare_request(service, c("IBM US Equity", "MSFT US Equity"), c("PX_LAST", "NAME"))
submit_request(session, request)



continue <- TRUE

while(continue) {
   event <- .jcall(session, returnSig="Lcom/bloomberglp/blpapi/Event;", method="nextEvent")
   messageIterator <- .jcall(event, returnSig="Lcom/bloomberglp/blpapi/MessageIterator;", method="messageIterator")
   
   while (.jcall(messageIterator, returnSig="Z", method="hasNext")) {
      message <- .jcall(messageIterator, returnSig="Lcom/bloomberglp/blpapi/Message;", method="next")
      cat(.jcall(message, "Ljava/lang/String;", "toString"))
   }
   
   continue <- !(length(grep("ReferenceDataResponse", .jcall(message, "Ljava/lang/String;", "toString"))) > 0)
}
