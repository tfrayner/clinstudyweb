\name{csWebReannotate}
\alias{csWebReannotate}

\title{ Reannotate a data object using the ClinStudyWeb database }
\description{

  Given a data object from one of the supported classes, replace the
  object sample annotation data frame with a new data set extracted from
  the database.

}
\usage{
csWebReannotate ( data, uri, .opts=list(), cred=NULL )
}
\arguments{

  \item{data}{A data object to reannotate. See the individual methods
    documentation for more details.}

  \item{uri}{The URI for the clinical database web site.}

  \item{.opts}{A list of CURLOptions passed to \code{getURLContent}.}

  \item{cred}{An optional list of login credentials, as returned by the
    \code{getCredentials} function. This list should contain
    just two character entries, named ``username'' and ``password''.}

}
\details{

  As the ClinStudyWeb database develops it is convenient to be able to
  reannotate old data sets to account for new developments. This
  function allows you to do this.

  This function will generally be used interactively; it asks the user for
  username and password. It has been set up this way to avoid the
  temptation to hard-code passwords in R scripts. If, however, you
  really need to run this in some kind of loop you can pass in your
  login credentials as the \code{cred} argument.

}
\value{
  A reannotated data object.
}
\references{ RCurl package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csWebQuery}}
}
\examples{
  \dontrun{csWebReannotate(data,
                           uri='http://my.webhost.com/' )}
}
