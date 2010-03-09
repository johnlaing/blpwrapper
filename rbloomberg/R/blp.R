blp <- function(conn, securities, fields, start = NULL, end = NULL, 
barsize = NULL, barfields = NULL, retval = NULL, 
override_fields = NULL, overrides = NULL, currency = NULL) { 
  if (is.null(start)) {
    stop("The blp() function has been removed. Please consult documentation for the bdp() function, or the bds() function for making bulk data calls.")
  } else {
    if (is.null(barsize)){
      stop("The blp() function has been removed. Please consult documentation for the bdh() function.")
    } else if (barsize == 0) {
      stop("The blp() function has been removed. Please consult documentation for the tick() function.")
    } else {
      stop("The blp() function has been removed. Please consult documentation for the bar() function.")
    }
  }
}

blpGetData <- function(conn, securities, fields, start = NULL, end = NULL, 
barsize = NULL, barfields = NULL, retval = NULL, 
override_fields = NULL, overrides = NULL, currency = NULL) { 
  if (is.null(start)) {
    stop("The blpGetData() function has been removed. Please consult documentation for the bdp() function, or the bds() function for making bulk data calls.")
  } else {
    if (is.null(barsize)){
      stop("The blpGetData() function has been removed. Please consult documentation for the bdh() function.")
    } else if (barsize == 0) {
      stop("The blpGetData() function has been removed. Please consult documentation for the tick() function.")
    } else {
      stop("The blpGetData() function has been removed. Please consult documentation for the bar() function.")
    }
  }
}

### @export "bdp-definition"
bdp <- function(conn, securities, fields, override_fields = NULL, override_values = NULL, option_names = NULL, option_values = NULL) {
### @end
  securities <- .jarray(securities)
  fields <- .jarray(fields)

  if (is.null(override_fields) && is.null(option_names)) {
    result <- conn$blp(securities, fields)
  } else if (is.null(option_names)) {
    override_fields <- .jarray(override_fields)
    override_values <- .jarray(override_values)
    result <- conn$blp(securities, fields, override_fields, override_values)
  } else {
    override_fields <- .jarray(override_fields)
    override_values <- .jarray(override_values)
    option_names <- .jarray(option_names)
    option_values <- .jarray(option_values)
    result <- conn$blp(securities, fields, override_fields, override_values, option_names, option_values)
  }

  return(process.result(result, "java"))
}

### @export "bds-definition"
bds <- function(conn, securities, fields, override_fields = NULL, override_values = NULL, option_names = NULL, option_values = NULL) {
### @end
  # Pass each security+field separately. Merge resulting data frames
  # if the results are conformal, raise an error if they're not.
  stored.names <- NULL
  combined <- NULL

  combine.multiple = (length(securities) + length(fields) > 2)

  for (security in securities) {
    for (field in fields) {
      if (is.null(override_fields) && is.null(option_names)) {
        result <- conn$bls(security, field)
      } else if (is.null(option_names)) {
        override_fields <- .jarray(override_fields)
        override_values <- .jarray(override_values)
        result <- conn$bls(security, field, override_fields, override_values)
      } else {
        override_fields <- .jarray(override_fields)
        override_values <- .jarray(override_values)
        option_names <- .jarray(option_names)
        option_values <- .jarray(option_values)
        result <- conn$bls(security, field, override_fields, override_values, option_names, option_values)
      }

      if (all(dim(result$getData()) == 0)) next # Skip empty results.
      result <- process.result(result) # Convert to data frame.

      if (combine.multiple) {
        # Prepend data frame with new row containing security ticker.
        result <- data.frame(ticker = security, result)
      }

      if (is.null(stored.names)) {
        stored.names <- colnames(result)
        if (!is.null(combined)) stop("combined should be null if stored.names is null")
        combined <- result
      } else {
        if (!all(colnames(result) == stored.names)) stop(paste("returned names", colnames(result), "do not match previous names", stored.names))
        if (!combine.multiple) stop("combine.multiple should be true if we are running through loop more than once")
        combined <- rbind(combined, result)
      }
    }
  }

  return(combined)
}

### @export "bar-definition"
bar <- function(conn, security, field, start_date_time, end_date_time, interval) {
### @end
  result <- conn$bar(security, field, start_date_time, end_date_time, interval)
  return(process.result(result, "first.row"))
}

### @export "tick-definition"
tick <- function(conn, security, fields, start_date_time, end_date_time) {
### @end
  fields <- .jarray(fields);
  result <- conn$tick(security, fields, start_date_time, end_date_time)
  return(process.result(result))
}

### @export "bdh-definition"
bdh <- function(conn, security, fields, start_date, end_date = NULL, override_fields = NULL, override_values = NULL, option_names = NULL, option_values = NULL) {
### @end
  fields <- .jarray(fields)
  
  if (!is.null(override_fields)) {
    override_fields <- .jarray(override_fields)
    override_values <- .jarray(override_values)
  }

  start_date = format(start_date, format="%Y%m%d")
  if (!is.null(end_date)) {
    end_date = format(end_date, format="%Y%m%d")
  }

  if (!is.null(option_names)) {
    option_names <- .jarray(option_names)
    option_values <- .jarray(option_values)
  }

  if (is.null(end_date)) {
    if (is.null(override_fields) && is.null(option_names)) {
      result <- conn$blh(security, fields, start_date)
    } else if (is.null(option_names)) {
      result <- conn$blh(security, fields, start_date, override_fields, override_values)
    } else {
      result <- conn$blh(security, fields, start_date, override_fields, override_values, option_names, option_values)
    }
  } else {
    if (is.null(override_fields) && is.null(option_names)) {
      result <- conn$blh(security, fields, start_date, end_date)
    } else if (is.null(option_names)) {
      result <- conn$blh(security, fields, start_date, end_date, override_fields, override_values)
    } else {
      result <- conn$blh(security, fields, start_date, end_date, override_fields, override_values, option_names, option_values)
    }
  }

  return(process.result(result, "first.row"))
}

process.result <- function(result, row.name.source = "none") {
  matrix.data <- result$getData()

  rownames(matrix.data) <- switch(row.name.source,
      java = result$getRowNames(),
      first.row = matrix.data[,1],
      none = NULL,
      stop(paste("don't know how to handle this row name source", row.name.source))
      )

  colnames(matrix.data) <- result$getColumnNames()

  df.data <- as.data.frame(matrix.data)
  data_types <- result$getDataTypes()

  if (dim(df.data)[2] > 0) {
    convert.to.type(df.data, data_types)
  } else {
    df.data
  }
}

convert.to.type <- function(df.data, data_types) {
  for (i in 1:(dim(df.data)[2])) {
    string_values = as.vector(df.data[,i])

    new_values <- switch(data_types[i],
        FLOAT64 = as.numeric(string_values),
        INT32 = as.numeric(string_values),
        INT64 = as.numeric(string_values),
        STRING = string_values,
        DATE = string_values,
        DATETIME = string_values,
        NOT_APPLICABLE = string_values,
        stop(paste("unknown type", data_types[i]))
        )
    df.data[,i] <- new_values
  }

  return(df.data)
}

