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

calculateCellPurities <- function(uri, .opts=list(), cred) {

    require('RCurl')

    .retrieveFileInfo <- function(sample_id, type, uri, .opts, cred) {
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

        return(file$filename) ## FIXME better to allow file download uri here. ORM fix?
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

        ## FIXME download both files to a temporary location.

        ## FIXME Attempt cell purity calculation.
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
