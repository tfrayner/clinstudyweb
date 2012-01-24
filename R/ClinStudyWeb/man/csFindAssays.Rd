\name{csFindAssays}
\alias{csFindAssays}

\title{ Query Assay information from the database }
\description{
  Retrieves assay data via the JSON API using a simplified function call.
}
\usage{
csFindAssays(cell.type, platform, batch.name, study,
             diagnosis, timepoint, trial.id, ... )
}
\arguments{

  \item{cell.type}{The cell type CV term to match against (e.g. 'CD8').}

  \item{platform}{The assay platform CV term to match against
    (e.g. 'Affy GeneST').}

  \item{batch.name}{The assay batch name to match against (e.g. 'triad0056').}

  \item{study}{The study type CV term to match against (e.g. 'Vasculitis').}

  \item{diagnosis}{The diagnosis CV term to match against
    (e.g. "Wegener's Granulomatosis").}

  \item{timepoint}{The timepoint CV term to match against (e.g. '0 months').}

  \item{trial.id}{The patient trial ID to match against (e.g. '181').}

  \item{...}{Further arguments passed to the JSON query
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
  \code{csFindAssays}.

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
  \dontrun{csFindAssays( assay.file='T234 CD4.CEL',
                       uri='http://my.webhost.com/',
                       auth=list(username='johndoe',
                                 password='mylongandnowincrediblyinsecurepassword') )}
}

