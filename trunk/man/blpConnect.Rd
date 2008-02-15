\name{blpConnect}
\alias{blpConnect}
\alias{blpDisconnect}
\title{Open or shut a connection to Bloomberg}
\description{
  The function \code{blpConnect} returns a connection object to one of
  the Bloomberg interfaces. Currently, only the COM Desktop API is
  supported.
}
\usage{
blpConnect(iface="COM", timeout=12000, show.days="week",
na.action="na", periodicity="daily")
blpDisconnect(conn)
}
\arguments{
  \item{iface}{Which Bloomberg interface? (only "COM" currently supported).}
  \item{timeout}{Timeout in Seconds}
  \item{show.days}{"trading", "week", or "all"}
  \item{na.action}{"bloomberg.handles", "previous.days", or "na"}
  \item{periodicity}{"daily", "weekly", "monthly", or "annual"}
  \item{conn}{Connection object}
}
\details{
  Connection to other API's provided by Bloomberg (e.g., C Desktop API
  and C Server API) will be accessable via this function in future
  releases of this package. Currently, the object returned is of class
  'BlpCOMConnect'.

  \#\# FIX ME \#\#
}
\keyword{math}
\examples{
## by default establish connection via Desktop COM API
\dontrun{conn <- blpConnect()
blpDisconnect(conn)}
}
\author{Robert Sams \email{robert@sanctumfi.com}}


