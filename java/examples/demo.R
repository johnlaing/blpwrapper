library(rJava)
.jinit()
.jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
.jaddClassPath("C:\\bloombergapi\\java\\build\\prod")

conn <- .jnew("com/bloombergapi/wrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

result <- conn$blp(c("BKIR ID Equity", "OCN US Equity"), c("PX_LAST","NAME"))
l1 <- as.list(.jcastToArray(result$getData))

l1

l2 <- sapply(l1, .jcastToArray)

colnames(l2) <- result$fields
rownames(l2) <- result$securities

l2
