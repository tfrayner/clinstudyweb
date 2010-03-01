#!/usr/bin/env perl
#
# Copyright 2010 Tim Rayner, University of Cambridge
# 
# This file is part of ClinStudy::Web.
# 
# ClinStudy::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# ClinStudy::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$
#
# Module supporting some kind of generic query structure on
# tab-delimited files. Note that this effectively reinvents the
# DBD::CSV module (and badly) so it's probably of questionable use.

use strict;
use warnings;

package CIMR::QueryObj;

use Moose;
use Carp;

has 'id_field' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has '_cache' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
    default  => sub { {} },
);

has 'queryterms' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    auto_deref => 1,
);

sub query {

    my ( $self, $id, @terms ) = @_;

    my $cache = $self->_cache();
    if ( my $annot = $cache->{ $id } ) {
        my @results = map { $annot->{ $_ }{ 'used'  }++;
                            $annot->{ $_ }{ 'value' } } @terms;
        return @results;
    }
    else {
        warn(qq{Warning: ID "$id" not found in cache.\n});
    }

    return;
}

1;
