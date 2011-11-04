## Copyright 2011 Tim Rayner, University of Cambridge
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


facsCellPurity <- function( pre, pos, cell.type, B=100, K.start=1:6 ) {

    require(flowCore)
    require(flowClust)
    require(flowViz)

    .readAndLog <- function(f, ...) {
        x <- read.FCS(f, ...)
        x <- transform(x,
                       `FL1-H`=log10(`FL1-H`),
                       `FL2-H`=log10(`FL2-H`),
                       `FL3-H`=log10(`FL3-H`),
                       `FL4-H`=log10(`FL4-H`),
                       `SSC-H`=log10(`SSC-H`),
                       `FSC-H`=log10(`FSC-H`))
        return(x)
    }

    ## Select the number of clusters which makes approximately the
    ## most sense. The 0.1 below is an arbitrary threshold and could
    ## stand some tuning.
    .findBestBIC <- function(r, m=0.1) {
        d <- diff(criterion(r, 'BIC'))
        w <- sum(d/d[1] > m) + 1 ## N.B. assumes monotonically increasing BIC
        return(w)
    }

    ## This map lists points near the centre of the target
    ## cluster. One hopes that these are sufficiently consistent that
    ## this will work. FIXME needs values filled in for all five cell types.
    ct.maplist <- list(CD4=list(`FL1-H`=2.2, `FL2-H`=3.2),
                       CD8=list(`FL2-H`=, `FL4-H`=),
                       CD14=list(`FL2-H`=, `FL4-H`=),
                       CD16=list(`FL2-H`=, `FL4-H`=),
                       CD19=list(`FL2-H`=, `FL4-H`=))

    ct.map <- ct.maplist[[ cell.type ]]
    if ( is.null(ct.map) )
        stop('Unrecognised cell type.')

    ## First read in the pre data and log10 transform.
    ld <- .readAndLog(pre)

    ## Find clusters. FIXME the B=100 probably needs fixing and the
    ## whole function made parallelizable.
    ld.res <- flowClust(ld, varNames=c('FSC-H','SSC-H'), K=K.start, B=B)
    K      <- .findBestBIC(ld.res)

    ## FIXME generate a plot at this juncture.

    
    ld.gate <- tmixFilter('live_cells', c('FSC-H','SSC-H'), K=K, B=B, level=0.8)

    ## FIXME we need some heuristics here to correctly identify live vs. dead populations.
    ld.gated <- filter(ld, ld.gate)
    ld.pops  <- split(ld, ld.gated, population=list(live=2, dead=1)) ## these numbers may well be wrong.

    ## FIXME the channels in use need to be determined by cell type.
    ct.res <- flowClust(ld.pops$live, varNames=c('FL1-H','FL2-H'), K=K.start, B=B)
    K      <- .findBestBIC(ct.res)

    ct.testgate  <- tmixFilter('CD4', c('FL1-H','FL2-H'), K=K, B=B, level=0.8)
    ct.testgated <- filter(ld.pops$live, ct.testgate)
    ct.testpops  <- split(ld.pops$live, ct.testgated, population=list(a=1, b=2, c=3)) ## again we need some heuristics FIXME.

    ## FIXME figure out which our target cluster is and expand the
    ## ranges to include everything except for the other identified
    ## clusters.
    range(exprs(ct.testpops$c[,'FL1-H']))
    range(exprs(ct.testpops$c[,'FL2-H']))

    ## FIXME make this a rectangleGate instead, using the ranges identified in the previous step.

    ## FIXME also generate a plot here, overlaying the plot of ct.res[[K]] with the new rect gate.
    ct.gate  <- quadGate(`FL1-H`=65, `FL2-H`=270)  ## Obviously these numbers are wrong FIXME.

    ct       <- .readAndLog(pos)
    ct.gated <- filter(ct, ct.gate)

#    plot(split(y, z)[[1]], c('FL1-H','FL2-H'))

    summary(ct.gated) ## Should spit out the purity value.
}

calculateCellPurities <- function(uri, .opts=list(), cred) {

    require('RCurl')

    .retrieveFileInfo <- function(sample_id, type, uri, .opts, cred) {

        uri <- sub( '/+$', '', uri )

        file <- csJSONQuery(resultSet='SampleDataFile',
                            condition=list('sample_id'=sample_id,
                                           'type_id.value'=type),
                            attributes=list('join'='type_id'),
                            uri=uri,
                            .opts=.opts,
                            cred=cred)

        if ( length(file) < 1 ) {
            warning("File not found: ", type, " file for sample ", sample_id, ". Skipping.")
            return() 
        } else if (length(file) > 1) {
            warning("Multiple files found: ", type, " file for sample ", sample_id, ". Skipping.")
            return()
        }

        ## FIXME better to centralise this redirection somewhere. ORM
        ## fix to automate file uri attribute?
        file.uri <- paste(uri, 'static/datafiles/sample', file$filename, sep='/')

        return(file.uri)
    }

    .downloadFile <- function( uri, outfile, .opts=list() ) {
        ## FIXME at some point it would be good to password-protect
        ## these files, at which point we need to use an authenticated
        ## RCurl session.
        content <- getBinaryURL(uri, .opts=.opts)
        writeBin(content, outfile)
        return();
    }

    ## Connect to the clinical database; pull down a list of
    ## samples lacking cell purities but having the files required to
    ## attempt a calculation.
    cond    <- list('cell_purity'=NULL,  ## FIXME this will probably be changed to auto_cell_purity.
                    'type_id.value'='FACS positive')
    attrs   <- list(join=list('sample_data_files'='type_id'))
    samples <- csJSONQuery(resultSet='Sample',
                           condition=cond,
                           attributes=attrs,
                           uri=uri,
                           .opts=.opts,
                           cred=cred)

    ## Loop over the samples, pull down the two files required
    ## (recheck that they're both present).
    for ( samp in samples ) {
        pre <- .retrieveFileInfo(samp$id, 'FACS pre', uri, .opts, cred)
        pos <- .retrieveFileInfo(samp$id, 'FACS positive', uri, .opts, cred)

        if ( any(is.null(c(pre, pos)) ) )
            next

        ## Download both files to a temporary location.
        fn.pre <- tempfile()
        fn.pos <- tempfile()
        .downloadFile(pre, fn.pre, .opts)
        .downloadFile(pos, fn.pos, .opts)

        ## Retrieve the cell type
        ct <- csJSONQuery(resultSet='ControlledVocab',
                          condition=list(id=samp$cell_type_id),
                          uri=uri,
                          .opts=.opts,
                          cred=cred)

        ## FIXME Attempt cell purity calculation.
        facsCellPurity( fn.pre, fn.pos, ct$value )
    }

    return()
}

outputCSV <- function(res, file) {

    ## FIXME output results in tabular format to file, suitable for
    ## use with tab2clinstudy.pl.

}

## USAGE: Rscript $0 uri outfile
if ( ! interactive() ) {
    args <- commandArgs(TRUE)
    res  <- calculateCellPurities(uri=args[1])
    outputCSV(res, file=args[2])
}
