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
#EXAMPLE
}
\author{Ana Nelson \email{ana@ananelson.com}}

