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

## Classic AffyBatch-based workflow.
csWebAffyBatch <- function (files, pattern=NULL, categories=NULL, ... ) {
    .csWebEset(affy::ReadAffy, files=files, pattern=pattern, categories=categories, ... )
}

## Newer, recommended Oligo-based workflow.
csWebGeneFeatureSet <- function(files, pattern=NULL, categories=NULL, ... ) {
    .csWebEset(oligo::read.celfiles, files=files, pattern=pattern, categories=categories, ... )
}

.csWebEset <- function (read.fun, files, uri=NULL, .opts=list(), auth=NULL,
                        pattern=NULL, categories=NULL, ... ) {

    stopifnot( ! missing(files) )
    stopifnot( ! missing(uri) )

    files <- as.character(files)

    p <- .filenamesToPData(files=files, pattern=pattern, categories=categories,
                           uri=uri, .opts=.opts, auth=auth)

    ## Merge the lists into a data frame, and create the phenoData object.
    message("Reading CEL files...")
    ph   <- new('AnnotatedDataFrame', data=p)
    varMetadata(ph)$channel <- factor('_ALL_')  # Fixes some dubious NChannelSet validity requirement.
    cels <- read.fun(filenames=files, phenoData=ph, ...)

    return(cels)
}

csWebRGList <- function (files, uri, .opts=list(), auth=NULL,
                         pattern=NULL, categories=NULL, ... ) {

    stopifnot( ! missing(files) )
    stopifnot( ! missing(uri) )

    files <- as.character(files)

    targets <- .filenamesToTargets(files=files, pattern=pattern, categories=categories,
                                   uri=uri, .opts=.opts, auth=auth )
    message("Reading data files...")

    RG <- read.maimages(targets, ...)

    return(RG)
}

.filenamesToPData <- function( files, ... ) {

    if ( ! length(files) > 1 )
        stop("No filenames provided to function.")
    
    p <- .batchDBQuery( files=files, samples=NULL, ... )
    p <- .conformLists(p)
    p <- lapply(p, unlist)

    ## This is perhaps more complicated than it needs to be because a
    ## large do.call('rbind',...) fails with deep recursion.
    stopifnot( length(p) > 1 )
    p2 <- do.call('rbind', p[1:2])
    if ( length(p) > 2 )
        for ( n in 3:length(p) )
            p2 <- rbind(p2, p[[n]])
    p <- as.data.frame(p2)

    ## Quick sanity check
    ## Strip out file paths which won't have been stored in the database.
    files <- gsub( paste('.*', .Platform$file.sep, sep=''), '', files )
    stopifnot( all( as.character(p$filename) == files ) )
    
    rownames(p) <- as.character(p$filename)

    return(p)
}

.samplesToPData <- function( samples, ... ) {

    if ( ! length(samples) > 1 )
        stop("No sample names provided to function.")

    p <- .batchDBQuery( samples=samples, files=NULL, ... )
    p <- .conformLists(p)
    p <- lapply(p, unlist)
    p <- data.frame(do.call('rbind', p))

    # Quick sanity check
    stopifnot( all( as.character(p$sample_name) == samples ) )
    
    return(p)
}

.annotateTargetLabels <- function( x ) {

    label <- x$label

    stopifnot( ! is.na(label) )

    x[[label]] <- x$sample_name

    return(x)
}

.addRefLabels <- function( x, l ) {

    if ( is.na(x[[l]]) )
        x[[l]] <- 'Ref'

    x <- x[ names(x) != 'label' ]

    return(x)
}

.filenamesToTargets <- function( files, ... ) {

    if ( ! length(files) > 1 )
        stop("No filenames provided to function.")
    
    p <- .batchDBQuery( files=files, samples=NULL, ... )

    p <- lapply(p, .annotateTargetLabels)
    p <- .conformLists(p)

    labels <- Reduce(union, lapply(p, function(x) { x$label } ) )
    for ( l in labels )
        p <- lapply(p, .addRefLabels, l)

    p <- lapply(p, unlist)
    p <- data.frame(do.call('rbind', p))

    ## Support for full-path file names. Unsure if read.maimages will
    ## honour this though FIXME.
    rownames(p) <- p$filename
    p$filename  <- files

    ## Quick sanity check.
    ## Strip out file paths which won't have been stored in the database.
    files <- gsub( paste('.*', .Platform$file.sep, sep=''), '', files )
    stopifnot( all(as.character(p$filename) == files) )

    colnames(p)[colnames(p) == 'filename'  ] <- 'FileName'
    colnames(p)[colnames(p) == 'identifier'] <- 'SlideNumber'
    colnames(p)[colnames(p) == 'batch_date'] <- 'Date'

    return(p)
}

.samplesToTargets <- function( samples, ... ) {

    if ( ! length(samples) > 1 )
        stop("No sample names provided to function.")

    warning("Reannotation of MAList objects at the sample level does not preserve channel information.")

    p <- .batchDBQuery( samples=samples, files=NULL, ... )

    p <- .conformLists(p)

    p <- lapply(p, unlist)
    p <- data.frame(do.call('rbind', p))

    # Quick sanity check.
    stopifnot( all(as.character(p$sample_name) == samples) )

    return(p)
}

