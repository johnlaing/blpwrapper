library(rJava)
.jinit()
.jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
.jaddClassPath("C:\\blpwrapper\\java\\build\\prod")

print(.jclassPath())

conn <- .jnew("org.findata/blpwrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

securities <- c("BKIR ID Equity", "OCN US Equity")
fields <- c("PX_LAST","NAME", "BID", "LOW_DT_52WEEK", "CHG_PCT_YTD", "LAST_UPDATE", "VOLUME_AVG_5D")

call.blp <- function(conn, securities, fields) {
  result <- conn$blp(securities, fields)

  l3 <- result$getData()

  rownames(l3) <- result$getSecurities()
  colnames(l3) <- result$getFields()

  df <- as.data.frame(l3)

  data_types = result$getDataTypes()

  for (i in 1:(dim(df)[2])) {
    string_values = as.vector(df[,i])

    new_values <- switch(data_types[i],
        FLOAT64 = as.numeric(string_values),
        STRING = string_values,
        DATE = as.POSIXct(string_values),
        DATETIME = as.POSIXct(string_values, format="%H:%M:%S"),
        stop(paste("unknown type", data_types[i]))
        )
    df[,i] <- new_values
  }

  df
}

call.blp(conn, securities, fields)


convert.to.date.if.present <- function(x) {
  if (nchar(x) < 5) {
    NA
  } else {
    as.POSIXct(x)
  }
}

call.bls <- function(conn, security, field) {
  result <- conn$bls(security, field)

  l3 <- result$getData()
  colnames(l3) <- result$getFields()

  df <- as.data.frame(l3)

  data_types = result$getDataTypes()

  for (i in 1:(dim(df)[2])) {
    string_values = as.vector(df[,i])

    new_values <- switch(data_types[i],
        FLOAT64 = as.numeric(string_values),
        STRING = string_values,
        DATE = sapply(string_values, convert.to.date.if.present),
        DATETIME = as.POSIXct(string_values, format="%H:%M:%S"),
        stop(paste("unknown type", data_types[i]))
        )
    df[,i] <- new_values
  }

  df
}

call.bls(conn, "BKIR ID Equity", "DVD_HIST")

sec1 <- call.bls(conn, "RAY Index", "INDX_MEMBERS")[,1]
sec2 <- call.bls(conn, "RAY Index", "INDX_MEMBERS2")[,1]

securities <- paste(c(sec1, sec2, recursive=TRUE), " EQUITY")
#call.blp(conn, securities, fields)

result <- conn$blh("OCN US Equity", c("BID", "PX_LAST"), "20100101", "20100202")
result <- conn$blh("OCN US Equity", c("BID", "PX_LAST"), "20100101")
l <- result$getData()
colnames(l) <- result$getFields()
rownames(l) <- l[,1]
df <- as.data.frame(l)
df
data_types = result$getDataTypes()


for (i in 1:(dim(df)[2])) {
  string_values = as.vector(df[,i])

  new_values <- switch(data_types[i],
      FLOAT64 = as.numeric(string_values),
      STRING = string_values,
      DATE = sapply(string_values, convert.to.date.if.present),
      DATETIME = as.POSIXct(string_values, format="%H:%M:%S"),
      stop(paste("unknown type", data_types[i]))
      )
  df[,i] <- new_values
}

df


fields <- c("NAME", "COUNTRY", "INDUSTRY_SECTOR", "PX_LAST", "EXCH_CODE", "ID_ISIN", "CRNCY_ADJ_MKT_CAP", "CHG_PCT_YTD", "DVD_PAYOUT_RATIO", "TOT_ANALYST_REC", "ALTMAN_Z_SCORE")
result <- conn$fieldInfo(fields)

l <- result$getData()
l

colnames(l) <- result$getFields()

df <- as.data.frame(l)
df
