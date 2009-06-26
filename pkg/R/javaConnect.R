java_init <- function() {
   library(rJava)
   .jinit()
   .jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")   
}

create_session_and_service <- function() {
   session <- create_bloomberg_session()
   service <- create_bloomberg_service(session)
   conn <- c(session = session, service = service)
   class(conn) <- "JavaObject"
   return(conn)
}

create_bloomberg_session <- function(host = "localhost", port = 8194) {
   session_options <- .jnew("com/bloomberglp/blpapi/SessionOptions")

   host_jstring <- .jnew("java/lang/String", host)
   port_jint <- int(port)
   
   .jcall(session_options, returnSig = "V", method = "setServerHost", host_jstring)
   .jcall(session_options, returnSig = "V", method = "setServerPort", port_jint)
   
   # Start session.
   session <- .jnew("com/bloomberglp/blpapi/Session", session_options)
   success <- .jcall(session, returnSig = "Z", method = "start")
   stopifnot(success)
   
   process_event(session, "SESSION_STATUS")
   
   # Start services.
   success <- .jcall(session, returnSig = "Z", method = "openService", "//blp/refdata")
   stopifnot(success)
   
   process_event(session, "SERVICE_STATUS")

   return(session)
}

create_bloomberg_service <- function(session) {
   .jcall(session, returnSig = "Lcom/bloomberglp/blpapi/Service;", method="getService", "//blp/refdata")
}
