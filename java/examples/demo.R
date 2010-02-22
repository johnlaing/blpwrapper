library(rJava)
.jinit()
.jaddClassPath("C:\\blp\\API\\APIv3\\JavaAPI\\lib\\blpapi3.jar")
.jaddClassPath("C:\\bloombergapi\\java\\build\\prod")

conn <- .jnew("com/bloombergapi/wrapper/Connection")
.jcall(conn, returnSig="V", method="connect")

result <- conn$blp(c("BKIR ID Equity", "OCN US Equity"), c("PX_LAST","NAME", "BID"))

l1 <- as.list(.jcastToArray(result$getData()))
l1
l2 <- sapply(l1, .jevalArray)
l2
l3 <- t(l2)
l3

rownames(l3) <- result$securities()
colnames(l3) <- result$fields()

numeric.indexes <- which(result$getDataTypes() %in% c("FLOAT64"))
string.indexes <- which(result$getDataTypes() %in% c("STRING"))

df <- as.data.frame(l3)
df
df[1,1]

df[numeric.indexes]
df$PX_LAST <- as.numeric(as.vector(df$PX_LAST))
df
df[1,1]

