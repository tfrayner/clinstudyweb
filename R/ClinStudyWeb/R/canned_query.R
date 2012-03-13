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

csPatients <- function( trial_id=NULL, id=NULL, study=NULL, diagnosis=NULL, extended=FALSE, ... ) {

    query <- list(trial_id=trial_id,
                  id=id,
                  study=study,
                  diagnosis=diagnosis)

    if ( extended )
        query$include_relationships <- 1

    res <- .csJSONGeneric( query=query, action='query/patients', ... )

    ## Reorganise the results into data frames.
    dat <- .csCannedJSONToDFs(res, 'patients', 'trial_id')

    return(dat)
}

.csCannedJSONToDFs <- function( res, coreAttr, recordIdAttr ) {

    if ( length(res) == 0 )
        return(NULL)

    w <- sapply(res[[1]], is.list)

    ## Core data
    dat <- list()
    dat[[coreAttr]] <- as.data.frame(do.call('rbind', lapply(res, function(x) {x[!w]})))

    ## For extended data, we include the trial_id as a column.
    res <- lapply(res, function(r) {
        lapply(r, function(x) {
            if ( ! is.list(x) || length(x) == 0 )
                return(x)
            return(lapply(x, function(y) { y[[recordIdAttr]] <- r[[recordIdAttr]]; y }))
        } )
    } )

    ## Assumes that extended annotation only goes one level deep.
    for ( n in names(res[[1]])[w] ) {
        dat[[n]] <- as.data.frame(do.call('rbind',
                                          lapply(res,
                                                 function(r) { do.call('rbind', r[[n]]) } )))
    }

    return(dat)
}
