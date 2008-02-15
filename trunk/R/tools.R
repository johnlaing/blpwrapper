## Take BlpCOMReturn object and return vector with any Bloomberg
## errors replaced with NA's (and raise warnings detailing error types
## if suppress = FALSE). 
replaceBloombergErrors <- function(x, suppress=TRUE){
  err.codes <- c("#N/A Fld","#N/A Tim","#N/A Com","#N/A Auth",
                 "#N/A Security","#N/A Intraday","#N/A History","#N/A N.A.",
                 "#N/A N Ap","#N/A Neg","#N/A Sec","#N/A Trd",
                 "#N/A RI Tim","#N/A RI Perm","#N/A Dberr","#N/A Sec Tp",
                 "#N/A Limit","#N/A MD Limit","#N/A Dly Lmt","#N/A Mth Lmt",
                 "#N/A Sls Auth","#N/A Unknown","#N/A Hist Fld","#N/A Rte",
                 "#N/A RTbl","#N/A InvalidReq","#N/A Restart","#N/A DBTimeOut")
  err.descr <- c("Invalid field mnemonic is specified",
                 "The request for this field has timed out",
                 "The connection between DDE server and local bbcomm is lost/unavailiable",
                 "Not authorized for Bloomberg data",
                 "Invalid security",
                 "No intraday is available",
                 "No history is available",
                 "The data for the specified derived field is not available",
                 "The field is not applicable for this security",
                 "The field is a numeric field that cannot be negative but the calculated value is negative",
                 "Security unknown/not recognized",
                 "The security for which realtime data was requested has not traded for more than 30days",
                 "Realtime not available for the given field/security",
                 "The user does not have the permission to access the specified field",
                 "Bloomberg database error",
                 "The specified security type is not among the valid types",
                 "The daily limit for the number of hits you can make to our data servers has been reached or exceeded",
                 "Over the limit of allowed market depth subscriptions",
                 "Over the daily API limit for security/field pairs",
                 "Over the monthly API limit for security/field pairs",
                 "API usage is shut off for administrative reasons. Please contact your Bloomberg Account Manager",
                 "Unkown problem with the requests for the realtime fields",
                 "Not an applicable history field",
                 "API monitor.rte file not configured correctly",
                 "API monitor.rte file not configured correctly",
                 "One or more of the parameters in the request are wrong",
                 "The back-end server was restarted due to the problems on the back-end while processing request",
                 "The request has timed out on the back-end")
  vec <- unlist(x)
  nas <- which(vec %in% err.codes)
  err <- which(err.codes %in% vec[nas])
  vec <- replace(vec,nas,NA)
  if(!suppress){
    for(i in err){
      warning(paste(err.codes[i],"(",err.descr[i],")",sep=""))
    }
  }
  return(vec)
}

## Bloomberg WAPI reference: "Appendix D: Reading the Data
## Dictionary", #CAX041

## Data type codes in bbfields.tbl 
## 1 = Character string
## 2 = Numeric
## 3 = Price (e.g., can be 102-28+.. but we'll ignore that for now)
## 4 = Security (e.g., T 1.5 10/20/01)
## 5 = Date
## 6 = Time
## 7 = Date or Time
## 8 = Bulk Format ** CURRENTLY NOT SUPPORTED **
## 9 = Month/Year (e.g. mm/yyyy)
## 10 = Boolean
## 11 = ISO Currency Code (ASCII string)

read.bbfields <- function(path="C:/blp/API"){
  path <- paste(path,"/bbfields.tbl",sep="")
  cnames <- c("category","category.name","subcategory","subcategory.name",
          "field.id","field.name","field.mnemonic","mkt.bitmask",
          "data.bitmask","data.type")
  df <- try(read.table(path,sep="|",col.names=cnames,
                       fill=TRUE,as.is=TRUE,quote=""))
  if(!class(df)=="try-error"){
    return(df)
  }
}

dataType <- function(mnemonic, bbfields=.bbfields){
  mnemonic <- toupper(mnemonic)
  b.typ <- c()
  for(i in mnemonic){
    b.typ <- c(b.typ, bbfields[which(i==bbfields$field.mnemonic),]$data.type)
  }
  r.typ <- c("character","double","double","character",
              "chron","chron","chron","character","character",
              "logical","character")
  x <- r.typ[b.typ]
  if(length(x) == 0){
    return(NULL)
  }else{
    return(x)
  }   
}

