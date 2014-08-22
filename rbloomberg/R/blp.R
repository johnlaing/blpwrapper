### @export "bdp-definition"
bdp <- function(conn, securities, fields,
    override_fields = NULL, override_values = NULL, 
    option_names = NULL, option_values = NULL)
### @end
{
  securities <- .jarray(securities)
  fields <- .jarray(fields)

  if (is.null(override_fields) && is.null(option_names)) {
    result <- conn$blp(securities, fields)
  } else if (is.null(option_names)) {
    override_fields <- .jarray(override_fields)
    override_values <- .jarray(override_values)
    result <- conn$blp(securities, fields, override_fields, override_values)
  } else if (is.null(override_fields)) {
    override_fields <- .jarray("IGNORE")
    override_values <- .jarray("IGNORE")
    option_names <- .jarray(option_names)
    option_values <- .jarray(option_values)
    result <- conn$blp(securities, fields, override_fields, override_values, option_names, option_values)
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
bds <- function(conn, securities, fields, 
    override_fields = NULL, override_values = NULL, 
    option_names = NULL, option_values = NULL)
### @end
{
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
      } else if (is.null(override_fields)) {
        override_fields <- .jarray("IGNORE")
        override_values <- .jarray("IGNORE")
        option_names <- .jarray(option_names)
        option_values <- .jarray(option_values)
        result <- conn$bls(security, field, override_fields, override_values, option_names, option_values)
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

### @export "bdh-definition"
bdh <- function(conn, securities, fields, start_date, end_date = NULL, 
    override_fields = NULL, override_values = NULL, 
    option_names = NULL, option_values = NULL,
    always.display.tickers = FALSE, dates.as.row.names = (length(securities) == 1),
    include.non.trading.days = NULL)
### @end
{
  fields <- .jarray(fields)

  if (!is.null(override_fields)) {
    override_fields <- .jarray(override_fields)
    override_values <- .jarray(override_values)
  }

  start_date = format(start_date, format="%Y%m%d")
  if (!is.null(end_date)) {
    end_date = format(end_date, format="%Y%m%d")
  }

  combined <- NULL
  combine.multiple <- (length(securities) > 1)

  if (combine.multiple && is.null(include.non.trading.days)) {
    include.non.trading.days = TRUE
    ## TODO Should raise error if set to FALSE?
  }

  if (is.null(include.non.trading.days)) {
    # We don't want to call 'if' on a NULL value.
  } else if (include.non.trading.days) {
    option_names <- c("nonTradingDayFillOption", "nonTradingDayFillMethod", option_names) 
    option_values <- c("ALL_CALENDAR_DAYS", "NIL_VALUE", option_values)
  }

  if (!is.null(option_names)) {
    option_names <- .jarray(option_names)
    option_values <- .jarray(option_values)
  }

  i <- 0

  for (security in securities) {
    i <- i+1

    if (is.null(end_date)) {
      if (is.null(override_fields) && is.null(option_names)) {
        result <- conn$blh(security, fields, start_date)
      } else if (is.null(option_names)) {
        result <- conn$blh(security, fields, start_date, override_fields, override_values)
      } else if (is.null(override_fields)) {
        override_fields <- .jarray("IGNORE")
        override_values <- .jarray("IGNORE")

        result <- conn$blh(security, fields, start_date, override_fields, override_values, option_names, option_values)
      } else {
        result <- conn$blh(security, fields, start_date, override_fields, override_values, option_names, option_values)
      }
    } else {
      if (is.null(override_fields) && is.null(option_names)) {
        result <- conn$blh(security, fields, start_date, end_date)
      } else if (is.null(option_names)) {
        result <- conn$blh(security, fields, start_date, end_date, override_fields, override_values)
      } else if (is.null(override_fields)) {
        override_fields <- .jarray("IGNORE")
        override_values <- .jarray("IGNORE")

        result <- conn$blh(security, fields, start_date, end_date, override_fields, override_values, option_names, option_values)
      } else {
        result <- conn$blh(security, fields, start_date, end_date, override_fields, override_values, option_names, option_values)
      }
    }

    matrix.data <- result$getData()
    column.names <- result$getColumnNames()
    data.types <- result$getDataTypes()
    if (is.null(matrix.data)) {
      matrix.data <- matrix(, nrow=0, ncol=length(column.names))
    } else {
      matrix.data <- .jevalArray(matrix.data, simplify = TRUE)
    }

    if (combine.multiple || always.display.tickers) {
      matrix.data <- cbind(rep(security, dim(matrix.data)[1]), matrix.data)
      column.names <- c("ticker", column.names)
      data.types <- c("STRING", data.types)
    }

    if (is.null(combined)) { # First time through loop...
      # Initialize matrix with this iteration's results
      combined <- rbind(combined, matrix.data)
    } else { # Not the first time through loop...
      if (!combine.multiple) stop("combine.multiple should be true if we are running through loop more than once")
      combined <- rbind(combined, matrix.data)
    }
  }

  if (is.null(combined)) {
    return(NULL)
  } else {
    if (dates.as.row.names) {
      if (combine.multiple) stop("Can't use dates as row names with multiple tickers, dates will not be unique.")
      if (always.display.tickers) {
        rownames(combined) <- matrix.data[,2]
      } else {
        rownames(combined) <- matrix.data[,1]
      }
    }

    colnames(combined) <- column.names
    combined <- convert.data.to.type(combined, data.types)
    return(combined)
  }
}

### @export "bar-definition"
bar <- function(conn, security, field, start_date_time, end_date_time, interval,
    option_names = NULL, option_values = NULL)
### @end
{
  if (is.null(option_names)) {
    result <- conn$bar(security, field, start_date_time, end_date_time, interval)
  } else {
    option_names <- .jarray(option_names)
    option_values <- .jarray(option_values)
    result <- conn$bar(security, field, start_date_time, end_date_time, interval, option_names, option_values)
  }
  return(process.result(result, "first.column"))
}

### @export "tick-definition"
tick <- function(conn, security, fields, start_date_time, end_date_time, 
    option_names = NULL, option_values = NULL)
### @end
{
  fields <- .jarray(fields);

  if (is.null(option_names)) {
    result <- conn$tick(security, fields, start_date_time, end_date_time)
  } else {
    option_names <- .jarray(option_names)
    option_values <- .jarray(option_values)
    result <- conn$tick(security, fields, start_date_time, end_date_time, option_names, option_values)
  }
  return(process.result(result))
}

process.result <- function(result, row.name.source = "none") {
  matrix.data <- .jevalArray(result$getData(), simplify = TRUE)
  if (is.null(matrix.data)) return(NULL)

  rownames(matrix.data) <- switch(row.name.source,
      java = result$getRowNames(),
      first.column = matrix.data[,1],
      none = NULL,
      stop(paste("don't know how to handle this row name source", row.name.source))
      )

  colnames(matrix.data) <- result$getColumnNames()

  convert.data.to.type(matrix.data, result$getDataTypes())
}

convert.data.to.type <- function(matrix.data, data_types) {
  df.data <- as.data.frame(matrix.data)

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
        CHAR = string_values == 'Y', # Assumes CHAR is only used for Boolean values and can be trusted to return 'Y' or 'N'.
        stop(paste("unknown type", data_types[i]))
        )
    df.data[,i] <- new_values
  }

  return(df.data)
}

