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

csWebAffyBatch <- function ( files, uri, .opts=list(), cred=NULL, ... ) {

    stopifnot( ! missing(files) )
    stopifnot( ! missing(uri) )

    p <- .filenamesToPData( files, uri, .opts, cred )

    ## Merge the lists into a data frame, and create the phenoData object.
    message("Reading CEL files...")
    ph   <- new('AnnotatedDataFrame', data=p)
    cels <- affy::ReadAffy(filenames=as.character(p$filename), phenoData=ph, ...)

    return(cels)
}

csWebRGList <- function ( files, uri, .opts=list(), cred=NULL, ... ) {

    stopifnot( ! missing(files) )
    stopifnot( ! missing(uri) )

    targets <- .filenamesToTargets( files, uri, .opts, cred )
    message("Reading data files...")

    RG <- read.maimages(targets, ...)

    return(RG)
}

.filenamesToPData <- function( files, ... ) {

    p <- .batchDBQuery( files=files, samples=NULL, ... )
    p <- .conformLists(p)
    p <- lapply(p, unlist)
    p <- data.frame(do.call('rbind', p))

    # Quick sanity check
    stopifnot( all( as.character(p$filename) == files ) )
    
    rownames(p) <- files

    return(p)
}

.samplesToPData <- function( samples, ... ) {

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

    p <- .batchDBQuery( files=files, samples=NULL, ... )

    p <- lapply(p, .annotateTargetLabels)
    p <- .conformLists(p)

    labels <- Reduce(union, lapply(p, function(x) { x$label } ) )
    for ( l in labels )
        p <- lapply(p, .addRefLabels, l)

    p <- lapply(p, unlist)
    p <- data.frame(do.call('rbind', p))

    # Quick sanity check.
    stopifnot( all(as.character(p$filename) == files) )

    colnames(p)[colnames(p) == 'filename'  ] <- 'FileName'
    colnames(p)[colnames(p) == 'identifier'] <- 'SlideNumber'
    colnames(p)[colnames(p) == 'batch_date'] <- 'Date'

    return(p)
}

