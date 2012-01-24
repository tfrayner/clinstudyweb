\name{csDrugQuery}
\alias{csDrugQuery}

\title{ Retrieve drug information from the ClinStudyWeb database }
\description{
  Simplified query system for retrieving drug information linked to
  Assays in the database. Minimal query constraints are supported.
}
\usage{
csDrugQuery( filename=NULL, identifier=NULL, drug.type=NULL,
             months.prior=NULL, prior.treatment.type=NULL,
             ... )
}
\arguments{

  \item{filename}{The filename of the Assay to query. Either this or
    Assay identifier must be specified.}

  \item{identifier}{The identifier of the Assay to query. Either this or
    Assay filename must be specified.}

  \item{drug.type}{A ControlledVocab DrugType term to limit the types of
    drugs retrieved. Example: 'immunosuppression'. Please consult the
    database for suitable CV terms.}

  \item{months.prior}{The number of months prior to the Visit linked to
    the Assay to search for drug treatments. Note that this form of
    query can only search for drug treatments with known dates,
    i.e. attached to specific clinical visits. See also
    prior.treatment.type, below.}

  \item{prior.treatment.type}{In addition to drug treatments attached to
    Visits, the database also stores legacy data in a more free-text form
    for cases where there has been a treatment some time in the past but
    for which there are sparse details. These data can be queried by
    specifying a prior.treatment.type (e.g. 'historical drug therapy',
    'drug therapy at entry'). Note that using this option will override
    the months.prior option, although it will still honour drug.type.}

  \item{...}{Further arguments passed to the JSON query
    function. Examples are "auth" (see \code{getCredentials} and
    \code{getCSWebHandle}) and "uri".}
  
}
\details{

  This function connects to the web interface and runs some potentially
  quite complex queries against the drug information stored in the
  database. Drugs are stored in the database as controlled vocabulary
  terms in a proto-ontology which links these drugs with concepts such
  as drug action and synonyms. This function attempts to make the use of
  that system as simple as possible, providing just a handful of
  available query constraints which may be used to limit the results to
  the most interesting drug types.

}
\value{

  A list of lists; each top-level list element corresponds to an Assay
  channel, named by label. Each channel has three entries:

  \item{drugs}{ A list of the DrugName terms retrieved. }

  \item{sample}{ The Sample name. }

  \item{label}{ The Channel label (e.g. Cy3). }

}
\references{ RCurl package, rjson package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csFindAssays}}
}
\examples{
  \dontrun{
 x <- csDrugQuery('some_filename.CEL',
                  prior.treatment.type='drug therapy at entry',
                  drug.type='immunosuppression',
                  auth=auth,
                  uri=uri)
  }
}

