\name{csWebQuery}
\alias{csWebQuery}

\title{ Query the ClinStudyWeb database via its REST API }
\description{
  Retrieves sample annotation for a given array barcode or filename.
}
\usage{
csWebQuery ( assay.file=NULL, assay.barcode=NULL, sample.name=NULL,
                 query=list(), ... )
}
\arguments{

  \item{assay.file}{The name of the file of interest.}

  \item{assay.barcode}{The barcode used for the assay of interest.}

  \item{sample.name}{The identifier of the sample of interest. If used,
    this argument causes the database query to ignore all assay information.}

  \item{query}{An optional list of JSON query parameters to be passed
    through to the web server. Examples include test_ids, phenotype_pattern.}

  \item{...}{Further arguments passed to the internal JSON query
    function. Examples are "auth" (see \code{getCredentials} and
    \code{getCSWebHandle}) and "uri".}
  
}
\details{

  Either assay.file or assay.barcode must be provided; uri, username and
  password are also all required. Note that it is unwise to hard-code
  your authentication credentials in your R code as this is potentially
  highly insecure; rather, it is better to use an approach similar to
  that used by the \code{csWebAffyBatch} function, which prompts the user
  for username and password interactively and then passes those on to
  \code{csWebQuery}.

}
\value{
  A list giving key-value pairs defining sample attributes.
}
\references{ RCurl package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csWebAffyBatch}}
}
\examples{
  \dontrun{csWebQuery( assay.file='T234 CD4.CEL',
                       uri='http://my.webhost.com/',
                       auth=list(username='johndoe',
                                 password='mylongandnowincrediblyinsecurepassword') )}
}

