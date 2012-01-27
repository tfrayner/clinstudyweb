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


## Current status:
##
## - CD4, CD8 and CD14 will probably work with just a little tweaking.
##
## - CD16 is just too pure in the pre fractions! Clustering probably
##   needs to know about this; special case for this cell type.
##
## - CD19 is to be quite honest a bit of a mess. Not sure at all how
##   to deal with this cell type.

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
    ## this will work. FIXME needs values filled in for all five cell
    ## types. Note that we're assuming elsewhere that the ordering
    ## here is consistent with an X, Y interpretation in plots.
    ct.maplist <- list(CD4=list(`FL1-H`=2.2, `FL2-H`=3.2),
                       CD16=list(`FL1-H`=2.5, `FL2-H`=3),
                       CD14=list(`FL1-H`=1.5,`FL2-H`=3.5),
                       CD8=list(`FL2-H`=3.2, `FL4-H`=2.9),
                       CD19=list(`FL1-H`=2.4, `FL2-H`=2.2))

    ct.map <- ct.maplist[[ cell.type ]]
    if ( is.null(ct.map) )
        stop('Unrecognised cell type.')

    xch <- names(ct.map)[1]
    ych <- names(ct.map)[2]

    ## First read in the pre data and log10 transform.
    ld <- .readAndLog(pre)

    ## Find clusters. FIXME the B=100 probably needs fixing and the
    ## whole function made parallelizable. Note that we fix K at 2
    ## because we expect only live and dead cell populations
    ## here. (FIXME a large granulocyte population would throw this
    ## off though).
    ld.res <- flowClust(ld, varNames=c('FSC-H','SSC-H'), K=2, B=B)

    ld.gate  <- tmixFilter('live_cells', c('FSC-H','SSC-H'), K=2, B=B, level=0.8)
    ld.gated <- filter(ld, ld.gate)

    ## This gives a plot indicating which population was chosen as live cells.
    plot(ld.gated, data=ld)
    ## Alternatively (seems to be identical):
    plot(ld.res, data=ld)

    ## Take the population with the largest median FSC and assume it's the live cell population.
    ld.pops  <- split(ld, ld.gated)
    w <- which.max(sapply(ld.pops, function(cl) median(exprs(cl[, 'FSC-H']))))

    ## For illustration only; this would ideally also indicate the
    ## location of the gate we're ultimately constructing here.
    plot(ld.pops[[w]], c(xch, ych))

    ct.res <- flowClust(ld.pops[[w]], varNames=c(xch, ych), K=K.start, B=B)
    K      <- .findBestBIC(ct.res)

    ct.testgate  <- tmixFilter('CD4', c(xch, ych), K=K, B=B, level=0.8)
    ct.testgated <- filter(ld.pops[[w]], ct.testgate)
    ct.testpops  <- split(ld.pops[[w]], ct.testgated)

    ## This now has the initial clustering illustrated.
    plot(ct.testgated, data=ld.pops[[w]])

    ## Figure out which our target cluster is and expand the ranges to
    ## include everything except for the other identified clusters.
    ##
    ## Rough outline of the algorithm:
    ## a. find the target cluster (this needs the ct.maplist heuristic).
    ## b. for each non-target cluster, sort into locations relative to the
    ##      target (left/right/above/below). This will be based on the direction
    ##      of the largest distance between target and non-target clusters.
    ## c. find the nearest point to the target in the combined clusters from each location
    ## d. for any NULL directions, take the distance equal to that for the clusters located
    ##      in the opposite direction. If there are no such clusters, maybe take the mean
    ##      of all the remaining distances (e.g. above distance = mean of right and left distances).

    ## Step a: find the target cluster.
    .findTarget <- function( ct.testpops, ct.map ) {

        w <- sapply(ct.testpops, function(pop) {
            all(sapply(names(ct.map), function(ch) {
                xr <- range(exprs(pop[, ch]))
                x <- ct.map[[ch]]
                return(x > xr[1] & x < xr[2])
            }))
        })

        if ( sum(w) == 1 )
            return(w)
          else
              stop("Either zero or multiple gated populations match our target heuristic.")
    }

    w <- .findTarget( ct.testpops, ct.map )
    tgt <- ct.testpops[w][[1]]
    oth <- ct.testpops[!w]

    ## Step b: sort non-target clusters into locations relative to the target.
    .locateCluster <- function( cl, tgt, xch, ych ) {
        xtr <- range(exprs(tgt[, xch]))
        ytr <- range(exprs(tgt[, ych]))

        xcr <- range(exprs(cl[, xch]))
        ycr <- range(exprs(cl[, ych]))

        sc <- c(left  = xtr[1]-xcr[2],
                down  = ytr[1]-ycr[2],
                right = xcr[1]-xtr[2],
                up    = ycr[1]-ytr[2])
        which.max(sc)
    }

    locs <- sapply(oth, .locateCluster, tgt, xch, ych)

    ## Step c: combine the clusters and find the nearest point to the
    ## target in each available direction.
    .findNearestPoints <- function( oth, locs, xch, ych ) {
        up <- sapply(oth[names(locs) == 'up'], function(cl) min(exprs(cl)[, ych]) )
        dn <- sapply(oth[names(locs) == 'down'], function(cl) max(exprs(cl)[, ych]) )
        rt <- sapply(oth[names(locs) == 'right'], function(cl) min(exprs(cl)[, xch]) )
        lf <- sapply(oth[names(locs) == 'left'], function(cl) max(exprs(cl)[, xch]) )

        up <- ifelse( length(up) > 0, min(up), NA )
        dn <- ifelse( length(dn) > 0, max(dn), NA )
        rt <- ifelse( length(rt) > 0, min(rt), NA )
        lf <- ifelse( length(lf) > 0, max(lf), NA )

        return(list(up=up, down=dn, right=rt, left=lf))
    }

    nrst <- .findNearestPoints(oth, locs, xch, ych)

    ## Step d: handle the directions missing any data.
    .fillInNAPoints <- function(nrst, tgt, xch, ych) {
        xtr <- range(exprs(tgt[, xch]))
        ytr <- range(exprs(tgt[, ych]))

        dist <- list(down  = ytr[1] - nrst$down,
                     up    = nrst$up - ytr[2],
                     left  = xtr[1] - nrst$left,
                     right = nrst$right - xtr[2])

        ## First, use a balanced distance from the opposing direction
        ## if available.  If there are still any NAs, find the non-NA
        ## mean of the distances and use that.
        m <- mean(unlist(dist), na.rm=TRUE)
        if ( is.na(nrst$up) )
            nrst$up    <- ytr[2] + ifelse(is.na(dist$down), m, dist$down)
        if ( is.na(nrst$down) )
            nrst$down  <- ytr[1] - ifelse(is.na(dist$up), m, dist$up)
        if ( is.na(nrst$right) )
            nrst$right <- xtr[2] + ifelse(is.na(dist$left), m, dist$left)
        if ( is.na(nrst$left) )
            nrst$left  <- xtr[1] - ifelse(is.na(dist$right), m, dist$right)

        return(nrst)
    }

    nrst <- .fillInNAPoints(nrst, tgt, xch, ych)
    if ( any( is.na( unlist(nrst) ) ) )
        stop("Error: cannot determine rectangle gate; no outlier clusters?")

    ## The gates we're getting currently seem to be a bit on the large
    ## side; here we shrink them down to size a bit.
    .shrinkRectGate <- function(nrst, tgt, xch, ych) {

        ## Initial try: reduce the distance between the gate and the
        ## tgt ranges by a fraction (e.g. 0.6).
        xtr <- range(exprs(tgt[, xch]))
        ytr <- range(exprs(tgt[, ych]))

        nrst$up    <- ytr[2] + ((nrst$up - ytr[2]) * 0.6)
        nrst$down  <- ytr[1] - ((ytr[1] - nrst$down) * 0.6)
        nrst$right <- xtr[2] + ((nrst$right - xtr[2]) * 0.6)
        nrst$left  <- xtr[1] - ((xtr[1] - nrst$left) * 0.6)

        return(nrst)
    }

    nrst <- .shrinkRectGate(nrst, tgt, xch, ych)

    ## FIXME check for negative distances, i.e. overlapping clusters.

    ## Show the derived rectangle gate on the plot.
    bc <- c(nrst$left, nrst$down, nrst$right, nrst$up)
    do.call('rect', as.list(bc))

    ## Construct the rectangle gate.
    x <- list( c( nrst$left, nrst$right), c(nrst$down, nrst$up) )
    names(x) <- c(xch, ych)
    ct.gate  <- do.call('rectangleGate', x)

    ct       <- .readAndLog(pos)
    ct.gated <- filter(ct, ct.gate)

    ## Plot the impurities.
    plot(ct, c(xch, ych))
    do.call('rect', as.list(bc))

    x <- summary(ct.gated) ## Should spit out the purity value.

    return(x$p)
}

