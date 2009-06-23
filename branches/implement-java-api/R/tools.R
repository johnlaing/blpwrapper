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

read.ovr <- function(path="C:/blp/API"){
  path <- paste(path,"/bbfields.ovr",sep="")
  readLines(path)
}

search.mnemonics <- function(string) {
   grep(string, .bbfields$field.mnemonic, value=TRUE)
}

what.i.override <- function(mnemonic, ovr=.ovr) {
  stopifnot(length(mnemonic)==1)
  field.mnemonic(gsub("^([0-9|A-Z]{2,4})\\|.*$", "\\1", grep(field.id(mnemonic), ovr, value=TRUE), extended=TRUE))
}

what.we.override <- function(mnemonic, ovr=.ovr) {
  lapply(mnemonic, what.i.override)
}

what.overrides.me <- function(mnemonic, ovr=.ovr) {
  stopifnot(length(mnemonic)==1)
  field.mnemonic(unlist(strsplit(grep(sprintf("^%s", field.id(mnemonic)), ovr, value=TRUE), "[|]"))[-1])
}

what.overrides.us <- function(mnemonic, ovr=.ovr) {
  lapply(mnemonic, what.overrides.me)
}

dataType <- function(mnemonic, bbfields=.bbfields){
  mnemonic <- toupper(mnemonic)
  b.typ <- c()
  for(i in mnemonic){
    b.typ <- c(b.typ, bbfields[which(i==bbfields$field.mnemonic),]$data.type)
  }
  r.typ <- c("character","double","double","character",
              "datetime","datetime","datetime","character","character",
              "logical","character")
  x <- r.typ[b.typ]
  if(length(x) == 0){
    return(NULL)
  }else{
    return(x)
  }   
}

field.info <- function(mnemonic, bbfields=.bbfields){
  mnemonic <- toupper(mnemonic)
  for(i in 1:length(mnemonic)){
    row_number <- which(mnemonic[i]==bbfields$field.mnemonic)
    if (length(row_number)!=1) {
      stop(paste("mnemonic", mnemonic, "not found in bbfields"))
    }
    r <- bbfields[row_number,]
    if (i==1) {
      b <- r
    } else {
      b <- rbind(b, r)
    }
  }
  return(b)
}

field.id            <- function(mnemonic) { as.character(as.hexmode(field.info(mnemonic)$field.id), upper.case=TRUE) } # field IDs cannot have leading zeros to look up in Bloomberg data files
field.name          <- function(mnemonic) { field.info(mnemonic)$field.name }
data.bitmask        <- function(mnemonic) { field.info(mnemonic)$data.bitmask }
market.bitmask      <- function(mnemonic) { field.info(mnemonic)$mkt.bitmask }
category.number     <- function(mnemonic) { field.info(mnemonic)$category } # "category" clashes with base, so call this category.number
category.name       <- function(mnemonic) { field.info(mnemonic)$category.name }

fieldName <- function(mnemonic) { field.name(mnemonic) }

# Use letters[] to get a quick char conversion 1=a, 2=b etc.
pad.4 <- function(str) {
  switch( 
    letters[nchar(str)],
    b=paste("00", str, sep=""),
    c=paste("0", str, sep=""),
    d=str,
    stop(paste(str, "should only have 2-4 chars!"))
  )
}

# IDs are recycled, so we need to exclude obsolete mnemonics which are in category 999.
field.mnemonic <- function(id, bbfields=.bbfields){
  id <- lapply(toupper(id), pad.4)
  return(bbfields[which( (bbfields$field.id %in% id) & (999!=bbfields$category) ),]$field.mnemonic)
}

# Why don't they have this in bitops?
# Returns a boolean.
isPowerOfTwo <- function(pwr) {
  return(bitAnd(pwr, pwr-1) == 0)
}

# Why don't they have this in bitops?
# Returns a boolean.
matchesBitMask <- function(arg, pwr) {
  if(!isPowerOfTwo(pwr)){
    stop("Argument must be a power of 2!")
  }
  return(bitAnd(arg, pwr) == pwr)
}

check.market <- function(mnemonic, market.code) {
  matchesBitMask(market.bitmask(mnemonic), market.code)
}

market.commodity   <- function(mnemonic) {check.market(mnemonic, 2)}
market.equity      <- function(mnemonic) {check.market(mnemonic, 4)}
market.muni        <- function(mnemonic) {check.market(mnemonic, 8)}
market.pdf         <- function(mnemonic) {check.market(mnemonic, 16)}
market.client      <- function(mnemonic) {check.market(mnemonic, 32)}
market.money       <- function(mnemonic) {check.market(mnemonic, 64)}
market.govt        <- function(mnemonic) {check.market(mnemonic, 125)}
market.corp        <- function(mnemonic) {check.market(mnemonic, 256)}
market.index       <- function(mnemonic) {check.market(mnemonic, 512)}
market.currency    <- function(mnemonic) {check.market(mnemonic, 1024)}
market.mortgage    <- function(mnemonic) {check.market(mnemonic, 2048)}

check.data <- function(mnemonic, data.code) {
  matchesBitMask(data.bitmask(mnemonic), data.code)
}

data.header             <- function(mnemonic) {check.data(mnemonic, 1)}
data.realtime           <- function(mnemonic) {check.data(mnemonic, 2)}
data.static             <- function(mnemonic) {check.data(mnemonic, 4)}
data.historical         <- function(mnemonic) {check.data(mnemonic, 8)}
data.intraday           <- function(mnemonic) {check.data(mnemonic, 16)}
data.enable.feature     <- function(mnemonic) {check.data(mnemonic, 32)}
data.market.depth       <- function(mnemonic) {check.data(mnemonic, 64)}
data.greeks             <- function(mnemonic) {check.data(mnemonic, 128)}
data.condition.code     <- function(mnemonic) {check.data(mnemonic, 256)}
data.bid.ask.only       <- function(mnemonic) {check.data(mnemonic, 512)}
