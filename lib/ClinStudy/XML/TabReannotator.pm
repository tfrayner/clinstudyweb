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
use Carp;

has 'database'    => ( is       => 'ro',
                       isa      => 'ClinStudy::ORM',
                       required => 1 );

has 'external_id_map' => ( is       => 'rw',
                           isa      => 'HashRef',
                           required => 1,
                           default  => sub { {} }, );

has '_csv_writer' => ( is       => 'rw',
                       isa      => 'Text::CSV_XS',
                       required => 0 );

# Dummy attribute since we're actually not using a schema here. FIXME
# consider reorganising this class inheritance - at the moment we're a
# child of XML::Schema but that now seems inappropriate.
has 'schema' => ( is       => 'rw',
                  isa      => 'Int',
                  required => 1,
                  default  => 1 );

sub BUILD {

    my ( $self, $params ) = @_;

    my $writer = Text::CSV_XS->new({
        sep_char  => "\t",
        eol       => "\n",
    }) or die("Unable to initialise CSV writer.");

    $self->_csv_writer( $writer );

    # Note that this is identical to that in the Loader class. Shared config?
    $self->external_id_map({
        ControlledVocab => 'value',
        Test            => 'name',
        Sample          => 'name',
    });

    return;
}

sub read {

    # Quick wrapper method which just reads in the header row and
    # spits it out in the appropriate column order
    # (i.e. alphabetically sorted).
    my $self = shift;

    my $tabfile = $self->tabfile();
    open (my $fh, '<', $tabfile)
        or die("Unable to open file $tabfile:$!\n");
    
    my $header = $self->_csv_writer->getline($fh);
    unless ( $header && ref $header eq 'ARRAY' ) {
        die("Unable to read file header line.\n");
    }

    # Strip whitespace on either side of each column header.
    $header = [ map { s/ \A \s* (.*?) \s* \z /$1/ixms; $_ } @$header ];

    $self->_csv_writer->print( \*STDOUT, [sort @$header] );

    seek( $fh, 0, 0 ) or die("Unable to rewind input file: $!");

    $self->next::method(@_);
}
                    
sub recursive_cols_to_elements {

    # Here we override the business end of the parent TabReader class.
    my ( $self, $colhash, $tree, $parent, $level, $db_parent ) = @_;

    # Note that $parent, the XML element, is completely unused here.

    $self->_recurse_element_tree( $colhash, $tree, $db_parent, $level );

    # Finally write out a serialised updated $colhash to STDOUT.
    my @values = map { $colhash->{$_} } sort keys %$colhash;
    $self->_csv_writer()->print( \*STDOUT, \@values );

    return;
}

