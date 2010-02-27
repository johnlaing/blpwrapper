\name{blpConnect}
\alias{blpConnect}
\alias{blpDisconnect}
\title{Open or shut a connection to Bloomberg}
\description{
  The function \code{blpConnect} returns a connection object to one of
  the Bloomberg interfaces. Currently, only the Java Version 3 API is
  supported.
}
\usage{
blpConnect(iface="Java")
blpDisconnect(conn)
}
\arguments{
  \item{iface}{Which Bloomberg interface? (only "Java" currently supported).}
  \item{conn}{Connection object}
}
\details{
  Connections to other APIs may be developed in future.
}
\keyword{math}
\examples{
\dontrun{conn <- blpConnect()
blpDisconnect(conn)}
}
\author{Ana Nelson \email{ana@ananelson.com}}

