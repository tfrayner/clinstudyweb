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

cellTypeHeuristic <- function(ct) {

    ## This map lists points near the centre of the target
    ## cluster. One hopes that these are sufficiently consistent that
    ## this will work. Note that we're assuming elsewhere that the
    ## ordering here is consistent with an X, Y interpretation in
    ## plots.
    ct.maplist <- list(CD4  = list(`FL1-H`=2.2, `FL2-H`=3.2),
                       CD16 = list(`FL1-H`=2.5, `FL2-H`=3),
                       CD14 = list(`FL1-H`=1.5, `FL2-H`=3.5),
                       CD8  = list(`FL2-H`=3.2, `FL4-H`=2.9),
                       CD19 = list(`FL1-H`=2.4, `FL2-H`=2.2))

    return(ct.maplist[[ct]])
}

facsCellPurity <- function( pre, pos, cell.type, verbose=FALSE, B=100, K.start=1:6 ) {

    require(flowCore)
    require(flowClust)
    require(flowViz)

    .readAndLogTransform <- function(f, ...) {
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


    livegate <- list(up=2.5, down=1, left=2.3, right=3.5)

    ct.map <- cellTypeHeuristic( cell.type )
    if ( is.null(ct.map) )
        stop(sprintf('Unrecognised cell type %s.', cell.type), call.=FALSE)

    if (verbose)
        message(sprintf("Processing %s data (params: %s).", cell.type, deparse(ct.map, control=c())))

    xch <- names(ct.map)[1]
    ych <- names(ct.map)[2]

    ## First read in the pre data and log10 transform.
    ld <- .readAndLogTransform(pre)

    ## Find clusters. FIXME the B=100 probably needs fixing and the
    ## whole function made parallelizable. Fixing K at 2 here tends to
    ## give spurious results so we have to be a bit smart about
    ## identifying live cell populations.
    if (verbose) message("Identifying live-cell population...")
    suppressMessages(ld.res <- flowClust(ld, varNames=c('FSC-H','SSC-H'), K=K.start, B=B))
    K      <- .findBestBIC(ld.res)

    ld.gate  <- tmixFilter('live_cells', c('FSC-H','SSC-H'), K=K, B=B, level=0.8)
    suppressMessages(ld.gated <- filter(ld, ld.gate))

    ## This gives a plot indicating which population was chosen as live cells.
    plot(ld.gated, data=ld)
    bc <- list(livegate$left, livegate$down, livegate$right, livegate$up)
    bc$lty <- 2
    do.call('rect', bc)

    ## Find the live populations
    .findLivePops <- function( ld.pops, livegate ) {

        w <- sapply(ld.pops, function(pop) {
            xr <- range(exprs(pop[, 'FSC-H']))
            yr <- range(exprs(pop[, 'SSC-H']))
            xw <- xr[1] > livegate$left & xr[2] < livegate$right
            yw <- yr[1] > livegate$down & yr[2] < livegate$up
            return( xw & yw )
        })

        if ( sum(w) == 0 )
            stop("Zero gated populations fall entirely within our live-cell gate.", call.=FALSE)

        return(w)
    }

    ## Take the populations which fall entirely within the livegate
    ## rectangle as the live cell population.
    ld.pops <- split(ld, ld.gated)
    w <- .findLivePops(ld.pops, livegate)

    ## Merge the +ve population in to give the algorithm a better hint.
    ld.pops <- as(ld.pops[w], 'flowSet')  # Replace this line with the following two lines to include the hint.
#    ct       <- .readAndLogTransform(pos)
#    ld.pops <- as(append(ld.pops[w], ct), 'flowSet')
    ld.pops <- as(ld.pops, 'flowFrame')

    ## Identify the 'best' number of clusters to fit.
    if (verbose) message(sprintf("Identifying %s population...", cell.type))
    suppressMessages(ct.res <- flowClust(ld.pops, varNames=c(xch, ych), K=K.start, B=B))
    K      <- .findBestBIC(ct.res)

    ## Filter the live cell population based on that value of K.
    ct.testgate  <- tmixFilter('CD4', c(xch, ych), K=K, B=B, level=0.8)
    suppressMessages(ct.testgated <- filter(ld.pops, ct.testgate))
    ct.testpops  <- split(ld.pops, ct.testgated)

    ## FIXME discard the ct.testpops with only a handful of events in them?

    ## This now has the initial clustering illustrated. See below for
    ## an overlay of the final rectangleGate.
    plot(ct.testgated, data=ld.pops)

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

        ## First, identify the nearest cluster.
        dists <- sapply(ct.testpops, function(pop) {
            ch.dist <- sapply(names(ct.map), function(ch) {
                xr <- range(exprs(pop[, ch]))
                m  <- mean(xr)
                return(ct.map[[ch]]-m)
            })
            return(sqrt(sum(ch.dist^2)))
        })

        w <- dists == min(dists) & dists < 1 # No further than one log-unit away.

        if ( sum(w) == 0 )
            stop("Zero populations match our target heuristic.", call.=FALSE)

        init <- ct.testpops[w][[1]]

        ## Now expand out to cover clusters which overlap the midpoint
        ## of the initial cluster.
        w <- sapply(ct.testpops, function(pop) {
            dst <- sapply(names(ct.map), function(ch) {
                xm <- mean(range(exprs(pop[, ch])))
                tm <- mean(range(exprs(init[, ch])))
                return(xm-tm)
            })
            # This is probably too relaxed; consider only including
            # populations within a smaller distance of our initial
            # target (0.5 is too small for CD16 though).
            return(sqrt(sum(dst^2)) < 1) 
        })

        w <- w & dists < 1  # You wouldn't think this would be a problem, but it is.

        return(w)
    }

    w <- .findTarget( ct.testpops, ct.map )
    tgt <- as(ct.testpops[w], 'flowSet')
    tgt <- as(tgt, 'flowFrame')
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

        ## Another fall-back option: just expand the distances by some
        ## fraction of the widths of the target population. Most useful for CD16.
        xwd <- abs(xtr[2] - xtr[1])
        ywd <- abs(ytr[2] - ytr[1])
        if ( is.na(nrst$up) )
            nrst$up    <- ytr[2] + ywd
        if ( is.na(nrst$down) )
            nrst$down  <- ytr[1] - ywd
        if ( is.na(nrst$right) )
            nrst$right <- xtr[2] + xwd
        if ( is.na(nrst$left) )
            nrst$left  <- xtr[1] - xwd

        return(nrst)
    }

    nrst <- .fillInNAPoints(nrst, tgt, xch, ych)
    if ( any( is.na( unlist(nrst) ) ) )
        stop("Error: cannot determine rectangle gate; no outlier clusters?", call.=FALSE)

    ## The gates we're getting currently seem to be a bit on the large
    ## side; here we shrink them down to size a bit.
    .shrinkRectGate <- function(nrst, tgt, xch, ych, f=0.6) {

        ## Initial try: reduce the distance between the gate and the
        ## tgt ranges by a fraction (e.g. 0.6).
        xtr <- range(exprs(tgt[, xch]))
        ytr <- range(exprs(tgt[, ych]))

        nrst$up    <- ytr[2] + ((nrst$up - ytr[2]) * f)
        nrst$down  <- ytr[1] - ((ytr[1] - nrst$down) * f)
        nrst$right <- xtr[2] + ((nrst$right - xtr[2]) * f)
        nrst$left  <- xtr[1] - ((xtr[1] - nrst$left) * f)

        return(nrst)
    }

    nrst <- .shrinkRectGate(nrst, tgt, xch, ych, f=1)

    ## Show the derived rectangle gate on the plot.
    bc <- c(nrst$left, nrst$down, nrst$right, nrst$up)
    do.call('rect', as.list(bc))

    ## Construct the rectangle gate.
    x <- list( c( nrst$left, nrst$right), c(nrst$down, nrst$up) )
    names(x) <- c(xch, ych)
    x$filterId <- sprintf("Live%sGate", cell.type)
    ct.gate  <- do.call('rectangleGate', x)

    ct       <- .readAndLogTransform(pos)
    ct.gated <- filter(ct, ct.gate)

    ## Plot the impurities.
    plot(ct, c(xch, ych))
    do.call('rect', as.list(bc))

    x <- summary(ct.gated) ## Should spit out the purity value.

    if (verbose)
        print(x)

    return(x$p)
}

