\name{csJSONQuery}
\alias{csJSONQuery}

\title{ Query the ClinStudyWeb database via its JSON API }
\description{
  Generic database queries using an API based on the perl
  DBIx::Class::ResultSet module.
}
\usage{
csJSONQuery( resultSet, condition=NULL, attributes=NULL,
             ... )
}
\arguments{

  \item{resultSet}{The name of the perl ORM ResultSet class to use as a
    base for queries.}

  \item{condition}{A list of conditions to apply in the constructed SQL
    WHERE clause.}

  \item{attributes}{A list, quite possibly nested, giving database query
    attributes as used by DBIx::Class::ResultSet. This can be used to
    join across tables in the database.}

  \item{...}{Further arguments passed to the JSON query
    function. Examples are "auth" (see \code{getCredentials} and
    \code{getCSWebHandle}) and "uri".}

}
\details{

  This function is intended for advanced users only; it relies on
  knowledge of composing complex SQL::Abstract queries which will not be
  documented here. Please see the perl DBIx::Class::ResultSet
  documentation for how this function may be used.

}
\value{

  A list of lists; each sub-list corresponds to a row in the joined
  resultset giving values for each column.

}
\references{ RCurl package, rjson package }
\author{ Tim F Rayner }
\seealso{
  \code{\link{csFindAssays}}
}
\examples{
  \dontrun{
 x <- csJSONQuery('Assay',
                  condition=list(
                    'cell_type_id.value'='CD19',
                    'platform_id.value'='MEDIANTE'),
                  attributes=list(join=c(
                                    list(channels=list(sample_id='cell_type_id')),
                                    list(assay_batch_id='platform_id'))
                    ),
                  auth=auth,
                  uri=uri)
  }
}

