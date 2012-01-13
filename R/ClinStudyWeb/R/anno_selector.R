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

## Code used to pull down lists of annotation classes (tests,
## phenotype quantities) and allow the user to choose the items to
## retrieve.
csWebTestNames <- function (uri, username=NULL, password=NULL, pattern=NULL,
                            retrieve.all=FALSE, .opts=list(), curl=NULL ) {

    if ( missing(uri) )
        stop("Error: uri is required")

    if ( ! is.list(.opts) )
        stop("Error: .opts must be a list object")

    query  <- list( pattern=pattern, retrieve_all=retrieve.all )

    status <- .csWebExecuteQuery( query, uri, 'query/list_tests', username, password, .opts, curl )

    ## FIXME do something with this.
    status$data
}

csWebPhenotypes <- function (uri, username=NULL, password=NULL, pattern=NULL,
                             .opts=list(), curl=NULL ) {

    if ( missing(uri) )
        stop("Error: uri is required")

    if ( ! is.list(.opts) )
        stop("Error: .opts must be a list object")

    query  <- list( pattern=pattern )

    status <- .csWebExecuteQuery( query, uri, 'query/list_phenotypes', username, password, .opts, curl )

    ## FIXME do something with this.
    status$data
}

csAnnoPicker <- function (testnames, phenotypes) {

    require(tcltk)

    testnames <- testnames[ order(names(testnames)) ]

    dlg <- tktoplevel()

    scr <- tkscrollbar(dlg, repeatinterval=5,
                       command=function(...) tkyview(tl, ...))

    tl <- tklistbox(dlg, height=10, selectmode="extended",
                    yscrollcommand=function(...) tkset(scr, ...), background="white")

    tkgrid(tklabel(dlg, text="Select Tests to retrieve."))
    tkgrid(tl, scr)
    tkgrid.configure(scr, rowspan=10, sticky='nsw')
    for ( n in 1:length(testnames))
        tkinsert(tl, 'end', names(testnames)[n])

    testChoice  <- list()
    phenoChoice <- list()

    OnOK <- function() {
        testChoice <<- testnames[ as.numeric(tkcurselection(tl))+1 ]
        tkdestroy(dlg)
    }

    b.OK <- tkbutton(dlg, text="    OK    ", command=OnOK)
    tkgrid(b.OK)
    tkfocus(dlg)

    tkwait.window(dlg)

    return(list(tests=testChoice, phenotypes=phenoChoice))
}
