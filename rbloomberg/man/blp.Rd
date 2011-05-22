\name{blp}
\alias{blp}
\title{Get Bloomberg Reference Data}
\description{
  This is the primary user-level function for retrieving Bloomberg reference data.
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

Overrides which are dates must be passed in "YYYYMMDD" format as per Bloomberg Version 3 API. 
}
\keyword{math}
\examples{
# Please consult unit tests for more examples.
\dontrun{
library(RBloomberg)
conn <- blpConnect()

bdp(conn, "AMZN US Equity", "NAME")

securities <- c("AMZN US Equity", "OCN US Equity")
fields <- c("NAME", "PX_LAST", "TIME", "SETTLE_DT", "HAS_CONVERTIBLES") # Demo different return data types.
bdp(conn, securities, fields)

securities <- c("AMZN US Equity", "OCN US Equity")
fields <- c("CUST_TRR_RETURN_HOLDING_PER")
override_fields <- c("CUST_TRR_START_DT", "CUST_TRR_END_DT", "CUST_TRR_CRNCY")
overrides <- c("20090601", "20091231", "PRC")
bdp(conn, securities, fields, override_fields, overrides)

securities <- c("RYA ID EQUITY", "OCN US EQUITY", "YHOO US EQUITY")
fields <- c("LT_DEBT_TO_COM_EQY")
override_fields <- c("EQY_FUND_DT")
overrides <- c("20051231")
bdp(conn, securities, fields, override_fields, overrides)

override_fields <- c("EQY_FUND_DT")
overrides <- c("20061231")
bdp(conn, securities, fields, override_fields, overrides)

fields <- c("CRNCY_ADJ_PX_LAST")
override_fields <- c("EQY_FUND_CRNCY")
overrides <- c("JPY")
bdp(conn, securities, fields, override_fields, overrides)
overrides <- c("CHF")
bdp(conn, securities, fields, override_fields, overrides)

# Retrieve by SEDOL
bdp(conn, "/SEDOL1/2292612 EQUITY", "NAME")

blpDisconnect(conn)


}
}
\author{Ana Nelson \email{ana@ananelson.com}}

