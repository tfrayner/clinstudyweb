\name{csWebDrugInfo}
\alias{csWebDrugInfo}

\title{ Annotate a Bioconductor data object with drug information from the ClinStudyWeb database }
\description{
  Use the filenames from a Bioconductor data object to retrieve drug
  information from the database.
}
\usage{
csWebDrugInfo( data, output.column, ...)
}
\arguments{

  \item{data}{A Bioconductor data object of a supported class
    (e.g. AffyBatch, GeneFeatureSet, RGList).}

  \item{output.column}{The name of the output annotation column(s) to be
  added to the data object. There is no default value to avoid
  inadvertent overwriting of prior data. }

  \item{...}{Further query arguments are passed to csDrugQuery() via csDrugList().}

}
\details{

  A wrapper function designed to simplify the querying of drug
  information using the csDrugQuery() function.

}
\value{

  The input data object with a new annotation column added, named as
  requested using the output.column argument.

}
\references{ RCurl package, rjson package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csDrugQuery}}
}
\examples{
  \dontrun{
 x <- csWebDrugInfo(eset,
                    output.column='drug_treatment',
                    prior.treatment.type='drug therapy at entry',
                    drug.type='immunosuppression',
                    auth=auth,
                    uri=uri)
  }
}

