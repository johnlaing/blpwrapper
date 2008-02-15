\name{blpReadFields}
\alias{blpReadFields}
\title{Read bbfields.tbl file into workspace.}
\description{
  Read into the workspace the file \code{bbfields.tbl} located on the local
  machine.
}
\usage{
blpReadFields(path = "C:/blp/API")
}
\arguments{
  \item{path}{character. path where \code{bbfields.tbl} can be found.}
}
\details{
  In order to perform datatype mapping, RBloomberg needs to consult the
  Bloomberg API file \code{bbfields.tbl} located on the machine running the
  Bloomberg terminal. We don't physically search the file each time
  a datatype mapping is needed. Instead, we read the entire contents of
  the file into the workspace and store it in a hidden dataframe
  \code{.bbfields}.

  This is attempted when the package is first loaded. If the file is not
  found in \code{C:/blp/API}, you must manually specify the correct path
  using this function.
}
\keyword{math}
\examples{
.bbfields <- blpReadFields()
}
\author{Robert Sams \email{robert@sanctumfi.com}}


