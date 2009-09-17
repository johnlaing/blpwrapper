comSubscribe <- function(conn, securities, fields, override_fields = NULL, overrides = NULL) {
   has_override_fields <- !(is.null(override_fields))
   has_overrides <- !(is.null(overrides))

   if (has_override_fields && !has_overrides) {
     stop("Overrides must be specified if override fields are.")
   }

   classname <- as.character(class(conn))

  if (has_overrides) {
     lst <- switch(
        classname,
        COMIDispatch = conn$BLPSubscribe(Security = securities, Fields = fields, OverrideFields = override_fields, Overrides = overrides),
        COMObject = comGetProperty(conn, "BLPSubscribe", Security = securities, Fields = fields, OverrideFields = override_fields, Overrides = overrides),
        stop(paste("class", classname, "not supported!"))
      )
  } else {
     lst <- switch(
        classname,
        COMIDispatch = conn$BLPSubscribe(Security = securities, Fields = fields),
        COMObject = comGetProperty(conn, "BLPSubscribe", Security = securities, Fields = fields),
        stop(paste("class", classname, "not supported!"))
     )
  }

  if (is.null(lst)) {
     stop("Call to BLPSubscribe.COMIDispatch did not return any data!")
  }

  unlist(as.vector(lst), recursive = TRUE)
}
