blp <- function(conn, securities, fields, override_fields = NULL, overrides = NULL) {
  securities <- .jarray(securities)
  fields <- .jarray(fields)
  if (is.null(override_fields)) {
    result <- conn$blp(securities, fields)
  } else {
    override_fields <- .jarray(override_fields)
    overrides <- .jarray(overrides)
    result <- conn$blp(securities, fields, override_fields, overrides)
  }

  return(process.result(result, "tickers"))
}

bls <- function(conn, securities, fields) {
  # Pass each security+field separately. Merge resulting data frames
  # if the results are conformal, raise an error if they're not.
  stored.names <- NULL
  combined <- NULL

  combine.multiple = (length(securities) + length(fields) > 2)

  for (security in securities) {
    for (field in fields) {
      result <- conn$bls(security, field)
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

blh <- function(conn, security, fields, start_date, end_date = NULL, override_fields = NULL, overrides = NULL) {
  fields <- .jarray(fields)

  if (!is.null(override_fields)) {
    override_fields <- .jarray(override_fields)
    overrides <- .jarray(overrides)
  }

  start_date = format(start_date, format="%Y%m%d")
  if (!is.null(end_date)) {
    end_date = format(end_date, format="%Y%m%d")
  }

  if (is.null(end_date)) {
    if (is.null(override_fields)) {
      result <- conn$blh(security, fields, start_date)
    } else {
      result <- conn$blh(security, fields, start_date, override_fields, overrides)
    }
  } else {
    if(is.null(override_fields)) {
      result <- conn$blh(security, fields, start_date, end_date)
    } else {
      result <- conn$blh(security, fields, start_date, end_date, override_fields, overrides)
    }
  }
  
  return(process.result(result, "dates"))
}

process.result <- function(result, row.name.source = "none") {
  matrix.data <- result$getData()

  rownames(matrix.data) <- switch(row.name.source,
      tickers = result$getSecurities(),
      dates = matrix.data[,1],
      none = NULL,
      stop(paste("don't know how to handle this row name source", row.name.source))
  )

  colnames(matrix.data) <- result$getFields()

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

