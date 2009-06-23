\name{lowlevel}
\alias{blpGetHistoricalData}
\alias{blpSubscribe}
\alias{as.COMDate.chron}
\alias{as.chron.COMDate}
\alias{as.matrix.BlpCOMReturn}
\alias{as.data.frame.BlpCOMReturn}
\alias{as.zoo.BlpCOMReturn}
\alias{replaceBloombergErrors}
\alias{dataType}
\title{Low Level Functions}
\description{
  These functions are not to be called by the user. This is ad-hoc
  documentation for developers of this package.
}
\usage{
blpGetHistoricalData(conn, securities, fields, start, end, barsize = NULL,
                     barfields = NULL)
blpSubscribe(conn, securities, fields)
replaceBloombergErrors(x, suppress = TRUE)
dataType(mnemonic, bbfields = .bbfields)
\method{as.COMDate}{chron}(x, date1904 = FALSE)
\method{as.chron}{COMDate}(x, date1904 = FALSE, \dots)
\method{as.matrix}{BlpCOMReturn}(x)
\method{as.data.frame}{BlpCOMReturn}(x, row.names = NULL, optional =
FALSE, \dots)
\method{as.zoo}{BlpCOMReturn}(x, suppress = TRUE, bbfields = .bbfields, \dots)
}
\arguments{
  \item{x}{object}
  \item{conn}{connection object}
  \item{securities}{vector of Bloomberg security codes}
  \item{fields}{vector of field mnumonics}
  \item{start,end}{chron object defining data window}
  \item{barsize}{see blpGetData documentaion}
  \item{barfields}{see blpGetData documentaion}
  \item{date1904}{see below}
  \item{suppress}{logical. do not raise warnings when Bloomberg error codes are
    converted to NA's}
  \item{mnemonic}{Bloomberg field mnemonic, as documented in bbfields}
  \item{bbfields}{dataframe containing data in bbfields}
  \item{row.names}{ignored}
  \item{optional}{ignored}
  \item{\dots}{other args}
}
\details{
  At the moment this package can connect to Bloomberg only via the COM
  Desktop interface. Support for other Bloomberg interfaces are
  invisioned, especially the C Server interface.
  
  The user interacts with Bloomberg via the \code{blpGetData}
  function. This is a generic and a method will eventually exist for
  each Bloomberg interface. The idea is that calls to it and the values
  returned by it are exactly the same, regardless of the actual
  interface used, which is determined by the class of the connection
  object passed to the first argument of \code{blpGetData}. In short:
  user code is devorced from choice of interface. That's the
  aim. Currently, only one method exists, \code{blpGetData.BlpCOM}.

  All COM requests return a nested list, the nesting structure
  implicitly defining the return value's dimension and preserving data
  types. At present, we only support two-dimensional return values
  (e.g.,  a multiple security, mutiple field timeseries request is not
  allowed). 

  First, the nested list is transformed into something useful by
  coercing it to a vector, thereby implicitly coercing everything to the
  character data type if there is at least one non-numeric item in the
  return. If there are any Bloomberg error codes, these are then
  converted to NA's. Finally, the columns are recoved by setting the dim
  attribute based on what we know about the request. If the request is
  for a timeseries, the leftmost column is the COM date index, 
  represented numerically. We use \code{as.chron(mtx[1,])} to get back
  chron dates.

  If there are multiple data types in a single return, a dataframe is
  the natural structure for Bloomberg return values. But how do we
  recover the data types? (Note: a single Bloomberg error code in a
  numeric field will cause that field to be coerced into character mode
  on the strategy implimented here.) When RBloomberg is attached, the
  .bbfields file on the user's workstation is read and stored as a
  dataframe in .bbfields on the workspace. Every field availiable from
  the Bloomberg API is mapped onto a datatype in this file. RBloomberg
  maps these datatypes to R datatypes. We use this information to
  recover datatypes when a data.frame is required.

  \code{blpGetHistoricalData} and \code{blpSubscribe} are both wrappers to the COM
  methods of the same name. Depending on what is passed to
  \code{blpGetHistoricalData}, either a historical, intraday bars, or intraday
  tick request is made. \code{blpSubscribe} is for non-time series requests. Both
  functions return an object of class 'BlpCOMReturn', which is nothing more
  than the list returned by the COM method with some attributes attached. 
  The attributes provide meta-information that the coercion methods need
  to coerce the nested list returned by COM.

  Users pass chron dates to blpGetData and they always get chron
  dates. But COM requests expect COM dates and return COM dates, which are
  floating point reals representing the number of days since 1900. Two
  coercion functions \code{as.Date.comDate} and \code{as.comDate.Date} are
  provided to deal with this. For a discussion of the issue surrounding
  the treatment of 1904, see
  \url{http://cpearson.com/excel/datetime.htm}.

}
\references{
  From your Bloomberg terminal, use function WAPI:
  \tabular{ll}{
    "BLPGetHistoricalData Property" \tab Ref\# FRP003 \cr
    "History, Raw Tick and Time-Bar Requests" \tab Ref\# DP015 \cr
    "Extended Historical Data Requests" \tab Ref\# DBExt \cr
    "Appendix C: Ticker Syntax" \tab Ref\# APX003 \cr
    "Appendix D: Reading the Data Dictionary" \tab Ref\# CAX041\cr
    "Appendix G: Error Codes" \tab Ref\# APX007 
  }
  Also, threads in the R-sig-finance mailing list archives:
  \tabular{ll}{
    "Import from Bloomberg" \tab Enrique Bengoechea, 6 Jul 04 \cr
    "Bloomberg data import" \tab David L. Reiner, 31 Mar 05 
  }
}
\keyword{math}
\author{Robert Sams \email{robert@sanctumfi.com}}