spadeCellPurity <- function( pre, pos, cell.type, verbose=FALSE, output_dir=tempdir(), tolerance=3, archive_dir ) {

    require(spade)

    ct.map <- cellTypeHeuristic( cell.type )
    if ( is.null(ct.map) )
        stop(sprintf('Unrecognised cell type %s.', cell.type), call.=FALSE)

    SPADE.driver(pos, out_dir=output_dir, cluster_cols=c(names(ct.map), "FSC-H", "SSC-H"))
    gfile <- file.path(output_dir,
                       paste(basename(pos), ".density.fcs.cluster.fcs.medians.gml",
                             sep=''))
    message("Reading in graph file ", gfile, "...")
    mst    <- igraph:::read.graph(gfile, format="gml")
    layout <- read.table(file.path(output_dir, "layout.table"))
    SPADE.plot.trees(mst, output_dir,
                     out_dir=file.path(output_dir, "pdf"),
                     layout=as.matrix(layout))

    ## Beware that round-tripping via GML seems to strip underscores
    ## from attribute names.
    if ( ! missing(archive_dir) ) {
        outfile <- file.path(archive_dir, paste(basename(pos), ".gml", sep=''))
        message("Writing graph file ", outfile, "...")
        igraph::write.graph(mst, outfile, format="gml")
    }
    
    bins <- lapply(names(ct.map), spadeAssignBins, mst=mst, tolerance=tolerance )

    ## A quick look with Cytoscape/SPADE suggests that we can accept a
    ## maxpop call in any, rather than all, channels.
    maxpop <- apply(do.call('rbind', bins), 2, all)

    return( sum(V(mst)$percenttotal[ as.logical(maxpop) ]) )
}