.samplesToTargets <- function( samples, ... ) {

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

.batchDBQuery <- function( files, samples=NULL, uri, .opts=list(), cred, curl=NULL ) {

    ## We use tcltk to generate a nice echo-free password entry field.
    if ( is.null(cred) ) {
        cred <- getCredentials()
        if ( any(is.na(cred)) )
            stop('User cancelled database connection.')
    }

    needs.logout <- 0
    if ( is.null(curl) ) {
        curl <- .csGetAuthenticatedHandle( uri, cred$username, cred$password, .opts )
        needs.logout <- 1
    }

    ## Quick check to ensure our credentials look okay.
    stopifnot( is.list(cred) )
    stopifnot( all( c('username', 'password') %in% names(cred) ) )
    stopifnot( ! any(is.na(cred)) )

    ## This call relies on assay.file being the first argument to
    ## csWebQuery
    message("Querying the database for annotation...")
    if ( is.null(samples) )
        p <- lapply(as.list(files), csWebQuery, assay.barcode=NULL, sample.name=NULL,
                    uri=uri, username=cred$username, password=cred$password,
                    .opts=.opts, curl=curl)
    else
        p <- lapply(as.list(samples), csWebQuery, assay.file=NULL, assay.barcode=NULL,
                    uri=uri, username=cred$username, password=cred$password,
                    .opts=.opts, curl=curl)

    if ( needs.logout == 1 ) {
        ## Log out for the sake of completeness (check for failure and warn).
        res <- RCurl::postForm(uri=paste(uri, 'logout', sep='/'), logout='1')

        ## FIXME at present this relies on the web server behaviour, which might change.
        if ( nchar(res) > 0 )
            warning("Unable to log out.")
    }

    return(p)
}

.reannotateEset <- function( data, sample.column=NULL, uri, .opts=list(), cred=NULL ) {

    ## ExpressionSet or AffyBatch.
    if ( is.null(sample.column) ) {
        files <- as.character(sampleNames(data))
        p <- .filenamesToPData(files, uri, .opts, cred)
        stopifnot(all(as.character(p$filename) == as.character(files)))
    } else {
        stopifnot( sample.column %in% varLabels(data) )
        samples <- as.character(pData(data)[ , sample.column ])
        stopifnot( all( ! is.na(samples) ) )
        p <- .samplesToPData(samples, uri, .opts, cred)
        stopifnot(all(as.character(p$sample_name) == as.character(samples)))
        rownames(p) <- sampleNames(data)
    }
    
    pData(data) <- p

    return(data)
}

.reannotateMAList <- function( data, sample.column=NULL, uri, .opts=list(), cred=NULL ) {

    ## MAList or RGList, both have similar targets structure.
    if ( is.null(sample.column) ) {
        files <- as.character(data$targets$FileName)
        stopifnot( all( ! is.na(files) ) )
        p <- .filenamesToTargets(files, uri, .opts, cred)
        stopifnot(all(as.character(p$FileName) == files))
    } else {
        stopifnot( sample.column %in% colnames(data$targets) )
        samples <- as.character(data$targets[, sample.column ])
        stopifnot( all( ! is.na(samples) ) )
        p <- .samplesToTargets(samples, uri, .opts, cred)
        stopifnot(all(as.character(p$sample_name) == samples))
        rownames(p) <- rownames(data$targets)
    }
        
    data$targets <- p

    return(data)
}

## Define a series of functions for various object signatures.
setGeneric('csWebReannotate', def=function(data, sample.column=NULL, uri, .opts=list(), cred=NULL)
           standardGeneric('csWebReannotate'))

setMethod('csWebReannotate', signature(data='ExpressionSet'), .reannotateEset)
setMethod('csWebReannotate', signature(data='AffyBatch'), .reannotateEset)
setMethod('csWebReannotate', signature(data='MAList'), .reannotateMAList)
setMethod('csWebReannotate', signature(data='RGList'), .reannotateMAList)

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
    query  <- list(filename=assay.file, identifier=assay.barcode, name=sample.name)
    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=quri,
                                 postfields=paste('data', rjson::toJSON(query), sep='='),
                                 .opts=.opts,
                                 curl=curl,
                                 writefunction=status$update)

    status  <- rjson::fromJSON(status$value())
    if ( ! isTRUE(status$success) )
        stop(status$errorMessage)

    if ( needs.logout == 1 ) {
        ## Log out for the sake of completeness (check for failure and warn).
        res <- RCurl::postForm(uri=paste(uri, 'logout', sep='/'), logout='1')

        ## FIXME at present this relies on the web server behaviour, which might change.
        if ( nchar(res) > 0 )
            warning("Unable to log out.")
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
    if ( !is.null(eg) ) {
        for ( n in 1:length(eg) ) {
            attrname <- paste('emergent_group', names(eg)[n], sep='.')
            attrs[[attrname]]<-as.character(eg[n])
        }
    }
    pg <- sample$prior_group
    if ( !is.null(pg) ) {
        for ( n in 1:length(pg) ) {
            attrname <- paste('prior_group', names(pg)[n], sep='.')
            attrs[[attrname]]<-as.character(pg[n])
        }
    }
    pt <- sample$prior_treatment
    if ( !is.null(pt) ) {
        for ( n in 1:length(pt) ) {
            attrname <- paste('prior_treatment', names(pt)[n], sep='.')
            attrs[[attrname]]<-as.character(pt[n])
        }
    }

    ## We handle TestResults in much the same way.
    tr <- sample$test_result
    if ( !is.null(tr) ) {
        for ( n in 1:length(tr) ) {
            attrname <- paste('test', names(tr)[n], sep='.')
            attrs[[attrname]]<-as.character(tr[n])
        }
    }

    return(attrs)
}

## Code copied from
## http://bioinf.wehi.edu.au/~wettenhall/RTclTkExamples/modalDialog.html
## and modified.
getCredentials <- function(title='Database Authentication', entryWidth=30, returnValOnCancel=NA) {

    dlg <- tktoplevel()
    tkwm.deiconify(dlg)
    tkgrab.set(dlg)
    tkfocus(dlg)
    tkwm.title(dlg,title)
    userEntryVarTcl <- tclVar('')
    userEntryWidget <- tkentry(dlg, width=paste(entryWidth), textvariable=userEntryVarTcl)
    passEntryVarTcl <- tclVar('')
    passEntryWidget <- tkentry(dlg, width=paste(entryWidth), textvariable=passEntryVarTcl, show='*')
    tkgrid(tklabel(dlg, text="       "))
    tkgrid(tklabel(dlg, text='Username: '), userEntryWidget)
    tkgrid(tklabel(dlg, text='Password: '), passEntryWidget)
    tkgrid(tklabel(dlg, text="       "))
    userReturnVal <- returnValOnCancel
    passReturnVal <- returnValOnCancel
    onOK <- function() {
        userReturnVal <<- tclvalue(userEntryVarTcl)
        passReturnVal <<- tclvalue(passEntryVarTcl)
        tkgrab.release(dlg)
        tkdestroy(dlg)
    }
    onCancel <- function() {
        userReturnVal <<- returnValOnCancel
        passReturnVal <<- returnValOnCancel
        tkgrab.release(dlg)
        tkdestroy(dlg)
    }
    ## FIXME the layout needs a tweak here.
    OK.but     <- tkbutton(dlg, text="   OK   ", command=onOK)
    Cancel.but <- tkbutton(dlg, text=" Cancel ", command=onCancel)
    tkgrid(OK.but, Cancel.but)
    tkgrid(tklabel(dlg, text="    "))

    tkfocus(dlg)
    tkbind(dlg, "<Destroy>", function() {tkgrab.release(dlg)})
    tkbind(userEntryWidget, "<Return>", onOK)
    tkbind(passEntryWidget, "<Return>", onOK)
    tkwait.window(dlg)

    return(list(username=userReturnVal, password=passReturnVal))
}

