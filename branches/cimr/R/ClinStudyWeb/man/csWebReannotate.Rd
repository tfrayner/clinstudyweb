\name{csWebReannotate}
\alias{csWebReannotate}

\title{ Reannotate a data object using the ClinStudyWeb database }
\description{

  Given a data object from one of the supported classes, replace the
  object sample annotation data frame with a new data set extracted from
  the database.

}
\usage{
csWebReannotate ( data, sample.column=NULL, ... )
}
\arguments{

  \item{data}{A data object to reannotate. See the individual methods
    documentation for more details.}

  \item{sample.column}{An optional argument indicating the column of the
    data object's annotation which contains sample identifiers. If used,
    these identifiers will be used to retrieve annotation instead of the
    assay file names. As a result no assay annotation will be included
    in the output.}

  \item{...}{Additional arguments passed in to the internal JSON query
    functions. These may either be arguments such as "pattern" or
    "categories" which allow specification of the annotation to be
    retrieved, or authentication details. Examples of the latter are
    "auth" (see \code{getCredentials} and \code{getCSWebHandle}) and "uri".}
  
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
