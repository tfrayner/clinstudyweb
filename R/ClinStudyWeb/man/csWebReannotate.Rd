\name{csWebReannotate-methods}
\docType{methods}
\alias{csWebReannotate-methods}
\alias{csWebReannotate, AffyBatch-method}
\alias{csWebReannotate, ExpressionSet-method}
\alias{csWebReannotate, RGList-method}
\alias{csWebReannotate, MAList-method}

\title{ Reannotate a data object using the ClinStudyWeb database }
\description{

  Given a data object from one of the supported classes, replace the
  object sample annotation data frame with a new data set extracted from
  the database.

}
\usage{
csWebReannotate ( data, uri, .opts=list(), cred=NULL )
}
\section{Methods}{
  \describe{

    \item{data = "AffyBatch"}{ When passed an AffyBatch object, this
      method will replace the pData slot with an updated annotation data
      frame. The data sampleNames() must correspond to the original CEL
      file names.}

    \item{data = "ExpressionSet"}{ When passed an ExpressionSet object, this
      method will replace the pData slot with an updated annotation data
      frame. The data sampleNames() must correspond to the original CEL
      file names.}

    \item{data = "RGList"}{ The targets attribute of the supplied RGList
      will be replaced with an updated targets data frame. The input
      RGList object must contain a valid RGList$targets$FileName listing. }

    \item{data = "MAList"}{ The targets attribute of the supplied MAList
      will be replaced with an updated targets data frame. The input
      MAList object must contain a valid MAList$targets$FileName listing. }

  }
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
\keyword{methods}
