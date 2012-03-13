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

## Code copied from
## http://bioinf.wehi.edu.au/~wettenhall/RTclTkExamples/modalDialog.html
## and modified.
getCredentials <- function(title='ClinStudyWeb Authentication',
                           entryWidth=30, returnValOnCancel=NA, parent) {

    ## Previous versions checked X11 here but that doesn't make sense
    ## for the MS Windows version of R, which pushes tcltk through the
    ## internal R graphics device.
    if ( ! capabilities()['tcltk'] )
        stop("Error: tcltk windowing system is not available.")

    require(tcltk)

    username <- returnValOnCancel
    password <- returnValOnCancel
    username.tcl <- tclVar('')
    password.tcl <- tclVar('')

    if ( missing(parent) ) {
        dlg <- tktoplevel()

        tkwm.geometry(dlg, .calcTkWmGeometry(350,130))
        tkwm.geometry(dlg, '') # Shrink back to default size
        tkwm.deiconify(dlg)
        tkgrab.set(dlg)
        tkfocus(dlg)
        tkwm.title(dlg,title)
    }
    else {
        dlg <- tkframe(parent)
        tkpack(dlg, expand=TRUE)
    }

    onOK <- function() {
        username <<- tclvalue(username.tcl)
        password <<- tclvalue(password.tcl)
        tkgrab.release(dlg)
        tkdestroy(dlg)
    }

    onCancel <- function() {
        username <<- returnValOnCancel
        password <<- returnValOnCancel
        tkgrab.release(dlg)
        tkdestroy(dlg)
    }

    # Put our buttons into a frame.
    f.buttons <- tkframe(dlg, borderwidth=15)
    b.OK     <- tkbutton(f.buttons, text="   OK   ", command=onOK)
    b.cancel <- tkbutton(f.buttons, text=" Cancel ", command=onCancel)
    tkpack(b.OK, b.cancel, side='right')

    # Text entry fields belong in a grid inside a frame.
    f.entries <- tkframe(dlg, borderwidth=15)

    e.user       <- tkentry(f.entries, width=paste(entryWidth), textvariable=username.tcl)
    l.user       <- tklabel(f.entries, text='Username: ')
    e.pass       <- tkentry(f.entries, width=paste(entryWidth), textvariable=password.tcl, show='*')
    l.pass       <- tklabel(f.entries, text='Password: ')
    
    tkgrid(l.user, e.user)
    tkgrid(l.pass, e.pass)

    # Line the fields and labels up in the middle.
    tkgrid.configure(e.user, e.pass, sticky='w')
    tkgrid.configure(l.user, l.pass, sticky='e')

    tkpack(f.entries, side='top')
    tkpack(f.buttons, anchor='se')
    
    tkfocus(e.user)
    tkbind(dlg, "<Destroy>", function() tkgrab.release(dlg))
    tkbind(e.user, "<Return>", onOK)
    tkbind(e.pass, "<Return>", onOK)
    tkwait.window(dlg)

    return(list(username=username, password=password))
}

getCSWebHandle <- function( uri=NULL, auth, .opts=list() ) {

    if ( is.null(uri) )
        stop('Error: uri argument must be provided.')

    if ( ! is.list(.opts) )
        stop("Error: .opts must be a list object")

    ## It's entirely possible to get here with just a uri.
    if ( missing(auth) )
        auth <- NULL
    if ( is.null(auth) ) {
        auth <- getCredentials()
        if ( any( is.na(auth) ) )
            stop('User cancelled database connection.')
    }

    ## Set up our session and authenticate.
    curl    <- RCurl::getCurlHandle()
    cookies <- file.path(Sys.getenv('HOME'), '.cookies.txt')
    RCurl::curlSetOpt(cookiefile=cookies, curl=curl)

    ## We need to detect login failures here.
    query  <- list(username=auth$username, password=auth$password)
    query  <- rjson::toJSON(query)
    query  <- RCurl::curlEscape(query)
    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=paste(uri, 'json_login', sep='/'),
                                 postfields=paste('data', query, sep='='),
                                 .opts=.opts,
                                 curl=curl,
                                 writefunction=status$update)

    ## Check the response for errors.
    status  <- rjson::fromJSON(status$value())
    if ( ! isTRUE(status$success) )
        stop(status$errorMessage)

    return(curl)
}

logoutCSWebHandle <- function( auth, .opts=list(), ... ) {

    ## N.B. ... argument included to allow generous use of ... in upstream functions.

    if ( ! inherits(auth, 'CURLHandle') )
        stop("Must pass in a CURLHandle object.")

    uri    <- .csUriFromCurlHandle(auth)

    if ( ! is.list(.opts) )
        stop("Error: .opts must be a list object")

    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=paste(uri, 'json_logout', sep='/'),
                                 .opts=.opts,
                                 curl=auth,
                                 writefunction=status$update)

    ## Check the response for errors.
    status  <- rjson::fromJSON(status$value())
    if ( res != 0 )
        warning('Unable to log out.')

    return()
}

.calcTkWmGeometry <- function( width, height ) {

    px <- as.numeric(tkwinfo('screenwidth', '.'))
    py <- as.numeric(tkwinfo('screenheight', '.'))

    sprintf('%dx%d+%d+%d', width, height, (px/2)-(width/2), (py/2)-(height/2))
}
