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
library(RBloomberg)
conn <- blpConnect()

bdh(conn, "GOLDS Comdty", "PX_LAST", "20090101", "20090107")

Sys.setenv(TZ="GMT")
start.date <- as.POSIXct("2009-01-01")
end.date <- as.POSIXct("2009-01-07")

bdh(conn, "GOLDS Comdty", "PX_LAST", start.date, end.date)

bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)

library(zoo)
result <- bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 10)
zoo(result, order.by = rownames(result))

bdh(conn, "GOLDS Comdty", "PX_LAST", Sys.Date() - 366, 
    option_names = "periodicitySelection", option_values = "MONTHLY")

df <- bdh(conn, c("AMZN US Equity", "GOOG US Equity", "MSFT US Equity"), 
    c("PX_LAST", "BID"), start.date, end.date)
df
na.omit(df)

bdh(conn, c("AMZN US Equity"), c("PX_LAST", "BID"), start.date, end.date, 
    always.display.tickers = TRUE)

bdh(conn, c("AMZN US Equity"), c("PX_LAST", "BID"), start.date, end.date, 
    always.display.tickers = TRUE, dates.as.row.names = FALSE)

bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090401", "20090410")

# We should get NULL back when there's no data...
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405")

# To return rows for all requested dates, even when they have no data...
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405", 
    include.non.trading.days = TRUE)

# This is equivalent to...
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405",
    option_names = c("nonTradingDayFillOption", "nonTradingDayFillMethod"),
    option_values = c("ALL_CALENDAR_DAYS", "NIL_VALUE"))

# Consult API documentation for other available option values.
bdh(conn, "/SEDOL1/2292612 EQUITY", c("PX_LAST", "BID"), "20090405", "20090405",
    option_names = c("nonTradingDayFillOption", "nonTradingDayFillMethod"),
    option_values = c("ALL_CALENDAR_DAYS", "PREVIOUS_VALUE"))

blpDisconnect(conn)

}
}
\author{Ana Nelson \email{ana@ananelson.com}}

