library(rJava)
.jinit()

blpapi_jar_file_path <- "C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar"
blpwrapper_jar_file_path <- "C:\\Program Files\\R\\R-2.10.1\\library\\RBloomberg\\java\\blpwrapper.jar"

print(file.exists(blpapi_jar_file_path))
.jaddClassPath(blpapi_jar_file_path)

print(file.exists(blpwrapper_jar_file_path))
.jaddClassPath(blpwrapper_jar_file_path)

conn <- .jnew("org.findata/blpwrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

securities <- c("BKIR ID Equity", "OCN US Equity")
fields <- c("PX_LAST","NAME", "BID", "LOW_DT_52WEEK", "CHG_PCT_YTD", "LAST_UPDATE", "VOLUME_AVG_5D")

result <- conn$blp(securities, fields)
result$getData()