.fillList <- function(x, vars) {

    y <- x[vars]
    names(y) <- vars

    n <- unlist(lapply(y, is.null))
    y[n] <- NA

    return(y)
}

.conformLists <- function(p) {

    ## A list of all the variable names.
    vars <- Reduce(union, lapply(p, names))

    ## Make sure all the variables are represented in each list. This
    ## is a bit kludgey, but it does work.
    p <- lapply(p, .fillList, vars)

    return(p)
}

.collateAnnotationRequest <- function( pattern, categories, ... ) {

    ## We're pretty much assuming that the curl object exists and is
    ## authenticated by this point; hence we're not bothering with username and password.
    
    if ( ! ( missing(pattern) | is.null(pattern) ) ) { ## FIXME consider passing the pattern directly to the assay_dump query URL.
        qry <- list()
        qry$test_ids      <- csWebTestNames(pattern=pattern, ...)
        qry$phenotype_ids <- csWebPhenotypes(pattern=pattern, ...)
        qry <- lapply(qry, unlist)
    }
    else {
        db.tests <- csWebTestNames(...)
        db.pheno <- csWebPhenotypes(...)

        if ( missing(categories) | is.null(categories) ) {
            qry <- lapply(lapply(csAnnoPicker(db.tests, db.pheno), unlist), as.integer)
            names(qry) <- sub('s$', '_ids', names(qry))
        }
        else {
            avail <- c( names(db.tests), names(db.pheno) )
            w <- ! categories %in% avail
            if ( any( w ) ) {
                message(sprintf("Requested annotation not found in database:\n\n %s\n\nPlease select from this list:\n\n %s\n", paste(sort(categories[w]), collapse="\n "), paste(sort(avail), collapse="\n ")))
                stop("Error retrieving requested annotation; please see error message above.")
            }

            qry <- list()
            qry$test_ids <- unlist(db.tests)[ names(db.tests) %in% categories]
            qry$phenotype_ids <- unlist(db.pheno)[ names(db.pheno) %in% categories]
        }
    }

    ## Make sure we only have the IDs here; rjson::toJSON does funny things with named vectors.
    qry <- lapply(qry, as.integer)

    return(qry)
}        

.batchDBQuery <- function(files, samples=NULL,
                          categories=NULL, pattern=NULL, ... ) {

    ## Unless specified otherwise, retrieve the desired annotation terms.
    anno.qry <- .collateAnnotationRequest(pattern=pattern, categories=categories, ...)

    ## Strip out file paths which won't have been stored in the database.
    files <- gsub( paste('.*', .Platform$file.sep, sep=''), '', files )

    ## This call relies on assay.file being the first argument to
    ## csWebQuery
    message("Querying the database for annotation...")
    if ( is.null(samples) )
        p <- lapply(as.list(files), csWebQuery, assay.barcode=NULL,
                    sample.name=NULL, query=anno.qry, ...)
    else
        p <- lapply(as.list(samples), csWebQuery, assay.file=NULL,
                    assay.barcode=NULL, query=anno.qry, ...)

    return(p)
}

.reannotateEset <- function( data, sample.column=NULL, ... ) {

    ## ExpressionSet or AffyBatch.
    if ( is.null(sample.column) ) {
        files <- as.character(sampleNames(data))
        p <- .filenamesToPData(files, ...)
        stopifnot(all(as.character(p$filename) == as.character(files)))
    } else {
        stopifnot( sample.column %in% varLabels(data) )
        samples <- as.character(pData(data)[ , sample.column ])
        stopifnot( all( ! is.na(samples) ) )
        p <- .samplesToPData(samples, ...)
        stopifnot(all(as.character(p$sample_name) == as.character(samples)))
        rownames(p) <- sampleNames(data)
    }
    
    pData(data) <- p

    return(data)
}

.reannotateMAList <- function( data, sample.column=NULL, ... ) {

    ## MAList or RGList, both have similar targets structure.
    if ( is.null(sample.column) ) {
        files <- as.character(data$targets$FileName)
        stopifnot( all( ! is.na(files) ) )
        p <- .filenamesToTargets(files, ...)
        stopifnot(all(as.character(p$FileName) == files))
    } else {
        stopifnot( sample.column %in% colnames(data$targets) )
        samples <- as.character(data$targets[, sample.column ])
        stopifnot( all( ! is.na(samples) ) )
        p <- .samplesToTargets(samples, ...)
        stopifnot(all(as.character(p$sample_name) == samples))
        rownames(p) <- rownames(data$targets)
    }
        
    data$targets <- p

    return(data)
}

## Define a series of functions for various object signatures.
setGeneric('csWebReannotate', def=function(data, sample.column=NULL, ...)
           standardGeneric('csWebReannotate'))

setMethod('csWebReannotate', signature(data='ExpressionSet'), .reannotateEset)
setMethod('csWebReannotate', signature(data='AffyBatch'), .reannotateEset)
setMethod('csWebReannotate', signature(data='GeneFeatureSet'), .reannotateEset)
setMethod('csWebReannotate', signature(data='ExonFeatureSet'), .reannotateEset)
setMethod('csWebReannotate', signature(data='MAList'), .reannotateMAList)
setMethod('csWebReannotate', signature(data='RGList'), .reannotateMAList)

