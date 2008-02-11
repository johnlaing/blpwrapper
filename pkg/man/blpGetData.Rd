\name{blpGetData}
\alias{blpGetData}
\alias{blpGetData.default}
\alias{blpGetData.BlpCOMConnect}
\title{Get Bloomberg Data}
\description{
  This is the primary user-level function for retrieving Bloomberg
  data. Requests fall into four types: snapshot, historical, intraday
  bars, and intraday tick. The first type of call returns either static
  data or realtime data read at the time the function call is made. The
  remaining three call types return timeseries.
}
\usage{
blpGetData(x, \dots)
\method{blpGetData}{default}(x, \dots)
\method{blpGetData}{BlpCOMConnect}(x, securities, fields, start = NULL, end = NULL,
           barsize = NULL, barfields = NULL, retval = NULL, \dots)
}
\arguments{
  \item{x}{connection object.}
  \item{securities}{vector of Bloomberg tickers.}
  \item{fields}{vector of field mnumonics. For intraday requests, this
    must be one or more of "BID", "ASK", and "LAST\_PRICE".}
  \item{start,end}{chron object defining data window.}
  \item{barsize}{integer representing the duration (in clock minutes)
       of the bar intervals in an intraday bar timeseries request. If
       set to 0, the request is for intraday tick resolution. If NULL,
       the request is historical.}
  \item{barfields}{field aspect for intraday bar requests. One or more
       of "OPEN", "HIGH", "LOW", "LAST\_PRICE", "NUMBER\_TICKS", and
       "VOLUME". Number of fields returned is the length of
       \code{fields} times \code{barfields}.}
  \item{retval}{"matrix","data.frame", "zoo", or "raw". If NULL, return a zoo
    for timeseries requests and a data.frame for snapshot
    requests; "raw" will return the uncoerced, nested list.}
  \item{\dots}{other args.}
}
\details{
  The user specifies type of request through his choice of
  parameters. If no argument is passed to \code{start}, then a snapshot
  call is made. All three timeseries require that a chron object is
  passed to \code{start}. If nothing is passed to \code{barsize}, then a
  historical call is made. If \code{barsize=0}, a tick call is made. If
  \code{barsize} is passed an integer of 1 or greater, a bar call is
  made. All and only bar calls pass at least one mnumonic to
  \code{barfields}.
  
  Conceptually, a tick is a timestamped (to the clock second) record of
  six fields containing bid/ask/last price and size. An intraday tick
  call returns an ordered timeseries of tick records. A tick exists when
  and only when at least one of the six fields changes values. Thus, for two
  consecutive ticks, T1 and T2, the values of the six fields in T1 can
  be assumed to persist throughout the period of time that elapses
  between the timestamps of T1 and T2.

  An intraday bar call summarises (according to the mnumonic passed to
  \code{barfields}) the ticks that occur within fixed time
  intervals. The interval size is defined by \code{barsize}, which works
  at the clock minute resolution specified by the integer value passed
  to it.
  
  Most of the information here is conjectural, based on trial-and-error
  usage of the Bloomberg API as opposed to references to the API
  documentation. You have been warned. 
}

\section{Bugs}{
  There are no bugs of which I am aware. There are, however, a couple of
  idiosyncracies with the Bloomberg interface that you should keep in
  mind. 

  First, when \code{fields} contains "BID" and/or "ASK" and
  \code{barfields} contains "VOLUME", Bloomberg will return the sum of
  all bid/ask sizes, which is misleading. For example, if \code{barsize
    = 1}, the number of ticks for bar 18:30 is 3 and the ask sizes at
  each tick are 1000, 1020, and 1020, then the volume will be 3040. Use
  "VOLUME" combined with "NUMBER\_TICKS" fields to back out
  an average bid/ask size. 

  Second, the "VOLUME" barfield returns a value of 0.00 instead of na's for bars
  containing no ticks. This is a problem for the special case whereby a
  bid or ask price is missing. For example, suppose you make a call with
  \code{fields="BID"} and \code{barfields="VOLUME"} and there is a bar
  in the return where \code{BID.VOLUME} is \code{0.00}. That result is
  consistent with two scenarios: (1) the bid size and price in this bar is
  the same as it was in the previous bar and (2) there is \emph{no} bid
  in this bar. To my knowledge, there is no way of determining which
  case holds.
}
\examples{
\dontrun{
conn <- blpConnect()

## Snapshot 
eda <- blpGetData(conn, c("ED5 Comdty","ED6 Comdty","ED7 Comdty",
"ED8 Comdty"), "BID")

## Historical (last 30 days)
edb <- blpGetData(conn, "ED1 Comdty", "PX_LAST",
start=as.chron(Sys.time() - 86400 * 30))

## Intraday bars (last hour in 2 min bars)
edc <- blpGetData(conn, "ED1 Comdty", c("BID","ASK"),
start=as.chron(Sys.time() - 3600), barfields="OPEN", barsize=2)

## Tick-by-tick (3 minutes starting an hour ago)
edd <- blpGetData(conn, "ED1 Comdty", c("BID"),
start=as.chron(Sys.time() - 3600),
end=as.chron(Sys.time() - 3420), barsize=0)

blpDisconnect(conn)
}
}
\keyword{math}
\author{Robert Sams \email{robert@sanctumfi.com}}





