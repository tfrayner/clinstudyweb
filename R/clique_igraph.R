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

## Experimental code to identify cliques in an igraph object based on
## uniformity of specified vertex attributes.

igraphCliques <- function(g, medians='mediansFL4H_clust', cvs='cvsFL4H_clust', ...) {

    require(igraph) ## 0.6 or newer; vertex and edge number starting at 1, not 0.

    ## In the folloiwing functions we add a fudge factor to avoid
    ## division by zero. This is pretty easily justified: clusters
    ## with zero variance will really only be those containing a
    ## single cell, in which case we're not actually concerned with
    ## them. The fudge factor will tend to keep such clusters out of
    ## the developing cliques.
    weightedMean <- function(m, sd) {
        sd <- sd + 1e-10
        sum( m / (sd^2) ) / sum( 1 / (sd^2) )
    }

    weightedSD <- function(sd) {
        sd <- sd + 1e-10
        sqrt( 1 / sum( 1 / (sd^2) ) )
    }

    M <- get.vertex.attribute(g, medians)
    C <- get.vertex.attribute(g, cvs)
    SD <- M*C

    ## tolerance here is a fudge factor: how many SDs from the clique
    ## mean do we accept when linking in new nodes? 3 seems to work
    ## pretty well for now.
    nodesLinked <- function(i1, i2, bins, tolerance=3) {  # Indices i1, i2 are 1..n, not 0..n
        
        ## Build an ongoing per-clique mean and sd to compare against.
        w  <- bins == bins[i1]
        m1 <- weightedMean( M[w], SD[w] )
        sd1 <- weightedSD( SD[w] )

        w  <- bins == bins[i2]
        m2 <- weightedMean( M[w], SD[w] )
        sd2 <- weightedSD( SD[w] )

        return( abs( m1-m2 ) < tolerance * min(sd1, sd2) )
    }

    ## Determine the order in which we will inspect edges (that with
    ## vertices closest by median value first).
    edgeOrder <- order(unlist(lapply(1:ecount(g),
                                     function(n) { x <- M[ V(g)[ adj(E(g)[ n ]) ] ]
                                                   return(abs(x[1] - x[2])) })))

    bins <- 1:vcount(g)
    for ( n in edgeOrder ) {

        ## Build the cliques out from the centre as defined by the
        ## most tightly-linked vertices. For each vertex just test the
        ## closest neighboring vertex not yet incorporated into a clique.
        x <- as.vector(V(g)[ adj(E(g)[ n ]) ])
        if ( bins[ x[1] ] == bins[ x[2] ] )
            next  ## Already in the same clique

        if ( nodesLinked( x[1], x[2], bins, ... ) ) {

            ## merge cliques
            bins[ bins == bins[ x[2] ] ] <- bins[ x[1] ]
        }
    }

    ## Return a listing of bins in which 1 has the most vertices, then
    ## 2 and so on.
    return(as.numeric(factor(bins, levels=names(rev(sort(table(bins)))))))
}