calculateCellPurities <- function(uri, .opts=list(), cred, outfile) {

    require(RCurl)

    .retrieveFileInfo <- function(sample_id, type, uri, .opts, cred) {

        uri <- sub( '/+$', '', uri )

        file <- csJSONQuery(resultSet='SampleDataFile',
                            condition=list('sample_id'=sample_id,
                                           'type_id.value'=type),
                            attributes=list('join'='type_id'),
                            uri=uri,
                            .opts=.opts,
                            auth=cred)

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
                           auth=cred)

    ## Loop over the samples, pull down the two files required
    ## (recheck that they're both present).
    results <- vector(mode='list', length=length(samples))
    for ( n in 1:length(samples) ) {

        samp <- samples[[n]]

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
                          auth=cred)

        ## FIXME Attempt cell purity calculation.
        pur <- facsCellPurity( fn.pre, fn.pos, ct$value )

        results[[n]] <- c(sample=samp$name, purity=pur)
    }

    ## Beware large lists in this call FIXME.
    results <- do.call('rbind', results)

    return(results)
}

outputCSV <- function(res, file) {

    ## Output results in tabular format to file, suitable for
    ## use with tab2clinstudy.pl.

    colnames(results) <- c('Sample|name','Sample|auto_purity')

    write.csv(results, file=file, sep="\t", row.names=FALSE)

    return()
}

## USAGE: Rscript $0 uri outfile
if ( ! interactive() ) {
    args <- commandArgs(TRUE)
    res  <- calculateCellPurities(uri=args[1])
    outputCSV(res, file=args[2])
}
