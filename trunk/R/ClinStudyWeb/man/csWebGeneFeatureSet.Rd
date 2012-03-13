\name{csWebGeneFeatureSet}
\alias{csWebGeneFeatureSet}

\title{ Generate an annotated GeneFeatureSet }
\description{
  Retrieves sample annotation from the ClinStudyWeb database for a set of
  CEL files, and uses it to annotate the returned GeneFeatureSet object.
}
\usage{
csWebGeneFeatureSet ( files, pattern=NULL, categories=NULL, ... )
}
\arguments{

  \item{files}{A character vector of CEL file names.}

  \item{pattern}{A query term which can be used to specify annotation
    categories to be retrieved from the database. Wildcards are
    supported: '*' for multiple characters, '?' for single characters.}

  \item{categories}{ A character vector of category names which can be
    used to specify the annotation to be retrieved from the database. If
    the pattern argument has been used then this argument will be ignored.}

  \item{...}{Additional arguments are passed to the \code{oligo::read.celfiles}
    object. Authentication arguments are passed to the internal JSON query
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
  An annotated GeneFeatureSet object.
}
\references{ RCurl package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csWebQuery}}
}
\examples{
  \dontrun{csWebGeneFeatureSet( files=c('T234 CD4.CEL','L123 CD8.CEL'),
                           uri='http://my.webhost.com/' )}
}

