\name{reannotateFromClinWeb}
\alias{reannotateFromClinWeb}

\title{ Reannotate an ExpressionSet using the ClinStudy database }
\description{
  Given an ExpressionSet, or subclass thereof, replace the object pData
  data frame with a new data set extracted from the database.
}
\usage{
reannotateFromClinWeb ( data, uri, .opts=list(), cred=NULL )
}
\arguments{

  \item{data}{An ExpressionSet (or subclass such as AffyBatch) to
    reannotate. The data sampleNames() must correspond to the original
    CEL file names.}

  \item{uri}{The URI for the clinical database web site.}

  \item{.opts}{A list of CURLOptions passed to \code{getURLContent}.}

  \item{cred}{An optional list of login credentials, as returned by the
    \code{getCredentials} function. This list should contain
    just two character entries, named ``username'' and ``password''.}

  \item{...}{Additional arguments are passed to the \code{ReadAffy} object.}

}
\details{

  As the ClinStudy database develops it is convenient to be able to
  reannotate old data sets to account for new developments. This
  function allows you to do this.

  This function will generally be used interactively; it asks the user for
  username and password. It has been set up this way to avoid the
  temptation to hard-code passwords in R scripts. If, however, you
  really need to run this in some kind of loop you can pass in your
  login credentials as the \code{cred} argument.

}
\value{
  A reannotated ExpressionSet object.
}
\references{ RCurl package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{queryClinWeb}}
}
\examples{
  \dontrun{reannotateFromClinWeb(data,
                                 uri='http://my.webhost.com/' )}
}

