\name{csDrugList}
\alias{csDrugList}

\title{ Retrieve drug information from the ClinStudyWeb database }
\description{
  Query the database with a list of Assay filenames to retrieve the
  requested drug information for each Assay.
}
\usage{
csDrugList( files, output.column=NULL, ... )
}
\arguments{

  \item{files}{A list of Assay filenames. All the filenames must be
    represented in the database.}

  \item{output.column}{Optional name of the output data frame
  column(s). Defaults to 'drug_treatments'. Multi-channel
  assays will generate multi-column data frames in which the sample and
  label names are included in the column names. }

  \item{...}{Further query arguments are passed to csDrugQuery().}

}
\details{

  A wrapper function designed to simplify the querying of drug
  information using the csDrugQuery() function.

}
\value{

  A data frame with the same number of columns as the maximum number of
  channels in the input Assay list. Each row contains the retrieved drug
  names concatenated by semicolons.

}
\references{ RCurl package, rjson package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csDrugQuery}}
}
\examples{
  \dontrun{
 x <- csDrugList(c('some_filename.CEL', 'some_other_filename.CEL'),
                  prior.treatment.type='drug therapy at entry',
                  drug.type='immunosuppression',
                  cred=cred,
                  uri=uri)
  }
}

