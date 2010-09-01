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

package ClinStudy::XML::TabReannotator;

use ClinStudy::XML::TabReader;
use Moose;
extends 'ClinStudy::XML::TabReader';

use Text::CSV_XS;

has 'database'    => ( is       => 'ro',
                       isa      => 'ClinStudy::ORM',
                       required => 1 );

has '_csv_writer' => ( is       => 'rw',
                       isa      => 'Text::CSV_XS',
                       required => 0 );

sub BUILD {

    my ( $self, $params ) = @_;

    my $writer = Text::CSV_XS->new({
        sep_char  => "\t",
        eol       => "\n",
    }) or die("Unable to initialise CSV writer.");

    $self->_csv_writer( $writer );

    return;
}
                    
sub _process_columns {

    # Here we override the business end of the parent TabReader class.
    my ( $self, $colhash, $tree, $parent, $level, $db_parent ) = @_;

    # Note that $parent, the XML element, is completely unused here.

    # Try to do this safely.
    unless ( $level++ < 100 ) {
	die("Error: deep recursion in column processing.");
    }

    CLASS:
    foreach my $class ( keys %$tree ) {

        # Aggregate class attributes into a single hash, then find or
        # create it.
        my %attrhash;
        while ( my ( $key, $value ) = each %$colhash ) {
	    my ( $col_class, $attrname ) = split /\|/, $key;
            if ( $col_class && $col_class eq $class ) {

                # Record that we've at least considered this column.
                $self->_used()->{ $key }++;

                # Add the value to the element attribute hash.
                if ( defined $value ) {
                    $attrhash{ $attrname } = $value;
                }
            }
	}

        if ( scalar grep { defined $_ } values %attrhash ) {

            # First query the database to find our object.
            my %query_attrs = %{ \%attrhash };
            if ( $db_parent ) {

                # Add in parentage details to the query where
                # available. Note that this currently depends on certain
                # database column naming conventions. FIXME maybe look
                # at generalising this using introspection?
                my $parent_class = $db_parent->result_source->source_name();
                my $parent_attr  = lc $parent_class . '_id';
                $query_attrs{ $parent_attr } = $db_parent->id();
            }

            # FIXME again, extra work needed on *_id columns, e.g. cell_type_id.

            my $db_object = $self->database->resultset( $class )->find( \%query_attrs );

            next CLASS unless $db_object;

            # We need to fill in $colhash here where the values eq q{}.
            my %db_col = $db_object->get_columns;
            while ( my ( $colname, $value ) = each %db_col ) {

                # FIXME some extra work needed on *_id columns, e.g. nominal_timepoint_id!

                my $colattr = "$class|$colname";
                if ( exists $colhash->{ $colattr } && $colhash->{ $colattr } eq q{} ) {
                    $colhash->{ $colattr } = $value;
                }
            }
            
            # Recursion time. This works because the $colhash hashref
            # is being passed down the recursion tree as-is.
            $self->_process_columns( $colhash, $tree->{ $class }, undef, $level, $db_object );
        }
    }

    # Finally write out a serialised updated $colhash to STDOUT.
    my @values = map { $colhash->{$_} } sort keys %$colhash;
    $self->_csv_writer()->print( \*STDOUT, \@values );

    return;
}

1;

__END__

=head1 NAME

ClinStudy::XML::TabReannotator - Reannotation of tab-delimited files.

=head1 SYNOPSIS

 use ClinStudy::XML::TabReannotator;
 my $builder = ClinStudy::XML::TabReannotator->new({
     tabfile => 'filename.txt',
 });
 my $root    = $builder->root();

 # Writes to STDOUT.
 $builder->read();

=head1 DESCRIPTION

A module used to connect to a ClinStudy database and pull out missing
attributes to fill in a partially completed tab-delimited data file.

=head2 ATTRIBUTES

Note that XML TabReader attributes are handled by the
C<ClinStudy::XML::TabReader> superclass.

=over 2

=item database

The ClinStudy::ORM object to use for database queries.

=back

=head2 METHODS

=over 2

=back

=head2 SEE ALSO

L<ClinStudy::XML::Builder>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

