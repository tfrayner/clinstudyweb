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
## annotation for a given file or barcode. The query argument is used
## to pass through upstream query constraints (e.g. test_ids, phenotype_ids).
csWebQuery <- function (assay.file=NULL, assay.barcode=NULL, sample.name=NULL, query=list(), ... ) {

    if ( is.null(assay.file) && is.null(assay.barcode) && is.null(sample.name) )
        stop("Error: Either assay.file, assay.barcode or sample.name must be specified")

    if ( ! is.null(sample.name) )
        action <- 'query/sample_dump'
    else
        action <- 'query/assay_dump'

    ## Undef (NULL) in queries is acceptable.
    query$filename=assay.file
    query$identifier=assay.barcode
    query$name=sample.name

    response <- .csJSONGeneric( query, action, ... )

    .extractAttrs <- function(x) { class(x)!='list' }

    if ( ! is.null(sample.name) ) {
        attrs  <- Filter( .extractAttrs, response )
        sample <- response
    } else {

        ## N.B. this all assumes a single channel only (FIXME)
        attrs <- as.list(c(Filter( .extractAttrs, response),
                           lapply(response$channels,
                                  function(x) { Filter(.extractAttrs, x) } )[[1]],
                           lapply(response$channels,
                                  function(x) { Filter(.extractAttrs, x$sample) } )[[1]],
                           Filter( .extractAttrs, response$qc)))
        sample <- response$channels[[1]]$sample
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

    ## We handle TestResults and PhenotypeQuantities in much the same way.
    tr <- sample$test_result
    if ( !is.null(tr) & length(tr) ) {
        for ( n in 1:length(tr) ) {
            attrname <- paste('test', names(tr)[n], sep='.')
            attrs[[attrname]]<-as.character(tr[n])
        }
    }

    ph <- sample$phenotype
    if ( !is.null(ph) & length(ph) ) {
        for ( n in 1:length(ph) ) {
            attrname <- paste('pheno', names(ph)[n], sep='.')
            attrs[[attrname]]<-as.numeric(ph[n]) # All phenotypes are currently numeric.
        }
    }

    ## Also transplant data.
    tx <- sample$transplant
    if ( !is.null(tx) & length(tx) ) {
        for ( n in 1:length(tx) ) {
            attrname <- paste('tx', names(tx)[n], sep='.')
            attrs[[attrname]]<-as.character(tx[n])
        }
    }

    return(attrs)
}

