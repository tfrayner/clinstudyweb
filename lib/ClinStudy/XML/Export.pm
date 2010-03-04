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

package ClinStudy::XML::Export;

use 5.008;

use strict; 
use warnings;

use Moose;

extends 'ClinStudy::XML::Schema';

use XML::LibXML;

use Carp;
use List::Util qw(first);
use Data::Dumper;

our $VERSION = '0.01';

has 'database'   => ( is       => 'ro',
                      isa      => 'DBIx::Class::Schema',
                      required => 1);

has 'root_name'  => ( is       => 'rw',
                      isa      => 'Str',
                      required => 1,
                      default  => 'xml' );

has 'root_attrs' => ( is       => 'rw',
                      isa      => 'HashRef',
                      required => 1,
                      default  => sub{ {} } );

has 'classes'    => ( is         => 'rw',
                      isa        => 'ArrayRef',
                      auto_deref => 1,
                      required   => 1,
                      default    => sub{ [] } );

has 'boundaries' => ( is       => 'rw',
                      isa      => 'HashRef',
                      required => 1,
                      default  =>  sub{ {} }, );

has 'external_value_map' => ( is       => 'rw',
                              isa      => 'HashRef',
                              required => 1,
                              default  => sub { {} }, );

has 'irregular_plurals' => ( is       => 'rw',
                             isa      => 'HashRef',
                             required => 1,
                             default  => sub { {} }, );

has 'is_strict'         => ( is       => 'rw',
                             isa      => 'Bool',
                             required => 1,
                             default  => 1 );

sub _elements_to_doc {

    # This should probably be overridden in a subclass so one can
    # point to a specific XML schema/namespace.
    my ( $self, $elements ) = @_;

    unless ( scalar @$elements ) {
        die("No XML elements created.\n");
    }

    my $doc  = XML::LibXML::Document->new();
    my $root = XML::LibXML::Element->new( $self->root_name() );
    while ( my ($name, $val) = each %{ $self->root_attrs() } ) {
        $root->setAttribute( $name, $val );
    }
    $doc->setDocumentElement($root);

    my %grouping;
    foreach my $elem ( @$elements ) {
        push( @{ $grouping{ $elem->nodeName() } }, $elem );
    }

    $self->_add_elem_groups( $root, \%grouping );

    return $doc;
}

sub xml_all {

    my ( $self ) = @_;

    unless ( scalar $self->classes() ) {
        croak(qq{Error: The "classes" attribute has not been set.});
    }

    my @elements;
    foreach my $class ( $self->classes() ) {
        my $rs = $self->database()->resultset($class)
            or croak("Error: No ResultSet found for class $class.");
        while ( my $row = $rs->next() ) {
            my $elem = $self->row_to_element( $row, $class );
            push( @elements, $elem ) if defined $elem;
        }
    }

    my $doc = $self->_elements_to_doc( \@elements );
    if ( ! $self->validate($doc) && $self->is_strict() ) {
        croak("Error: Generated XML document does not conform to schema.\n");
    }

    return $doc;
}

sub xml {

    # Generic entry point that takes an object and dumps it to
    # XML. Must respect it's own boundaries.
    my ( $self, $objects ) = @_;

    my @elements;
    foreach my $row ( @$objects ) {
        my $topclass = $row->result_source()->source_name();
        my $elem = $self->row_to_element( $row, $topclass );
        push( @elements, $elem ) if defined $elem;
    }

    my $doc = $self->_elements_to_doc( \@elements );
    if ( ! $self->validate($doc) && $self->is_strict() ) {
        croak("Error: Generated XML document does not conform to schema.\n");
    }

    return $doc;
}

sub cols_to_attrs {

    my ( $self, $row, $element ) = @_;

    my $source  = $row->result_source();
    my @pkeys   = $source->primary_columns();

    COLUMN:
    foreach my $col ( $source->columns() ) {

        # Skip primary key columns - they are assumed to be outside
        # the scope of the XML schema.
        next COLUMN if ( first { $col eq $_ } @pkeys );

        my $value = $row->get_column($col);

        # Empty attributes and relationships are ignored; we assume
        # this is for the best.
        next COLUMN unless ( defined $value && $value ne q{} );

        # Skip relationships - these will be added as child elements
        # (or attributes) later.
        next COLUMN if ( $source->has_relationship( $col ) );

        # Simple attributes only.
        $element->setAttribute( $col, $value );
    }

    return;
}

