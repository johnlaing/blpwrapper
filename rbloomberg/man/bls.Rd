\name{bls}
\alias{bls}
\title{Get Bloomberg Bulk Data}
\description{
  This is the primary user-level function for retrieving Bloomberg bulk data.
}
\usage{
blp(conn, securities, fields, override_fields = NULL, overrides NULL)
}
\arguments{
  \item{conn}{Connection object}
  \item{securities}{A single ticker string or a vector of tickers.}
  \item{fields}{A single field string or a vector of field names.}
  \item{override_fields, overrides}{Override field names and their corresponding values.}
}
\details{
Pass either a single security/field or a vector of securities and fields. Objects are converted with .jarray before being passed to the Java wrapper which accesses the Bloomberg API and returns the result.

All dates are passed through the format() function to be converted to Bloomberg's YYYYMMDD date format. You can pass in a string in this format and it will be left alone, or you can pass an object of any date/datetime class which will respond to format().

Overrides which are dates must be passed in "YYYYMMDD" format as per Bloomberg Version 3 API. 
}
\keyword{math}
\examples{
# Please consult unit tests for more examples.
\dontrun{
library(RBloomberg)
conn <- blpConnect(log.level = "finest")


security <- c("BKIR ID Equity")
field <- c("DVD_HIST")

bds(conn, security, field)[1:5,]

security <- "TYA Comdty"
field <- "FUT_DELIVERABLE_BONDS"

bds(conn, security, field)[1:5,]

security <- "UKX Index"
field <- "INDX_MEMBERS"

bds(conn, security, field)[1:5,]

securities <- c("UKX Index", "SPX Index")
fields <- c("INDX_MEMBERS", "INDX_MEMBERS2", "INDX_MEMBERS3")

bds(conn, securities, fields)[c(1:5, 350:355),]



}
}
\author{Ana Nelson \email{ana@ananelson.com}}

