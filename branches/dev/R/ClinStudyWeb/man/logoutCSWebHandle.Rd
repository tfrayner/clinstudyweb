\name{logoutCSWebHandle}
\alias{logoutCSWebHandle}

\title{ Terminate an authenticated CURLHandle session. }
\description{
  Log out from an authenticated connection to the ClinStudyWeb database
  web site.
}
\usage{
logoutCSWebHandle ( auth, .opts=list() )
}
\arguments{

  \item{auth}{An authenticated CURLHandle object as returned by \code{getCSWebHandle}.}

  \item{.opts}{A list of CURLOptions passed to \code{RCurl::getURLContent}.}
}
\details{
  Use of this function is recommended for security purposes.
}
\value{
  This function is executed for its side effects.
}
\author{ Tim F Rayner }
\seealso{
  \code{\link{getCredentials}}
  \code{\link{getCSWebHandle}}
}
\examples{
  \dontrun{logoutCSWebHandle(auth)}
}

