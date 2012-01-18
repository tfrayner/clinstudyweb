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

csDrugQuery <- function(filename=NULL, identifier=NULL, drug.type=NULL,
                        months.prior=NULL, prior.treatment.type=NULL, ... ) {

    stopifnot( any( ! is.null( c(filename, identifier) ) ) )

    res <- .csJSONGeneric(query=list(filename=filename, identifier=identifier, drug_type=drug.type,
                               months_prior=months.prior, prior_treatment_type=prior.treatment.type),
                          action='query/assay_drugs', ... )

    res <- res$channels
    names(res) <- lapply(res, function(x) { x$label } )
    
    return( res )
}

csDrugList <- function(files, output.column=NULL, ...) {

    if ( is.null(output.column) )
        output.column <- 'drug_treatments'

    ## Reprocess the output from csDrugQuery, which is quite raw, into
    ## a user-friendly data frame. Reduce into a single column if possible.
    dlist <- lapply(files, csDrugQuery, ...)
    dlist <- lapply(dlist, function(dat) {
        f <- lapply(dat, function(ch) {
            paste( ch$drugs, collapse=';' )
        } )
        names(f) <- unlist(lapply(dat, function(ch) {
            paste( output.column, ch$sample, ch$label, sep='.' )
        }))
        return(f)
    } )

    chans <- Reduce(union, lapply(dlist, names))

    res <- matrix(nrow=length(files), ncol=length(chans), NA)
    res <- as.data.frame(res)
    colnames(res) <- chans
    rownames(res) <- files

    for ( n in 1:length(files) ) {
        for ( m in 1:length(chans) ) {
            d <- dlist[[n]][[chans[m]]]
            if ( ! is.null(d) )
                res[n, m] <- d
        }
    }

    ## Collapse into a single column if we can.
    if ( all(apply(res, 1, function(x) { sum(is.na(x)) } ) ) == 1 )
        res <- data.frame(apply(res, 1,
                                function(x) { paste(na.omit(x), collapse='') }))

    if ( ncol(res) == 1 )
        colnames(res) <- output.column

    return(res)
}

.drugInfoEset <- function( data, output.column, ... ) {

    ## ExpressionSet or AffyBatch.
    files <- as.character(sampleNames(data))
    p <- csDrugList(files=files, output.column=output.column, ...)
    stopifnot(all(rownames(p) == files))

    pData(data)[, output.column] <- p

    return(data)
}

.drugInfoMAList <- function( data, output.column, ... ) {

    ## ExpressionSet or AffyBatch.
    files <- as.character(data$targets$FileName)
    p <- csDrugList(files=files, output.column=output.column, ...)
    stopifnot(all(rownames(p) == files))

    data$targets[, output.column] <- p

    return(data)
}

## Define a series of functions for various object signatures.
setGeneric('csWebDrugInfo', def=function(data, output.column, ...)
           standardGeneric('csWebDrugInfo'))

setMethod('csWebDrugInfo', signature(data='ExpressionSet'), .drugInfoEset)
setMethod('csWebDrugInfo', signature(data='AffyBatch'), .drugInfoEset)
setMethod('csWebDrugInfo', signature(data='GeneFeatureSet'), .drugInfoEset)
setMethod('csWebDrugInfo', signature(data='ExonFeatureSet'), .drugInfoEset)
setMethod('csWebDrugInfo', signature(data='MAList'), .drugInfoMAList)
setMethod('csWebDrugInfo', signature(data='RGList'), .drugInfoMAList)