## Wrapper function to link the output of cellTypeHeuristic to the
## input of igraphCliques.
spadeAssignBins <- function(ch, mst, tolerance, suffix='_clust') {
    ch <- sub('-', '', ch)
    med <- paste('medians', ch, suffix, sep='')
    cvs <- paste('cvs', ch, suffix, sep='')
    stopifnot( all( c(med, cvs) %in% list.vertex.attributes(mst) ) )
    b <- igraphCliques(mst, medians=med, cvs=cvs, tolerance=tolerance)
    b == 1
}

calculateCellPurities <- function(uri, .opts=list(), auth=NULL, verbose=FALSE, logfile=NULL, purity.fun=facsCellPurity, ...) {

    require(RCurl)
    require(ClinStudyWeb)

    if ( ! is.null(logfile) )
        logconn <- file( logfile, open='at' )
    else
        logconn <- NULL

    if ( is.null(auth) )
        auth <- ClinStudyWeb::getCSWebHandle(uri=uri, .opts=.opts)

    writeLog <- function(x) {
        if ( ! is.null(logconn) ) {
            writeLines(paste(date(), x, sep="   "), con=logconn)
            flush(logconn)
        }
        if ( verbose )
            message(x)
        return()
    }

    writeLog("\n** Starting Cell Purity Calculation Pipeline...")

    .retrieveFileInfo <- function(sample_id, type, uri, .opts, auth) {

        uri <- sub( '/+$', '', uri )

        file <- csJSONQuery(resultSet='SampleDataFile',
                            condition=list('sample_id'=sample_id,
                                           'type_id.value'=type),
                            attributes=list('join'='type_id'),
                            uri=uri,
                            .opts=.opts,
                            auth=auth)

        if ( length(file) < 1 ) {
            warning("File not found: ", type, " file for sample ", sample_id, ". Skipping.")
            return() 
        } else if (length(file) > 1) {
            warning("Multiple files found: ", type, " file for sample ", sample_id, ". Skipping.")
            return()
        }

        return(file[[1]]$uri)
    }

    .downloadFile <- function( uri, outfile, auth, .opts=list() ) {
        ## FIXME at some point it would be good to password-protect
        ## these files, at which point we need to use an authenticated
        ## RCurl session.
        content <- getBinaryURL(uri, curl=auth, .opts=.opts)
        writeBin(content, outfile)
        return();
    }

    ## Connect to the clinical database; pull down a list of
    ## samples lacking cell purities but having the files required to
    ## attempt a calculation.
    writeLog("Querying the database for appropriate samples...")
    cond    <- list('auto_cell_purity'=NULL,
                    'home_centre_id.value'='Cambridge',
                    'type_id.value'='FACS positive')
    attrs   <- list(join=list('sample_data_files'='type_id',
                              'visit_id'=list('patient_id'='home_centre_id')))

    writeLog("Querying database for sample data files...")
    samples <- csJSONQuery(resultSet='Sample',
                           condition=cond,
                           attributes=attrs,
                           uri=uri,
                           .opts=.opts,
                           auth=auth)

    ## Loop over the samples, pull down the two files required
    ## (recheck that they're both present).
    results <- vector(mode='list', length=length(samples))

    for ( n in 1:length(samples) ) {

        samp <- samples[[n]]

        if ( is.null(samp$cell_purity) )
            next

        writeLog(sprintf("Commencing analysis for sample %s...", samp$name))

        pre <- .retrieveFileInfo(samp$id, 'FACS pre', uri, .opts, auth)
        pos <- .retrieveFileInfo(samp$id, 'FACS positive', uri, .opts, auth)

        if ( any(sapply(list(pre, pos), is.null) ) ) {
            writeLog("Either pre or pos files not found.")
            next
        }

        ## Retrieve the cell type
        ct <- csJSONQuery(resultSet='ControlledVocab',
                          condition=list(id=samp$cell_type_id),
                          uri=uri,
                          .opts=.opts,
                          auth=auth)

        ## Download both files to a temporary location.
        writeLog("Downloading files...")
        tmpdir <- tempdir()
        fn.pre <- file.path(tmpdir, basename(pre))
        fn.pos <- file.path(tmpdir, basename(pos))
        .downloadFile(pre, fn.pre, auth, .opts)
        .downloadFile(pos, fn.pos, auth, .opts)

        ## Attempt cell purity calculation.
        writeLog(sprintf("Calculating purity (%s)...", ct[[1]]$value))
        rc <- try(pur <- purity.fun( fn.pre, fn.pos, ct[[1]]$value, verbose=verbose, ... ))

        if ( inherits(rc, 'try-error') ) {
            writeLog(sprintf("Error encountered: %s", rc))
            next
        }

        writeLog(sprintf("Results: %s=%f (%s)", samp$name, pur, samp$cell_purity))

        results[[n]] <- c(sample=samp$name, purity=pur, manual=samp$cell_purity)
    }

    ## Beware large lists in this call FIXME.
    results <- do.call('rbind', results)

    return(results)
}

