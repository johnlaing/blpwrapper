java_init <- function() {
   library(rJava)
   .jinit()
   .jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")   
}

create_bloomberg_session <- function(host = "localhost", port = "8194") {
   session_options <- .jnew("com/bloomberglp/blpapi/SessionOptions")

   host_jstring <- .jnew("java/lang/String", host)
   port_jint <- int(8194)
   
   .jcall(session_options, returnSig = "V", method = "setServerHost", host_jstring)
   .jcall(session_options, returnSig = "V", method = "setServerPort", port_jint)
   
   # Start session.
   session <- .jnew("com/bloomberglp/blpapi/Session", session_options)
   success <- .jcall(session, returnSig = "Z", method = "start")
   stopifnot(success)
   
   # TODO read event stream here
   
   # Start services.
   success <- .jcall(session, returnSig = "Z", method = "openService", "//blp/refdata")
   stopifnot(success)
   
   # TODO read event stream here

   return(session)
}

create_bloomberg_service <- function(session) {
   .jcall(session, returnSig = "Lcom/bloomberglp/blpapi/Service;", method="getService", "//blp/refdata")
}

create_session_and_service <- function() {
   session <- create_bloomberg_session()
   service <- create_bloomberg_service(session)
   conn <- c(session = session, service = service)
   class(conn) <- "JavaObject"
   return(conn)
}

prepare_request <- function(service, securities, fields, parameters) {
   request <- .jcall(service, returnSig = "Lcom/bloomberglp/blpapi/Request;", method="createRequest", "ReferenceDataRequest")
   
   requested_securities <- getElement("securities", request)
   sapply(securities, append_value_to_element, requested_securities)

   requested_fields <- getElement("fields", request)
   sapply(fields, append_value_to_element, requested_fields)
   
   return(request)
}

submit_request <- function(session, request) {
   .jcall(session, returnSig="Lcom/bloomberglp/blpapi/CorrelationID;", method="sendRequest", request, .jnull(class = "com/bloomberglp/blpapi/CorrelationID") )
}

append_value_to_element <- function(value, element) {
   .jcall(element, returnSig = "V", "appendValue", value)
}

read_events_stream_to_string <- function(session) {
   continue <- TRUE
   blp <- NULL
   
   while(continue) {
      event <- .jcall(session, returnSig="Lcom/bloomberglp/blpapi/Event;", method="nextEvent")
      event_type <- .jcall(event, returnSig="Lcom/bloomberglp/blpapi/Event$EventType;", method="eventType")
      
      if (toString(event_type) %in% c("PARTIAL_RESPONSE", "RESPONSE")) {
         messageIterator <- .jcall(event, returnSig="Lcom/bloomberglp/blpapi/MessageIterator;", method="messageIterator")

         while (hasNext(messageIterator)) {
            message <- .jcall(messageIterator, returnSig="Lcom/bloomberglp/blpapi/Message;", method="next")
            message_type <- .jcall(message, returnSig="Lcom/bloomberglp/blpapi/Name;", method="messageType")
            
            if (toString(message_type) == "ReferenceDataResponse") {
               security_data <- getElement("securityData", message)
               securities <- getValuesAsElements(security_data)
               blp <- rbind(blp, aperm(sapply(securities, getFieldData)))
            } else {
               stop(paste("I am not trained to handle messageType", toString(message_type)))
            }
         }
      }
      
      continue <- !(toString(event_type) == "RESPONSE")
   }
   
   return(blp)
}

grepMethod <- function(java_object, search_string) {
   grep(search_string, .jmethods(java_object), ignore.case = TRUE, value=TRUE)
}

int <- function(value) {
   .jcall(.jnew("java/lang/Integer", format(value)), "I", "intValue")
}

toString <- function(java_object) {
   .jcall(java_object, "Ljava/lang/String;", "toString")
}

hasNext <- function(java_object) {
   .jcall(java_object, returnSig="Z", method="hasNext")
}

getElement <- function(element_name, java_object) {
   .jcall(java_object, returnSig="Lcom/bloomberglp/blpapi/Element;", method="getElement", element_name)
}

getElements <- function(java_object) {
   from <- 0
   to <- numElements(java_object) - 1
   lapply(seq(from, to), getElement, java_object)
}

getValueAsElement <- function(i, java_object) {
   .jcall(java_object, returnSig="Lcom/bloomberglp/blpapi/Element;", method="getValueAsElement", int(i))
}

getValuesAsElements <- function(java_object) {
   from <- 0
   to <- numValues(java_object) - 1
   lapply(seq(from, to), getValueAsElement, java_object)
}

# Returns an ordered list of field contents.
getFieldData <- function(field) {
   field_data <- getElement("fieldData", field)
   fields <- getElements(field_data)
   lapply(fields, getFieldValue)
}

getFieldAs <- function(field, fn_stub, return_sig) {
   fn_name <- paste("getValueAs", fn_stub, sep="")
   .jcall(field, returnSig = return_sig, fn_name)
}

getFieldValue <- function(field) {
   field_datatype <- getFieldType(field)
   switch(
     field_datatype,
      FLOAT64 = getFieldAs(field, "Float64", "D"),
      STRING = getFieldAs(field, "String", "S"),
      DATE = toString(getFieldAs(field, "Date", "Lcom.bloomberglp.blpapi.Datetime;")),
      stop(field_datatype)
   )
}

getFieldType <- function(field) {
   toString(.jcall(field, "Lcom/bloomberglp/blpapi/Schema$Datatype;", "datatype"))
}

numValues <- function(java_object) {
   .jcall(java_object, returnSig="I", method = "numValues")
}

numElements <- function(java_object) {
   .jcall(java_object, returnSig="I", method = "numElements")
}

