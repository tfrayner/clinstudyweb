\name{getCSWebHandle}
\alias{getCSWebHandle}

\title{ Obtain an authenticated CURLHandle for the ClinStudyWeb database. }
\description{
  Connects to the ClinStudyWeb database web site and obtains a
  persistent authenticated connection for use with other functions in
  this package.
}
\usage{
getCSWebHandle ( uri=NULL, auth, .opts=list() )
}
\arguments{

  \item{uri}{Required. The base URI for the ClinStudyWeb database web site.}

  \item{auth}{An optional list containing two values: username and
    password. Typically this will have been captured using
    \code{getCredentials}, which is called if this argument is missing.}

  \item{.opts}{A list of CURLOptions passed to \code{RCurl::getURLContent}.}
}
\details{

  This function is primarily intended to allow connections to be made to
  the database which will support multiple sequential queries without
  requiring additional authentication. The returned CURLHandle object
  contains session information which allows it to access protected areas
  of the database JSON web interface.

  The returned object can be used as the 'auth' argument to any of the
  core JSON query functions. When using an authenticated CURLHandle as
  the 'auth' argument, the 'uri' argument is no longer required.

  Use the \code{logoutCSWebHandle} function to properly end the JSON
  query session.

}
\value{
  An authenticated CURLHandle object.
}
\author{ Tim F Rayner }
\seealso{
  \code{\link{getCredentials}}
  \code{\link{logoutCSWebHandle}}
}
\examples{
  \dontrun{getCSWebHandle(uri='http://my.host.com')}
}

