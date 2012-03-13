\name{csWebRGList}
\alias{csWebRGList}

\title{ Generate an annotated RGList }
\description{
  Retrieves sample annotation from the ClinStudyWeb database for a set of
  data files, and uses it to annotate the returned RGList object.
}
\usage{
csWebRGList ( files, pattern=NULL, categories=NULL, ... )
}
\arguments{

  \item{files}{A character vector of data file names.}

  \item{pattern}{A query term which can be used to specify annotation
    categories to be retrieved from the database. Wildcards are
    supported: '*' for multiple characters, '?' for single characters.}

  \item{categories}{ A character vector of category names which can be
    used to specify the annotation to be retrieved from the database. If
    the pattern argument has been used then this argument will be ignored.}

  \item{...}{Additional arguments are passed to the \code{limma::read.maimages}
    function. Authentication arguments are passed to the internal JSON query
    function. Examples are "auth" (see \code{getCredentials} and
    \code{getCSWebHandle}) and "uri".}
  
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

