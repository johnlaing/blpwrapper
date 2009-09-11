library(RDCOMClient)

conn <- COMCreate("Bloomberg.Data.1")
cat(class(conn))