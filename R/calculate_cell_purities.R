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

calculateCellPurities <- function(uri) {

    ## FIXME connect to the clinical database; pull down a list of
    ## samples lacking cell purities but having the files required to
    ## attempt a calculation.

    ## Attempt said calculation.
    
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