sub _recurse_element_tree {

    my ( $self, $colhash, $tree, $db_parent, $level ) = @_;
    
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

        my $source = $self->database->resultset( $class )->result_source();
        if ( scalar grep { defined $_ } values %attrhash ) {

            # First query the database to find our object.
            my %query_attrs;

            ATTR:
            while ( my ( $colname, $value ) = each %{ \%attrhash } ) {

                next ATTR unless ( defined $value && $value !~ m/\A \s* \z/xms );

                # Extra work needed on *_id columns, e.g. cell_type_id.
                my $relname = $colname . '_id';
                if ( $source->has_relationship( $relname ) ) {
                    $query_attrs{ $relname } =
                        $self->_map_relname_to_obj( $relname, $value, $class, $source );
                }
                else {
                    $query_attrs{ $colname } = $value;
                }
            }
            if ( $db_parent ) {

                # Add in parentage details to the query where
                # available. Note that this currently depends on certain
                # database column naming conventions. FIXME maybe look
                # at generalising this using introspection?
                my $parent_class = $db_parent->result_source->source_name();
                $parent_class =~ s/(?<!^)([A-Z])/_$1/g;
                my $parent_attr  = lc $parent_class . '_id';
                $query_attrs{ $parent_attr } = $db_parent->id();
            }

            my @results = $self->database->resultset( $class )->search( \%query_attrs );

            my $db_object;
            if ( @results == 1 ) {
                $db_object = $results[0];
            }
            elsif ( @results == 0 ) {
                next CLASS;
            }
            else {
                require Data::Dumper;
                die("\nError: $class object too poorly constrained to be uniquely identified: \n\n" .
                        Data::Dumper->Dump( [ \%query_attrs ], [ qw(query) ] ));
            }

            # We need to fill in $colhash here where the values are whitespace-only.
            my %db_col = $db_object->get_columns;
            COLUMN:
            while ( my ( $colname, $value ) = each %db_col ) {

                next COLUMN unless defined $value;

                # Some extra work needed on *_id columns, e.g. nominal_timepoint_id!
                if ( $source->has_relationship( $colname ) ) {
                    ( $colname, $value ) = $self->_map_dbcol_to_value( $colname, $value, $class, $source );
                    next COLUMN unless $colname;
                }

                my $colattr = "$class|$colname";
                if ( exists $colhash->{ $colattr } && $colhash->{ $colattr } =~ m/\A \s* \z/xms ) {
                    $colhash->{ $colattr } = $value;
                }
            }
            
            # Recursion time. This works because the $colhash hashref
            # is being passed down the recursion tree as-is.
            $self->_recurse_element_tree( $colhash, $tree->{ $class }, $db_object, $level );
        }
    }

    return;
}

sub _map_relname_to_obj {

    my ( $self, $relname, $value, $class, $source ) = @_;

    my $nextclass = $source->related_class( $relname );
    $nextclass =~ s/^.*:://;
    my $valcol = $self->external_id_map()->{ $nextclass };
    return unless $valcol;

    my $nextrs = $self->database()->resultset( $nextclass )
        or croak("Error: no ResultSet found for class $nextclass");
    my @nextrows = $nextrs->search({ $valcol => $value });

    if ( @nextrows == 0 ) {
        croak("Error: $class relationship $relname returns no"
                  . " $valcol => $value object from database.");
    }
    elsif ( @nextrows > 1 ) {
        warn("WARNING: Insufficient constraint to uniquely"
                 . " identify $class $relname object ($valcol => $value)\n");
        $value = { 'in' => [ map { $_->id } @nextrows ] };
    }
    else {
        $value = $nextrows[0]->id();
    }

    return $value;
}

sub _map_dbcol_to_value {

    my ( $self, $colname, $value, $class, $source ) = @_;

    my $nextclass = $source->related_class( $colname );
    $nextclass =~ s/^.*:://;

    # We only care about the things in the id_map; skip all other
    # relationships. This behaviour differs slightly from the
    # XML::Export class.
    my $valcol = $self->external_id_map()->{ $nextclass };
    return unless $valcol;

    my $nextrs = $self->database()->resultset( $nextclass )
        or croak("Error: no ResultSet found for class $nextclass");
    my $nextrow = $nextrs->find( $value )
        or croak("Error: $class relationship $colname returns no value from database.");

    $value = $nextrow->get_column($valcol);
    $colname =~ s/_id \z//xms;

    return( $colname, $value );
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

=head1 ATTRIBUTES

Note that XML TabReader attributes are handled by the
C<ClinStudy::XML::TabReader> superclass.

=head2 database

The ClinStudy::ORM object to use for database queries.

=head1 METHODS

=head2 read

Quick wrapper method which just reads in the header row and spits it
out in the appropriate column order (i.e. alphabetically sorted). The
method then hands off control to the read method in the superclass
(see L<ClinStudy::XML::TabReader>).

=head2 recursive_cols_to_elements

Core superclass method overridden here to redirect the code into
building annotation trees for mapping onto tab-delimited file column
names. Not designed for direct use.

=head1 SEE ALSO

L<ClinStudy::XML::Builder>,
L<ClinStudy::XML::TabReader>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

