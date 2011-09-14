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

## Also public, this method is non-interactive and just returns the
## annotation for a given file or barcode.
csWebQuery <- function (assay.file=NULL, assay.barcode=NULL, sample.name=NULL,
                        uri, username, password, .opts=list(), curl=NULL ) {

    require(rjson)

    if ( is.null(assay.file) && is.null(assay.barcode) && is.null(sample.name) )
        stop("Error: Either assay.file, assay.barcode or sample.name must be specified")

    if ( missing(uri) || missing(username) || missing(password) )
        stop("Error: uri, username and password are required")

    if ( ! is.list(.opts) )
        stop("Error: .opts must be a list object")

    needs.logout <- 0
    if ( is.null(curl) ) {
        curl <- .csGetAuthenticatedHandle( uri, username, password, .opts )
        needs.logout <- 1
    }

    ## Strip off trailing /
    uri <- gsub( '/+$', '', uri )
    if ( ! is.null(sample.name) )
        quri <- paste(uri, '/query/sample_dump', sep='')            
    else
        quri <- paste(uri, '/query/assay_dump', sep='')

    ## Undef (NULL) in queries is acceptable.
    query  <- list(filename=assay.file,
                   identifier=assay.barcode,
                   name=sample.name)
    query  <- rjson::toJSON(query)
    query  <- RCurl::curlEscape(query)
    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=quri,
                                 postfields=paste('data', query, sep='='),
                                 .opts=.opts,
                                 curl=curl,
                                 writefunction=status$update)

    status  <- rjson::fromJSON(status$value())
    if ( ! isTRUE(status$success) )
        stop(status$errorMessage)

    if ( needs.logout == 1 ) {
        .csLogOutAuthenticatedHandle( uri, curl, .opts )
    }

    .extractAttrs <- function(x) { class(x)!='list' }

    if ( ! is.null(sample.name) ) {
        attrs  <- Filter( .extractAttrs, status$data )
        sample <- status$data
    } else {

        ## N.B. this all assumes a single channel only (FIXME)
        attrs <- as.list(c(Filter( .extractAttrs, status$data),
                           lapply(status$data$channels,
                                  function(x) { Filter(.extractAttrs, x) } )[[1]],
                           lapply(status$data$channels,
                                  function(x) { Filter(.extractAttrs, x$sample) } )[[1]],
                           Filter( .extractAttrs, status$data$qc)))
        sample <- status$data$channels[[1]]$sample
    }

    ## EmergentGroups and PriorGroups are a bit trickier, since they're 0..n

    eg <- sample$emergent_group
    if ( !is.null(eg) & length(eg) ) {
        for ( n in 1:length(eg) ) {
            attrname <- paste('emergent_group', names(eg)[n], sep='.')
            attrs[[attrname]]<-as.character(eg[n])
        }
    }
    pg <- sample$prior_group
    if ( !is.null(pg) & length(pg) ) {
        for ( n in 1:length(pg) ) {
            attrname <- paste('prior_group', names(pg)[n], sep='.')
            attrs[[attrname]]<-as.character(pg[n])
        }
    }
    pt <- sample$prior_treatment
    if ( !is.null(pt) & length(pt) ) {
        for ( n in 1:length(pt) ) {
            attrname <- paste('prior_treatment', names(pt)[n], sep='.')
            attrs[[attrname]]<-as.character(pt[n])
        }
    }

    ## We handle TestResults in much the same way.
    tr <- sample$test_result
    if ( !is.null(tr) & length(tr) ) {
        for ( n in 1:length(tr) ) {
            attrname <- paste('test', names(tr)[n], sep='.')
            attrs[[attrname]]<-as.character(tr[n])
        }
    }

    return(attrs)
}

