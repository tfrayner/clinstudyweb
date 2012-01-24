\name{getCredentials}
\alias{getCredentials}

\title{ Ask the user for their login credentials }
\description{
  Displays a dialog box asking the user to enter their login and
  password, returning these values in a form suitable for use with \code{studyAffyBatch}.
}
\usage{
getCredentials ( title='ClinStudyWeb Authentication', entryWidth=30,
returnValOnCancel=NA, parent )
}
\arguments{

  \item{title}{The title to use for the dialog box.}

  \item{entryWidth}{The character width of the entry fields.}

  \item{returnValOnCancel}{The username/password value to return if the
    user cancels the operation.}

  \item{parent}{An optional Tk widget to use as the parent for the
    displayed login dialog box.}
}
\details{

  This function uses the Tk windowing system to query the user for login
  and password, without echoing the latter to the screen. The returned
  list can be used as the 'auth' argument to any of the JSON query
  functions, in which case a separate 'uri' argument specifying the base
  URI of the ClinStudyWeb database web site is required (see also
  \code{getCSWebHandle}).

}
\value{
  A list containing just two elements:

  \item{username}{The username to use to log in to the database.}
  \item{password}{The corresponding password.}
}
\references{ Tk package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csWebQuery}}
  \code{\link{csWebAffyBatch}}
  \code{\link{csWebRGList}}
  \code{\link{getCSWebHandle}}
}
\examples{
  \dontrun{getCredentials()}
}

