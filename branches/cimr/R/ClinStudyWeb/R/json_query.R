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

csJSONQuery <- function( resultSet, condition=NULL, attributes=NULL, ... ) {
    return( .csJSONGeneric(query=list(resultSet=resultSet, condition=condition, attributes=attributes),
                           action='query', ... ) )
}

## auth==list(username, password) or auth==NULL; uri is required in either case.
.csJSONGenericCred <- function( query, action, auth=NULL, .opts=list(), uri, ... ) {

    curl <- getCSWebHandle( uri=uri, auth=auth, .opts=.opts )

    response <- .csJSONGeneric( query, action, auth=curl, .opts=.opts, ... )

    ## Log out for the sake of completeness (check for failure and warn).
    logoutCSWebHandle( curl, .opts )

    return(response)
}

## auth=CURLHandle
.csJSONGenericCurl <- function( query, action, auth, .opts=list(), ... ) {

    # Assumes that all JSON query actions in the web server behave
    # roughly the same; i.e. they consume JSON with a 'data' attribute
    # containing the payload, and return JSON with a 'success' flag
    # attribute, an 'errorMessage' attribute where necessary, and the
    # actual returned data in a 'data' attribute. Returns only the
    # 'data' attribute.

    if ( ! is.list(.opts) )
        stop("Error: .opts must be a list object")

    uri <- .csUriFromCurlHandle(auth)

    require(rjson)

    ## Concatenate the action.
    quri <- paste(uri, action, sep='/')

    ## Run the query.
    query  <- rjson::toJSON(query)
    query  <- RCurl::curlEscape(query)
    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=quri,
                                 postfields=paste('data', query, sep='='),
                                 .opts=.opts,
                                 curl=auth,
                                 writefunction=status$update)
        
    ## Check the response for errors.
    rc <- try(status  <- rjson::fromJSON(status$value()))

    ## A message such as this indicates a possible bug in .csUriFromCurlHandle:
    ##      "Error in rjson::fromJSON(status$value()) : no data to parse"
    if ( inherits(rc, 'try-error') )
        stop(sprintf("Error encountered: %s", rc))

    if ( ! isTRUE(status$success) )
        stop(status$errorMessage)

    ## No results returned; rather than passing back a list of length
    ## 0 we just pass back null; it's simpler to detect.
    if ( length(status$data) == 0 )
        return(NULL)

    return( status$data )
}

.csJSONUriComplaint <- function(query, action, auth, .opts, uri, ...) {
    stop('Error: uri argument is required unless using CURLHandle-based authentication.')
}

setGeneric('.csJSONGeneric', def=function( query, action, auth, .opts=list(), uri, ... )
           standardGeneric('.csJSONGeneric'))

setMethod('.csJSONGeneric', signature(auth='CURLHandle'),            .csJSONGenericCurl)
setMethod('.csJSONGeneric', signature(auth='list', uri='character'),  .csJSONGenericCred)
setMethod('.csJSONGeneric', signature(auth='NULL', uri='character'),  .csJSONGenericCred)
setMethod('.csJSONGeneric', signature(auth='missing', uri='character'),  .csJSONGenericCred)

setMethod('.csJSONGeneric', signature(auth='missing', uri='missing'), .csJSONUriComplaint)
setMethod('.csJSONGeneric', signature(auth='NULL', uri='missing'), .csJSONUriComplaint)
setMethod('.csJSONGeneric', signature(auth='list', uri='missing'), .csJSONUriComplaint)


.csUriFromCurlHandle <- function(curl) {

    ## Assumes that the web server json_login action is in the
    ## expected place. That allows us to forego the requirement to
    ## pass uri around everywhere.
    uri <- RCurl::getCurlInfo(curl)[['effective.url']]
    uri <- sub('/(query|json|static).*$', '', uri)  # Ugly as sin. FIXME!!!
    return(uri)
}
