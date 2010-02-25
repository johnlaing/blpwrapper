library(rJava)
.jinit()
.jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
.jaddClassPath("..\\java\\blpwrapper.jar")

conn <- .jnew("org/findata/blpwrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

result <- conn$blp(c("BKIR ID Equity", "OCN US Equity"), c("PX_LAST","NAME"))

result$getData()

