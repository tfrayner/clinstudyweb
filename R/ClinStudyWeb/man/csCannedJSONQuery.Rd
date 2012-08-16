\name{csCannedJSONQuery}
\alias{csPatients}
\alias{csVisits}
\alias{csSamples}
\alias{csAssays}
\alias{csTransplants}
\alias{csPriorTreatments}

\title{ Query the ClinStudyWeb database }
\description{
  Simple but powerful database queries using the JSON API.
}
\usage{
csPatients( trial_id=NULL, id=NULL, study=NULL, diagnosis=NULL,
extended=FALSE, ... )

csVisits( trial_id=NULL, id=NULL, date=NULL, nominal_timepoint=NULL,
data_file=NULL, extended=FALSE, ... )

csSamples( trial_id=NULL, id=NULL, name=NULL, date=NULL, cell_type=NULL,
material_type=NULL, data_file=NULL, extended=FALSE, ... )

csAssays( id=NULL, sample_id=NULL, filename=NULL, identifier=NULL,
date=NULL, batch=NULL, extended=FALSE, ... )

csTransplants( trial_id=NULL, id=NULL, date=NULL, organ_type=NULL,
extended=FALSE, ... )

csPriorTreatments( trial_id=NULL, id=NULL, type=NULL,
extended=FALSE, ... )
}
\arguments{

  \item{trial_id}{A list of patterns to use as a query for the patient
    trial ID.}

  \item{id}{Internal database IDs for the objects being queried.}

  \item{date}{Dates attached to the queried
    object type (e.g. visit date for \code{csVisits}).}

  \item{name}{Names attached to the object (e.g. sample name).}

  \item{study}{Patient study types.}

  \item{diagnosis}{Patient diagnosis terms.}

  \item{nominal_timepoint}{Nominal timepoints for clinic visits.}

  \item{cell_type}{Cell types for samples.}

  \item{material_type}{Material types for samples.}

  \item{data_file}{The name of a data file (typically FACS data)
    associated with the sample or visit. This is distinct from assay
    filename, below.)}

  \item{sample_id}{Internal database sample identifier (used to query
    assays).}

  \item{filename}{Assay filenames.}

  \item{identifier}{Assay identifiers.}

  \item{batch}{Assay batch names.}

  \item{organ_type}{Transplant organ types.}

  \item{type}{The type of the queried object (e.g. prior treatment types).}

  \item{extended}{A boolean flag indicating whether or not to return
    extended annotation.}

  \item{...}{Further arguments passed to the JSON query
    function. Examples are "auth" (see \code{getCredentials} and
    \code{getCSWebHandle}) and "uri".}

}
\details{

  These functions are intended for general use; they provides the ability to
  retrieve extended clinical data from the database using simple queries.

  Each function takes a series of query arguments, and an additional,
  optional "extended" argument which is used to request additional
  annotation from the database.

  Each query argument can accept a character vector of patterns using
  the '*' and '?' wildcards. The patterns for a given argument are
  combined using OR, while the results for separate arguments are
  combined using AND. For example, to query for certain clinic visits
  from specific patients:

   csVisits(trial_id=c('T1*', 'T2*'),
            nominal_timepoint=c('0 months', '3 months'))

}
\value{

  A named list of data frames containing the annotation. The first
  element of the list corresponds to core information regarding the
  subject of the query (be it patients, visits, etc.). If extended=TRUE,
  this data frame is supplemented by a number of other data frames
  appended to the returned list.

}
\references{ RCurl package, rjson package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csJSONQuery}}
}
\examples{
  \dontrun{
 x <- csPatients(trial_id='60?', studies='Transplant', extended=TRUE)
  }
}

