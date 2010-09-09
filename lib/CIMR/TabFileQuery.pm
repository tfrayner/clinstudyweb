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

package CIMR::TabFileQuery;

use Moose;
use Text::CSV_XS;
use Carp;

BEGIN { extends 'CIMR::QueryObj' };

has 'fh' => (
    is       => 'ro',
    isa      => 'FileHandle',
    required => 1,
);

has '_parser' => (
    is       => 'ro',
    isa      => 'Text::CSV_XS',
    required => 1,
    default  => sub { Text::CSV_XS->new({
        eol              => qq{\n},
        sep_char         => qq{\t},
        blank_is_undef   => 1,
        quote_char       => qq{"},
        escape_char      => qq{"},
        binary           => 1,
    }) },
);

sub BUILD {

    my ( $self, $params ) = @_;

    # Build a hashref-based cache for queries.
    my @terms = $self->queryterms();
    my $csv   = $self->_parser();
    my $fh    = $self->fh();
    my $harry = $csv->getline( $fh ) or croak("Error: No header line!\n");

    # Check our query terms for presence in the header.
    my %headercheck = map { $_ => 1 } @$harry;
    foreach my $term ( @terms ) {
        unless ( $headercheck{ $term } ) {
            croak(qq{Error: Term name "$term" not found in file header.\n});
        }
    }

    # Actually build the cache hashref.
    my %cache;
    while ( my $larry = $csv->getline( $fh ) ) {
        my %row;
        @row{ @$harry } = @$larry;
        my $id = $row{ $self->id_field() };
        unless ( defined $id && $id ne q{} ) {
            croak(sprintf(qq{Error: Input file lacks a proper ID in column "%s".\n},
                          $self->id_field() ) );
        }
        foreach my $term ( @terms ) {
            my $value = $row{ $term };
            if ( defined $value && $value ne q{} ) {

                # value is the actual value; used is a counter for term query usage.
                $cache{ $id }{ $term }{ 'value' } = $value;
                $cache{ $id }{ $term }{ 'used'  } = 0;
            }
        }
    }

    # Check we've parsed to the end of the file.
    my ( $error, $mess ) = $csv->error_diag();
    unless ( $error == 2012 ) {    # 2012 is the Text::CSV_XS EOF code.
	croak(sprintf("Error in tab-delimited format: %s. Bad input was:\n\n%s\n",
                      $mess,
                      $csv->error_input(), ),
          );
    }

    $self->_cache( \%cache );
}

sub report_unused {

    my ( $self ) = @_;

    my $cache = $self->_cache();

    while (my ( $id, $annot ) = each %{ $cache } ) {
        unless ( scalar grep { $_ > 0 } map { $_->{ 'used' } } values %$annot ) {
            print("ID not used: $id\n");
        }
    }

    return;
}

1;

=head1 NAME

CIMR::TabFileQuery - CIMR::QueryObj class handling tab-delimited data files (DEPRECATED).

=head1 SYNOPSIS

 use CIMR::TabFileQuery;
 my $qobj = CIMR::TabFileQuery->new(
     fh         => $fh,
     queryterms => \@queryterms,
     id_field   => $id_field,
 );
 my @values = $qobj->query( $id, @queryterms );

=head1 DESCRIPTION

This is a simple module which could easily have been substituted by
DBD::CSV, and as a result is not intended for further use. It is a
subclass of CIMR::QueryObj and is intended to support the same
usage. See L<CIMR::QueryObj> for more information on the API.

=head1 ATTRIBUTES

=head2 fh

The filehandle used to access the tab-delimited file of interest.

=head1 METHODS

=head2 report_unused

Reports those IDs from the data file which have not yet been returned
by a query.

=head1 SEE ALSO

L<CIMR::QueryObj>

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

