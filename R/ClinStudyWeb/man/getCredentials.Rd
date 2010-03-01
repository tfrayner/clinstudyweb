\name{getCredentials}
\alias{getCredentials}

\title{ Ask the user for their login credentials }
\description{
  Displays a dialog box asking the user to enter their login and
  password, returning these values in a form suitable for use with \code{studyAffyBatch}.
}
\usage{
getCredentials ( title='Database Authentication', entryWidth=30, returnValOnCancel=NA )
}
\arguments{

  \item{title}{The title to use for the dialog box.}

  \item{entryWidth}{The character width of the entry fields.}

  \item{returnValOnCancel}{The username/password value to return if the
    user cancels the operation.}

}
\details{

  This function uses the Tk windowing system to query the user for login
  and password, without echoing the latter to the screen.

}
\value{
  A list containing just two elements:

  \item{username}{The username to use to log in to the database.}
  \item{password}{The corresponding password.}
}
\references{ Tk package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{studyAffyBatch}}
}
\examples{
  \dontrun{getCredentials()}
}

