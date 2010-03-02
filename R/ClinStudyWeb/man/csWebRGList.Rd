\name{csWebRGList}
\alias{csWebRGList}

\title{ Generate an annotated RGList }
\description{
  Retrieves sample annotation from the ClinStudyWeb database for a set of
  data files, and uses it to annotate the returned RGList object.
}
\usage{
csWebRGList ( files, uri, .opts=list(), cred=NULL, ... )
}
\arguments{

  \item{files}{A character vector of data file names.}

  \item{uri}{The URI for the clinical database web site.}

  \item{.opts}{A list of CURLOptions passed to \code{getURLContent}.}

  \item{cred}{An optional list of login credentials, as returned by the
    \code{getCredentials} function. This list should contain
    just two character entries, named ``username'' and ``password''.}

  \item{...}{Additional arguments are passed to the \code{read.maimages} object.}

}
\details{

  This function will generally be used interactively; it asks the user for
  username and password. It has been set up this way to avoid the
  temptation to hard-code passwords in R scripts. If, however, you
  really need to run this in some kind of loop you can pass in your
  login credentials as the \code{cred} argument.

}
\value{
  An annotated RGList object.
}
\references{ RCurl package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csWebQuery}}
}
\examples{
  \dontrun{csWebRGList( files=c('T234_CD4.txt,'L123_CD8.txt'),
                        uri='http://my.webhost.com/' )}
}

