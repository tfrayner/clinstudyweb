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

    status$data
}

csAnnoPicker <- function (testnames=list(), phenotypes=list(), parent) {

    require(tcltk)

    testnames  <- testnames[ order(names(testnames)) ]
    phenotypes <- phenotypes[ order(names(phenotypes)) ]

    if ( missing(parent) ) {
        dlg <- tktoplevel()
        tkwm.geometry(dlg, .calcTkWmGeometry(550, 410))
        tkwm.geometry(dlg, '') # Shrink back to default size
        tktitle(dlg) <- 'ClinStudyWeb Annotation Selection'
    }
    else {
        dlg <- tkframe(tt)
        tkpack(dlg, expand=TRUE)
    }

    f.listbox <- tkframe(dlg, borderwidth=10)
    scr.tests <- tkscrollbar(f.listbox, repeatinterval=5,
                             command=function(...) tkyview(tl.tests, ...))
    tl.tests  <- tklistbox(f.listbox, height=20, width=30, selectmode="extended", exportselection=0,
                           yscrollcommand=function(...) tkset(scr.tests, ...), background="white")

    scr.pheno <- tkscrollbar(f.listbox, repeatinterval=5,
                             command=function(...) tkyview(tl.pheno, ...))
    tl.pheno  <- tklistbox(f.listbox, height=20, width=30, selectmode="extended", exportselection=0,
                           yscrollcommand=function(...) tkset(scr.pheno, ...), background="white")

    tkgrid(tklabel(f.listbox, text="Tests to retrieve:"), tklabel(f.listbox, text=""),
           tklabel(f.listbox, text="Phenotypes to retrieve:"))
    tkgrid(tl.tests, scr.tests, tl.pheno, scr.pheno)
    tkgrid.configure(scr.tests, rowspan=20, sticky='nsw')
    tkgrid.configure(scr.pheno, rowspan=20, sticky='nsw')

    for ( n in 1:length(testnames))
        tkinsert(tl.tests, 'end', names(testnames)[n])
    for ( n in 1:length(phenotypes))
        tkinsert(tl.pheno, 'end', names(phenotypes)[n])

    testChoice  <- list()
    phenoChoice <- list()

    OnOK <- function() {
        testChoice  <<- testnames[ as.numeric(tkcurselection(tl.tests))+1 ]
        phenoChoice <<- phenotypes[ as.numeric(tkcurselection(tl.pheno))+1 ]
        tkdestroy(dlg)
    }

    f.button <- tkframe(dlg, borderwidth=10)
    b.OK  <- tkbutton(f.button, text="    OK    ", command=OnOK)
    tkpack(b.OK, side='bottom')
    tkpack(f.listbox, side='top')
    tkpack(f.button, side='bottom')
    tkfocus(dlg)

    tkwait.window(dlg)

    return(list(tests=testChoice, phenotypes=phenoChoice))
}
