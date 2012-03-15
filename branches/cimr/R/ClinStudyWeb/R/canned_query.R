## Copyright 2012 Tim Rayner, University of Cambridge
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

csPatients <- function(trial_id=NULL, id=NULL, study=NULL, diagnosis=NULL,
                       extended=FALSE, ... ) {

    ## Generate a query list from our arguments.
    query <- .csQueryList(c('extended', '...'))

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/patients', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'patients', list(trial_id='trial_id'))

    return(dat)
}

csVisits <- function(trial_id=NULL, id=NULL, date=NULL, nominal_timepoint=NULL,
                     extended=FALSE, ... ) {

    ## Generate a query list from our arguments.
    query <- .csQueryList(c('extended', '...'))

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/visits', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'visits', list(trial_id='trial_id', date='visit_date') )

    return(dat)
}

csSamples <- function(trial_id=NULL, id=NULL, name=NULL, date=NULL,
                      cell_type=NULL, material_type=NULL,
                      extended=FALSE, ... ) {

    ## Generate a query list from our arguments.
    query <- .csQueryList(c('extended', '...'))

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/samples', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'samples', list(name='sample_name') )

    return(dat)
}

csAssays <- function(id=NULL, sample_id=NULL, filename=NULL, identifier=NULL,
                     date=NULL, batch=NULL,
                     extended=FALSE, ... ) {

    ## Generate a query list from our arguments.
    query <- .csQueryList(c('extended', '...'))

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/assays', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'assays', list(identifier='assay_identifier') )

    return(dat)
}

csTransplants <- function(trial_id=NULL, id=NULL, date=NULL, organ_type=NULL,
                              extended=FALSE, ... ) {

    ## Generate a query list from our arguments.
    query <- .csQueryList(c('extended', '...'))

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/transplants', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'transplants', list(trial_id='trial_id', date='transplant_date') )

    return(dat)
}

csPriorTreatments <- function(trial_id=NULL, id=NULL, type=NULL,
                              extended=FALSE, ... ) {

    ## Generate a query list from our arguments.
    query <- .csQueryList(c('extended', '...'))

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/prior_treatments', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'prior_treatments', list(trial_id='trial_id') )

    return(dat)
}

.csQueryList <- function(badargs) {

    ## Returns a list composed of the caller's arguments and values,
    ## with badargs removed.
    fn <- sys.function(sys.parent())
    n  <- names(formals(fn))
    if ( ! missing(badargs) )
        n  <- n[! n %in% badargs]

    query <- lapply(n, get, envir=parent.frame(n=1))
    names(query) <- n

    ## Throw an error here if there are no query terms at all.
    if ( length(unlist(query)) == 0 )
        stop("Must provide some query parameters.")

    return(query)
}

.csCannedJSONToDFs <- function( res, coreAttr, recordIdAttr ) {

    ## Somewhat overcomplicated function which processes the results
    ## from the JSON query into a series of data frames more easily
    ## handled in R.

    if ( length(res) == 0 )
        return(NULL)

    w <- sapply(res[[1]], is.list)

    ## Core data
    dat <- list()
    dat[[coreAttr]] <- as.data.frame(do.call('rbind', lapply(res, function(x) {
      sapply(x[!w], function(y) ifelse(is.null(y), NA, y))
    })))

    ## For extended data, we include a record id columns. recordIdAttr
    ## is a list of source=target column names.
    if ( ! missing(recordIdAttr) ) {
        res <- lapply(res, function(r) {
            lapply(r, function(x) {
                if ( ! is.list(x) || length(x) == 0 )
                    return(x)
                return(lapply(x, function(y) {
                    for ( attr in names(recordIdAttr) ) {
                        n <- recordIdAttr[[attr]]
                        y[[n]] <- r[[attr]]
                    }
                    return(y) }))
            } )
        } )
    }

    ## Assumes that extended annotation only goes one level deep.
    for ( n in names(res[[1]])[w] ) {
        dat[[n]] <- as.data.frame(do.call('rbind',
                                          lapply(res,
                                                 function(r) {
            do.call('rbind', lapply(r[[n]],
                                    function(x) {
                                      sapply(x, function(y) ifelse(is.null(y), NA, y))
                                    } ))
          } )))
    }

    ## Rename common columns to more distinctive values
    for ( n in names(dat) ) {
        nn <- .csDepluralise(n)
        cn <- colnames(dat[[n]])
        cn <- sub( '^(date|type|id|value|name|notes)$', paste(nn, '\\1', sep='_'), cn)
        colnames(dat[[n]]) <- cn
    }

    return(dat)
}

.csDepluralise <- function(x) {

    irreg <- list(diagnoses='diagnosis',
                  studies='study',
                  assay_batches='assay_batch',
                  phenotype_quantities='phenotype_quantity',
                  comorbidities='comorbidity')

    .deplural <- function(x) {
        if ( x %in% names(irreg) )
            return(irreg[[x]])
        else
            x <- sub('s$', '', x)
        return(x)
    }

    return(sapply(x, .deplural))
} 
