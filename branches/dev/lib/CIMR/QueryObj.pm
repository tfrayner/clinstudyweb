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

=head1 NAME

CIMR::QueryObj - Generic query base class (DEPRECATED)

=head1 SYNOPSIS

 use CIMR::QueryObj;

=head1 DESCRIPTION

Abstract base class supporting some kind of generic query structure on
tab-delimited files and other data sources. Note that this effectively
reinvents the DBD::CSV module (and badly) so it's probably of
questionable use. This is for local CIMR use only; ultimately we will
want to phase this out entirely.

=head1 ATTRIBUTES

=head2 id_field

The name of the ID field in the underlying data store to use in queries.

=head2 queryterms

A list of valid term names available to query.

=head1 METHODS

=head2 query

Given an identifier and a desired set of terms, return the values for
those terms from the underlying data store.

=head1 SEE ALSO

L<CIMR::DataPipeline>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

