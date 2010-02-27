\name{blh}
\alias{blh}
\title{Get Bloomberg Historical Data}
\description{
  This is the primary user-level function for retrieving Bloomberg historical data.
}
\usage{
blp(conn, securities, fields, start_date, end_date = NULL, override_fields = NULL, overrides NULL)
}
\arguments{
  \item{conn}{Connection object}
  \item{securities}{A single ticker string or a vector of tickers.}
  \item{fields}{A single field string or a vector of field names.}
  \item{start_date}{Start date for data retrieved, either as a YYYYMMDD format string or a date object of any class which responds correctly to format().}
  \item{end_date}{Optional end date for data retrieved, in the same format as start_date.}
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
#EXAMPLE
}
\author{Ana Nelson \email{ana@ananelson.com}}

