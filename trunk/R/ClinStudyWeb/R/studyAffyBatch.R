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

## This is the main public method.
studyAffyBatch <- function ( files, uri, .opts=list(), cred=NULL, ... ) {

    stopifnot( ! missing(files) )
    stopifnot( ! missing(uri) )

    p <- .filenamesToPData( files, uri, .opts, cred )

    ## Merge the lists into a data frame, and create the phenoData object.
    message("Reading CEL files...")
    ph   <- new('AnnotatedDataFrame', data=p)
    cels <- affy::ReadAffy(filenames=as.character(p$filename), phenoData=ph, ...)

    return(cels)
}

.filenamesToPData <- function( files, uri, .opts=list(), cred ) {

    ## We use tcltk to generate a nice echo-free password entry field.
    if ( is.null(cred) ) {
        cred <- getCredentials()
        if ( any(is.na(cred)) )
            stop('User cancelled database connection.')
    }

    ## Quick check to ensure our credentials look okay.
    stopifnot( is.list(cred) )
    stopifnot( all( c('username', 'password') %in% names(cred) ) )
    stopifnot( ! any(is.na(cred)) )

    ## This call relies on assay.file being the first argument to
    ## queryClinWeb
    message("Querying the database for annotation...")
    p <- lapply(as.list(files), queryClinWeb,
                uri=uri, username=cred$username, password=cred$password, .opts=.opts)

    ## A list of all the variables
    vars <- Reduce(union, lapply(p, names))

    ## Make sure all the variables are represented in each list. This
    ## is a bit kludgey, but it does work.
    p <- lapply(p, function(x) { y <- x[vars]
                                 names(y) <- vars
                                 n <- unlist(lapply(y, is.null))
                                 y[n] <- NA
                                 y } )
    p <- lapply(p, unlist)
    p <- data.frame(do.call('rbind', p))
    rownames(p) <- files

    return(p)
}

reannotateFromClinWeb <- function( data, uri, .opts=list(), cred=NULL ) {

    ## AffyBatch is apparently not a subclass of ExpressionSet.
#    stopifnot(inherits(data, 'ExpressionSet'))

    files <- sampleNames(data)

    p <- .filenamesToPData(files, uri, .opts, cred)

    stopifnot(all(as.character(p$filename) == as.character(sampleNames(data))))
    pData(data) <- p

    return(data)
}

## Also public, this method is non-interactive and just returns the
## annotation for a given file or barcode.
queryClinWeb <- function (assay.file=NULL, assay.barcode=NULL, uri, username, password, .opts) {

    if ( is.null(assay.file) && is.null(assay.barcode) )
        stop("Error: Either assay.file or assay.barcode must be specified")

    if ( missing(uri) || missing(username) || missing(password) )
        stop("Error: uri, username and password are required")

    if ( missing(.opts) )
        .opts <- list()
    else
        if ( ! is.list(.opts) )
            stop("Error: .opts must be a list object")

    ## Return a list of key-value pairs suitable for inserting into an
    ## AnnotatedDataFrame

    header <- list('X-Username' = username, 'X-Password' = password, 'Content-type' = 'text/xml')
    header <- do.call('rbind', header)
    header <- paste(rownames(header), header, sep=':', collapse="\n")

    ## Strip off trailing /
    uri <- gsub( '/+$', '', uri )
    if ( ! is.null(assay.file) )
        uri <- paste(uri, '/rest/assay_file/',    RCurl::curlEscape(assay.file),    sep='')
    else
        uri <- paste(uri, '/rest/assay_barcode/', RCurl::curlEscape(assay.barcode), sep='')

    ## Retrieve the xml
    .opts$HTTPHEADER=header
    rc <- try(xml <- RCurl::getURLContent(uri, .opts=.opts))
    if ( inherits (rc, 'try-error') )
        stop("Unable to retrieve annotation from database: ", assay.file, assay.barcode)

    ## parse the XML, return the info.
    rc <- try(xml <- XML::xmlParse(xml, asText=TRUE))
    if ( inherits(rc, 'try-error') )
        stop("Error parsing XML")

    xml <- XML::xmlToList(xml)

    attrs <- as.list(c(xml$data$.attrs,
                       xml$data$channels$.attrs,
                       xml$data$channels$sample$.attrs,
                       xml$data$qc))

    ## EmergentGroups and PriorGroups are a bit trickier, since they're 0..n
    sample <- xml$data$channels$sample

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

