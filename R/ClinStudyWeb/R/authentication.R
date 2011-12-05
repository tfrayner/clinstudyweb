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
getCredentials <- function(title='Database Authentication', entryWidth=30, returnValOnCancel=NA) {

    if ( ! capabilities()['X11'] )
        stop("Error: X11 device is not available.")

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
    query  <- list(username=username, password=password)
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

.csLogOutAuthenticatedHandle <- function( uri, curl, .opts=list() ) {

    status <- RCurl::basicTextGatherer()
    res    <- RCurl::curlPerform(url=paste(uri, 'json_logout', sep='/'),
                                 .opts=.opts,
                                 curl=curl,
                                 writefunction=status$update)

    ## Check the response for errors.
    status  <- rjson::fromJSON(status$value())
    if ( res != 0 )
        warning('Unable to log out.')

    return()
}

