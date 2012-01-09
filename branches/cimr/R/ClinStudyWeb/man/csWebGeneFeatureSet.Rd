\name{csWebGeneFeatureSet}
\alias{csWebGeneFeatureSet}

\title{ Generate an annotated GeneFeatureSet }
\description{
  Retrieves sample annotation from the ClinStudyWeb database for a set of
  CEL files, and uses it to annotate the returned GeneFeatureSet object.
}
\usage{
csWebGeneFeatureSet ( files, uri, .opts=list(), cred=NULL, ... )
}
\arguments{

  \item{files}{A character vector of CEL file names.}

  \item{uri}{The URI for the clinical database web site.}

  \item{.opts}{A list of CURLOptions passed to \code{getURLContent}.}

  \item{cred}{An optional list of login credentials, as returned by the
    \code{getCredentials} function. This list should contain
    just two character entries, named ``username'' and ``password''.}

  \item{...}{Additional arguments are passed to the \code{ReadAffy} object.}

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

