\name{csWebQuery}
\alias{csWebQuery}

\title{ Query the ClinStudyWeb database via its REST API }
\description{
  Retrieves sample annotation for a given array barcode or filename.
}
\usage{
csWebQuery ( assay.file=NULL, assay.barcode=NULL, uri, username,
password, .opts )
}
\arguments{

  \item{assay.file}{The name of the file of interest.}

  \item{assay.barcode}{The barcode used for the assay of interest.}

  \item{uri}{The top-level URI for the clinical database web site.}

  \item{username}{A username authorised to use the REST API.}

  \item{password}{The corresponding password.}

  \item{.opts}{A list of CURLOptions passed to \code{getURLContent}.}

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
                       username='johndoe',
                       password='mylongandnowincrediblyinsecurepassword' )}
}