{

    # State variable used to make sure we don't end up in an infinite
    # loop.
    my %TRACKER;

sub row_to_element {

    # This is the recursive workhorse function of the module.
    my ( $self, $row, $topclass, $parent_class ) = @_;

    # NOTE $parent_class may be undefined.

    my $source  = $row->result_source();
    my $class   = $source->source_name();
    my @pkeys   = $source->primary_columns();

    # We need to keep track of those ResultSource:PK
    # combinations we've already exported.
    my $tkey = join('|', map { $row->get_column($_) } @pkeys);
    return if $TRACKER{$class}{$tkey}++;

    # Check we're not on a boundary, in which case we ignore the DB
    # record.
    my $boundaries = $self->boundaries()->{$topclass} || [];
    return if first { $class eq $_ } @$boundaries;

    my $element = XML::LibXML::Element->new($class);

    $self->cols_to_attrs( $row, $element );

    $self->process_relationships( $row, $element, $topclass );

    return $element;
}

sub rel_to_attr {

    # $is_ref has been added for use by more complex subclasses which
    # need to be able to dump XML references. It is assumed that these
    # XML attrs will be named with a _ref suffix.
    my ( $self, $row, $col, $element, $is_ref ) = @_;

    my $source  = $row->result_source();
    my $class   = $source->source_name();
    my $nextclass = $source->related_class( $col );
    $nextclass =~ s/^.*:://;

    my $value = $row->get_column($col);

    # Empty attributes and relationships are ignored; we assume
    # this is for the best.
    return unless ( defined $value && $value ne q{} );
    
    my $nextrs = $self->database()->resultset( $nextclass )
        or croak("Error: no ResultSet found for class $nextclass");
    my $nextrow = $nextrs->find( $row->get_column($col) )
        or croak("Error: $class relationship $col returns no value from database.");

    # Check we're not covering old ground.
    my @pkeys  = $nextrow->result_source()->primary_columns();
    my $tkey = join('|', map { $nextrow->get_column($_) } @pkeys);
    return if $TRACKER{$nextclass}{$tkey};

    my $attrname = $col;
            
    # We assume we want to remove _id from the column name
    # to get the attr name.
    if ( $is_ref ) {
        $attrname =~ s/_id \z/_ref/xms;
    }
    else {
        $attrname =~ s/_id \z//xms;
    }
    my $valcol = $self->external_value_map()->{ $nextclass }
        or croak("Error: Unable to determine value column for $nextclass class.");
    $element->setAttribute( $attrname, $nextrow->get_column($valcol) );

    return;
}

}

sub process_relationships {

    my ( $self, $row, $element, $topclass ) = @_;

    my $source  = $row->result_source();
    my $class   = $source->source_name();

    my %related_elem;
    RELATIONSHIP:
    foreach my $col ( $source->relationships() ) {

        # Primary keys may form part of a relationship, so we don't
        # skip them here.

        # We assume singles/filters should be attrs, with
        # only multis added as child elems.
        my $reltype = $source->relationship_info($col)->{attrs}{accessor}
            or croak("Error: Unable to retrieve relationship info for $class column $col.");

        if ( $reltype eq 'multi' ) {
            foreach my $nextrow ( $row->search_related( $col ) ) {
                my $nextelem  = $self->row_to_element( $nextrow, $topclass, $class );
                my $nextclass = $nextelem ? $nextelem->nodeName() : undef;
                push( @{ $related_elem{$nextclass} }, $nextelem ) if defined $nextelem;
            }
        }
        else {
            $self->rel_to_attr($row, $col, $element);
        }
    }

    $self->_add_elem_groups( $element, \%related_elem, $class );

    return;
}

sub _add_elem_groups {

    my ( $self, $element, $related_elem, $parent_class ) = @_;

    # NOTE: $parent_class may be undefined.

    # Add all related elements in alphabetical order (this is another
    # assumption).
    foreach my $childclass ( sort keys %$related_elem ) {
        my @children = @{ $related_elem->{$childclass} };
        if ( scalar @children ) {
            my $groupname = $self->element_group( $childclass, $parent_class );
            my $group = XML::LibXML::Element->new( $groupname );
            $element->addChild($group);
            foreach my $child ( @children ) {
                $group->addChild($child);
            }
        }
    }

    return;
}

sub element_group {

    my ( $self, $class, $parent_class ) = @_;

    my $group;
    unless ( $group = $self->irregular_plurals()->{$class} ) {
        $group = $class . 's';
    }

    return $group;
}

1;
__END__

=head1 NAME

ClinStudy::XML::Export - XML export from ClinStudyDB databases.

=head1 SYNOPSIS

 use ClinStudy::XML::Export;
 my $dump = ClinStudy::XML::Export->new(
     database => $db_schema,
 );

 # Export a list of DBIx::Class::Row objects.
 my $doc  = $dump->xml(\@patients);
 
 # Export all data.
 my $full = $dump->xml_all();

=head1 DESCRIPTION

Generic module handling the generation of XML from a database
satisfying several assumptions (FIXME list them).

=head2 ATTRIBUTES

=over 2

=item database

A DBIx::Class::Schema instance storing the data to be dumped to XML.

=item boundaries

A hashref of arrayrefs which gives the level of the database schema
heirarchy at which to stop export for a given resultset class. This
data structure should be in the following form:

 %boundaries = (
     top-level resultset class => [ list of bottom-level resultset classes ],
 );

The output XML heirarchy will not contain any records from the
bottom-level boundary class.

=item external_value_map

See ClinStudy::XML::Loader for discussion of this attribute.

=item irregular_plurals

All table-derived elements are enclosed within grouping elements. This
hashref gives the group name in cases where it's not as simple as
adding 's' onto the end of the table class name.

=item is_strict

Boolean flag indicating whether or not to validate the exported XML
document against the XML Schema (default=True).

=back

=head1 SEE ALSO

ClinStudy::XML::Schema, ClinStudy::XML::Loader

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