.csGetAuthenticatedHandle <- function( uri, username, password, .opts=list() ) {

    ## Set up our session and authenticate.
    curl    <- RCurl::getCurlHandle()
    cookies <- file.path(Sys.getenv('HOME'), '.cookies.txt')
    RCurl::curlSetOpt(cookiefile=cookies, curl=curl)

    ## We need to detect login failures here.
    res <- RCurl::postForm(uri=paste(uri, 'login', sep='/'),
                           username=username,
                           password=password,
                           login='1',
                           .opts=.opts,
                           curl=curl)

    ## FIXME at present this relies on the web server behaviour, which might change.
    if ( nchar(res) > 0 )
        stop("Unable to log in.")    

    return(curl)
}

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
    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=paste(uri, 'query', sep='/'),
                                 postfields=paste('data', rjson::toJSON(query), sep='='),
                                 .opts=.opts,
                                 curl=curl,
                                 writefunction=status$update)

    ## Check the response for errors.
    status  <- rjson::fromJSON(status$value())
    if ( ! isTRUE(status$success) )
        stop(status$errorMessage)

    ## Log out for the sake of completeness (check for failure and warn).
    res <- RCurl::postForm(uri=paste(uri, 'logout', sep='/'), logout='1')

    ## FIXME at present this relies on the web server behaviour, which might change.
    if ( nchar(res) > 0 )
        warning("Unable to log out.")

    ## No results returned; rather than passing back a list of length 1
    ## with a single null entry we just pass back null; it's simpler
    ## to detect.
    if ( length(status$data) == 1 & is.null(status$data[[1]]) )
        return(NULL)

    return( status$data )
}

csFindAssays <- function(cell.type, platform, batch.name, study,
                         diagnosis, timepoint, trial.id, uri, .opts=list(), cred=NULL ) {

    stopifnot( ! missing(uri) )

    cond  <- list()
    attrs <- list(join=c())

    if ( ! missing(cell.type) ) {
        cond       <- append(cond, list('cell_type_id.value'=cell.type))
        attrs$join <- append(attrs$join, list(list(channels=list(sample_id='cell_type_id'))))
    }

    if ( ! missing(diagnosis) ) {   # FIXME this needs to use only the latest diagnosis.
        cond       <- append(cond, list('condition_name_id.value'=diagnosis))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=c(list(
                                                       visit_id=list(
                                                         patient_id=list(
                                                           diagnoses='condition_name_id'))))))))
    }

    if ( ! missing(study) ) {
        cond       <- append(cond, list('type_id.value'=study))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=list(
                                                       visit_id=list(
                                                         patient_id=list(
                                                           studies='type_id')))))))
    }

    if ( ! missing(timepoint) ) {
        cond       <- append(cond, list('nominal_timepoint_id.value'=timepoint))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=list(
                                                       visit_id='nominal_timepoint_id')))))
    }

    if ( ! missing(trial.id) ) {
        cond       <- append(cond, list('patient_id.trial_id'=trial.id))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=list(
                                                       visit_id='patient_id')))))
    }    

    if ( ! missing(platform) ) {
        cond       <- append(cond, list('platform_id.value'=platform))
        attrs$join <- append(attrs$join, list(list(assay_batch_id='platform_id')))
    }

    if ( ! missing(batch.name) ) {
        cond       <- append(cond, list('assay_batch_id.name'=batch.name))
        attrs$join <- append(attrs$join, 'assay_batch_id')
    }

    assays <- csJSONQuery(resultSet='Assay',
                          condition=cond,
                          attributes=attrs,
                          uri=uri,
                          .opts=.opts,
                          cred=cred)

    return(assays)
}
