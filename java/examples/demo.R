library(rJava)
.jinit()
.jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
.jaddClassPath("C:\\bloombergapi\\java\\build\\prod")

conn <- .jnew("com/bloombergapi/wrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

conn$blp(c("BKIR ID Equity", "OCN US Equity"), c("PX_LAST","NAME"))

