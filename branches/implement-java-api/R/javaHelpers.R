java_init <- function() {
   library(rJava)
   .jinit()
   .jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")   
}

create_bloomberg_session <- function(host = "localhost", port = "8194") {
   session_options <- .jnew("com/bloomberglp/blpapi/SessionOptions")

   host_jstring <- .jnew("java/lang/String", host)
   port_jint <- .jcall(.jnew("java/lang/Integer", "8194"), "I", "intValue")
   
   .jcall(session_options, returnSig = "V", method = "setServerHost", host_jstring)
   .jcall(session_options, returnSig="V", method = "setServerPort", port_jint)
   
   # Start session.
   session <- .jnew("com/bloomberglp/blpapi/Session", session_options)
   success <- .jcall(session, returnSig="Z", method="start")
   stopifnot(success)
   
   # Start services.
   success <- .jcall(session, returnSig="Z", method="openService", "//blp/refdata")
   stopifnot(success)
   
   return(session)
}

create_bloomberg_service <- function(session) {
   .jcall(session, returnSig = "Lcom/bloomberglp/blpapi/Service;", method="getService", "//blp/refdata")
}

prepare_request <- function(service, securities, fields, parameters) {
   request <- .jcall(service, returnSig = "Lcom/bloomberglp/blpapi/Request;", method="createRequest", "ReferenceDataRequest")
   
   requested_securities <- get_element(request, "securities")
   sapply(securities, append_value_to_element, requested_securities)

   requested_fields <- get_element(request, "fields")
   sapply(fields, append_value_to_element, requested_fields)
   
   return(request)
}

submit_request <- function(session, request) {
   .jcall(session, returnSig="Lcom/bloomberglp/blpapi/CorrelationID;", method="sendRequest", request, .jnull(class = "com/bloomberglp/blpapi/CorrelationID") )
}

get_element <- function(request, element_name) {
   .jcall(request, returnSig="Lcom/bloomberglp/blpapi/Element;", method="getElement", element_name)
}

append_value_to_element <- function(value, element) {
   .jcall(element, returnSig = "V", "appendValue", value)
}

