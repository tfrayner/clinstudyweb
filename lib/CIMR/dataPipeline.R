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
##
## Script to process data into a saved normalized R MAlist object.
## Call like this:
##
## Rscript dataPipeline.R targetfile.txt spottypes.txt adf.txt

## Other ideas for improving this pipeline:
##
##  - Filter out consistently non-expressed probes before linear
##    modelling (this is a post-normalisation step).
##
##  - Filter out probes with expression less than or equal to probe(s)
##    representing markers which should not be present (e.g. CD4,
##    CD8 in CD8 and CD4 cell types respectively).

processData <- function( targetFile, spotTypesFile, adfFile, logFile='datapipelineR.log' ) {

    ## The targetFile must be a standard limma targets file,
    ## indicating which channels contain sample and which contain
    ## reference. The reference name must be 'Ref' for automated
    ## design discovery.

    ## The spotTypesFile should link probe Name (ID = *) to control
    ## types. Names should match those in the passed adf object.

    ## The adfFile should be parseable into a data frame with a column
    ## Reporter.Name in exactly the same row order as that in the data
    ## files.

    require('limma')

    ## Read in the data, background correct, filter and print-tip
    ## loess adjustment.
    targets <- limma::readTargets(targetFile)
    f <- function(x) as.numeric(x$Flags > -50)
    RG <- limma::read.maimages(targets, source='genepix', wt.fun=f)

    ## Sort out RG$genes$Status; Weight buffer and empty spots
    ## two-fold for print tip-loess normalisation.
    adf <- read.table( adfFile, sep="\t", header=TRUE, stringsAsFactors=FALSE )
    RG$genes$Name <- adf$Reporter.Name

    ## FIXME this shouldn't be necessary once everyone is using the
    ## right koadarray mapping file.
    RG$genes$ID <- adf$Reporter.Identifier

    spottypes <- limma::readSpotTypes(spotTypesFile)
    RG$genes$Status <- limma::controlStatus(spottypes, RG)
    RG$weights <- limma::modifyWeights(RG$weights, RG$genes$Status, c("buffer", "empty"), c(2, 2))

    ## Background correct and print-tip loess.
    RG <- limma::backgroundCorrect(RG, method='normexp', offset=50)
    MA <- limma::normalizeWithinArrays(RG)

    ## Remove buffer and empty spots from downstream analysis.
    MA$weights <- limma::modifyWeights(MA$weights, RG$genes$Status, c("buffer", "empty"), c(0, 0))

    ## Remove spots marked as ambiguous (e.g. disagreement between probe library batches).
    MA$weights <- limma::modifyWeights(MA$weights, RG$genes$Status, c("ambiguous"), 0)

    ## Filter out any spots with particularly poor correlation between
    ## dye swaps.
    design <- limma::modelMatrix(targets, ref='Ref')
    MA <- filterDeviantSpots( MA, design, logFile )

    ## Save the data into one file per dye swap.
    for ( i in 1:ncol(design) ) {

        ## Figure out the filename from the design colnames.
        ix <- design[,i] != 0
        MAsubset <- MA[, ix]

        ## Assumes that the target file column 1 contains barcodes.
        fn <- paste( sort(targets[ix,]$Slidename), collapse='_' )
#        fn <- colnames(design)[i]
        fn <- gsub('[^A-Za-z0-9]+', '_', fn, perl=TRUE)
        filename <- paste(fn, 'RData', sep='.')

        ## Don't overwrite old files. Instead, append a number to the
        ## filename and retest, continuing as necessary until we get a
        ## filename we can use.
        while ( file.access(filename) == 0 ) {
            match <- regexpr('_[0-9]$', filename)
            len <- attr(match, 'match.length')
            if ( len >= 2 ) {
                num <- as.numeric(substr( filename, match+1, match+len ))
                substr( filename, match+1, match+len ) <- as.character(num+1)
            }
            else {
                filename <- paste(filename, 2, sep='_')
            }
        }

        save(MAsubset, file=filename)
    }

    return(MA)
}

filterDeviantSpots <- function( MA, design, logFile ) {

    ## Filter out the most extreme deviations between dye swaps.

    ## FIXME make this work seamlessly with both MAlist and RGlist.
    RG.n <- RG.MA(MA)
    q <- c()
    for ( i in 1:ncol(design) ) {

        designvec <- design[,i]
        index <- designvec != 0

        ## Use the design to figure out dye swap ratios.
        green <- t(apply(RG.n$G[,index], 1, function(x) { x^designvec[index] }))
        red   <- t(apply(RG.n$R[,index], 1, function(x) { x^-designvec[index] }))
        channelRatio <- red * green

        ## Raise each column of channelRatio by the power in the
        ## corresponding element of designvec and then multiply all
        ## columns together. In theory this should handle stuff more
        ## complex than simple dye swaps. Note that we're trying to
        ## get the ratio of R1/G1 to G2/R2, where 1 and 2 are the dye
        ## swaps. We already have G1/R1 and G2/R2 (channelRatio) so we
        ## just flip the dye swap once more and multiply the numbers.
        flipped <- apply( channelRatio, 1, function(x) { x^designvec[index] } )
        logDyeSwapRatio <- log2(apply( flipped + 0.0000001, 2, prod ))

        ## Assign the spot weights in the output to this vector
        ## (RG.n$weights, or MA$weights). This should also include the
        ## pre-existing weights!  Actually, simply filtering by a
        ## predefined cutoff might be the thing. In tests, the range
        ## 0.25 to 1.75 roughly corresponds to mean plus-or-minus
        ## 3SD. The problem with using quantiles here is that you're
        ## defining exactly how many spots we want to discard, which
        ## isn't quite what we're after. Could also exclude by SD, but
        ## again we're then ensuring that a set number of probes are
        ## always discarded (assuming normality, which of course we can't).
        m <- mean(logDyeSwapRatio)
        d <- sd(logDyeSwapRatio)

        ## This is currently a rather arbitrary value (5 SDs from the mean).
        range <- 5
        filter <- logDyeSwapRatio > (m - (range * d)) & logDyeSwapRatio < (m + (range * d))

        RG.n$weights[, index] <- limma::modifyWeights( RG.n$weights[, index], as.numeric(filter), c(0,1), c(0,1) )

        ## We could calculate the correlation coefficients before
        ## filtering out bad spots; not sure which is better, but this
        ## seems to better describe what's actually output.

        ## FIXME use limma::duplicateCorrelation on the final MA
        ## object instead? N.B. that only gives a general number for
        ## the whole data set, not per dye-swap.
        correlation <- cor(channelRatio[filter,], method='spearman')
        q[i] <- correlation[1,2]
    }

    names(q) <- colnames(design)

    ## Report the dye-swap correlation values to the user.
    write.table(data.frame(correlation=q), file=logFile, sep="\t", append=TRUE)

#    barplot(q)

    MA <- MA.RG(RG.n)
    return(MA)
}

## The script proper starts here.
args <- commandArgs(TRUE)
MA <- processData(args[1], args[2], args[3])
## save(MA, file=args[4])
