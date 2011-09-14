## Copyright 2010 Tim Rayner, University of Cambridge
## 
## This file is part of ClinStudy::Web.
## 
## ClinStudy::Web is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 2 of the License, or
## (at your option) any later version.
## 
## ClinStudy::Web is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
##
## $Id$

csJSONQuery <- function( resultSet, condition=NULL, attributes=NULL, uri, .opts=list(), cred=NULL ) {

    ## Strip the trailing slash; we will be concatenating actions later.
    uri <- sub( '/+$', '', uri )

    ## We use tcltk to generate a nice echo-free password entry field.
    if ( is.null(cred) ) {
        cred <- getCredentials()
        if ( any(is.na(cred)) )
            stop('User cancelled database connection.')
    }

    curl <- .csGetAuthenticatedHandle( uri, cred$username, cred$password, .opts )

    ## Run the query.
    query  <- list(resultSet=resultSet, condition=condition, attributes=attributes)
    query  <- rjson::toJSON(query)
    query  <- RCurl::curlEscape(query)
    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=paste(uri, 'query', sep='/'),
                                 postfields=paste('data', query, sep='='),
                                 .opts=.opts,
                                 curl=curl,
                                 writefunction=status$update)

    ## Check the response for errors.
    status  <- rjson::fromJSON(status$value())
    if ( ! isTRUE(status$success) )
        stop(status$errorMessage)

    ## Log out for the sake of completeness (check for failure and warn).
    .csLogOutAuthenticatedHandle( uri, curl, .opts )

    ## No results returned; rather than passing back a list of length
    ## 0 we just pass back null; it's simpler to detect.
    if ( length(status$data) == 0 )
        return(NULL)

    return( status$data )
}