outputCSV <- function(results, file) {

    ## Output results in tabular format to file, suitable for
    ## use with tab2clinstudy.pl.

    colnames(results) <- c('Sample|name','Sample|auto_purity')

    write.table(results, file=file, sep="\t", row.names=FALSE)

    return()
}

## USAGE: Rscript $0 uri outfile
if ( ! interactive() ) {
    args <- commandArgs(TRUE)
    res  <- calculateCellPurities(uri=args[1])
    outputCSV(res, file=args[2])
}

recalculateSpadePurities <- function( files, accept=c('all','any'), tolerance=3 ) {

    ## Recalculate purities from a list of GML files. Function assumes
    ## the naming convention adopted by util/facs_clinstudyml.pl which
    ## is effectively recycled by spadeCellPurity() above, when passed
    ## the archive_dir argument.

    require(igraph)
    
    accept <- match.arg(accept)

    .safeAssign <- function(ch, mst, ...) {
        rc <- try( bins <- spadeAssignBins(ch, mst, ...) )
        if ( inherits(rc, 'try-error') )
            return(rep(NA, length(V(mst))))
        return(bins)
    }

    res <- list()
    for ( f in files ) {

        cell.type <- strsplit(f, '_')[[1]][3]
        ct.map <- cellTypeHeuristic( cell.type )
        if ( is.null(ct.map) )
            stop(sprintf('Unrecognised cell type %s.', cell.type), call.=FALSE)

        mst    <- igraph:::read.graph(f, format="gml")
        bins   <- lapply(names(ct.map), .safeAssign, mst=mst,
                         tolerance=tolerance, suffix='clust' )

        if ( accept == 'all')
            maxpop <- apply(do.call('rbind', bins), 2, all)
        else
            maxpop <- apply(do.call('rbind', bins), 2, any)

        res[[f]] <- sum(V(mst)$percenttotal[ as.logical(maxpop) ])
    }

    return(res)
}
