library(rJava)
.jinit()
.jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
.jaddClassPath("C:\\bloombergapi\\java\\build\\prod")

conn <- .jnew("com/bloombergapi/wrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

result <- conn$blp(c("BKIR ID Equity", "OCN US Equity"), c("PX_LAST","NAME", "BID", "LOW_DT_52WEEK", "CHG_PCT_YTD", "LAST_UPDATE", "VOLUME_AVG_5D"))

l1 <- as.list(.jcastToArray(result$getData()))
l2 <- sapply(l1, .jevalArray)
l3 <- t(l2)

rownames(l3) <- result$securities()
colnames(l3) <- result$fields()

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

