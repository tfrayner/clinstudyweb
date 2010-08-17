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

package ClinStudy::XML::Import;

use 5.008;

use strict; 
use warnings;

use Carp;

use Data::Dumper;

our $VERSION = '0.01';

use Moose;

extends 'ClinStudy::XML::Schema';

use XML::LibXML;
use Storable qw(dclone);

has 'database' => ( is    => 'ro',
                    isa   => 'DBIx::Class::Schema', );

has 'load_order' => ( is        => 'rw',
                      isa       => 'ArrayRef',
                      predicate => 'has_load_order', );

has 'external_id_map' => ( is       => 'rw',
                           isa      => 'HashRef',
                           required => 1,
                           default  => sub { {} }, );

has 'external_value_map' => ( is       => 'rw',
                              isa      => 'HashRef',
                              required => 1,
                              default  => sub { {} }, );

has 'onload_callback'   => ( is        => 'rw',
                             isa       => 'CodeRef',
                             required  => 0 );

has 'is_strict'         => ( is       => 'rw',
                             isa      => 'Bool',
                             required => 1,
                             default  => 1 );

sub load {

    my ( $self, $doc ) = @_;

    UNIVERSAL::isa( $doc, 'XML::LibXML::Document' )
        or croak("Error: Incorrect XML document type passed to load method.");

    # We always check this before loading, just in case.
    if ( ! $self->validate( $doc ) && $self->is_strict() ) {
        croak("Error: XML document does not comply with the supplied XML Schema.\n");
    }

    unless ( defined $self->database() ) {
        croak("Error: Database loading requires the database attribute to be set.\n"); 
    }

    my $root = $doc->getDocumentElement();

    # Link into the class config to allow loading of groups in a
    # defined order. This will be useful in schema-specific subclasses.
    my @groups;
    if ( $self->has_load_order() ) {
        foreach my $tag ( @{ $self->load_order() } ) {
            push @groups, $root->getChildrenByTagName($tag);
        }
    }
    else {
        @groups = $root->getChildrenByTagName('*');
    }

    # Actually do the loading.
    foreach my $group ( @groups ) {
        $self->_load_group_element( $group );
    }

    return;
}

sub _load_group_element {

    my ( $self, $element, $parent_ref ) = @_;

    foreach my $child ( $element->getChildrenByTagName('*') ) {
        $self->_load_clindb_element( $child, $parent_ref );
    }

    return;
}

sub process_attr {

    my ( $self, $attr, $parent_ref ) = @_;

    my $class = $attr->getOwnerElement()->nodeName();
    my $rs = $self->database()->resultset($class)
        or die("Error: Unable to find a ResultSet for $class elements.");
    my $source = $rs->result_source();

    my $attr_name = $attr->nodeName();
    if ( $source->has_column($attr_name) ) { 
        $parent_ref->{ $attr_name } = $attr->getValue();
    }
    elsif ( $source->has_column($attr_name . '_id') ) {
        $attr_name .= '_id';
        if ( my $related = $source->related_class($attr_name) ) {
            $related =~ s/.*:://;
            my $rel_obj = $self->_load_related( $related,
                                                $attr->getValue(),
                                                $class,
                                                $attr_name );
            
            # FIXME derive the PK field name by introspection.
            $parent_ref->{ $attr_name } = $rel_obj->id();
        }
        else {
            confess("Error: $class $attr_name attribute is not part of a relationship.");
        }
    }
    elsif ( $attr_name =~ /_ref \z/xms ) {

        # We also need to be able to handle references (e.g. Channel to Sample).
        $attr_name =~ s/_ref \z/_id/xms;
        if ( $source->has_column($attr_name) ) {
            if ( my $related = $source->related_class( $attr_name ) ) {
                $related =~ s/.*:://;
                my $rel_obj  = $self->_find_reference( $related,
                                                       $attr->getValue() );
                
                # FIXME derive the PK field name by introspection.
                $parent_ref->{ $attr_name } = $rel_obj->id();
            }
            else {
                confess("Error: $class reference to $attr_name is not part of a relationship.");
            }
        }
        else {
            confess("Error: $class references unknown relationship $attr_name.");
        }
    }
    else {
        confess("Error: Unknown attribute $attr_name for class $class.");
    }

    return( $parent_ref );
}

sub load_element {

    # Core database loading method; can be overridden in subclasses
    # for special cases. Takes an XML::LibXML::Element object and a
    # hashref { parent_relationship_id => database_parent_id } and
    # returns a new object which has been loaded into the database.

    my ( $self, $element, $parent_ref ) = @_;

    $parent_ref ||= {};

    my $class = $element->nodeName();
    my $rs = $self->database()->resultset($class)
        or die("Error: Unable to find a ResultSet for $class elements.");

    # Clone the parent_ref, otherwise we get carry-over of attributes
    # between elements.
    my $row_ref = dclone( $parent_ref );

    # Create an object based on the element attributes, pass it
    # into the recursion as lc($class) . '_id' so we can link up our children.
    foreach my $attr ( $element->attributes() ) {
        next unless $attr->isa('XML::LibXML::Attr');

        # If the nodeName is related to a relationship name in the
        # ResultSet, create the child object automatically (this will
        # mainly be Test and ControlledVocab).
        $self->process_attr( $attr, $row_ref );
    }

    my $obj = $self->load_object( $row_ref, $rs );

    return $obj;
}

sub _load_clindb_element {

    my ( $self, $element, $parent_ref ) = @_;

    my $obj = $self->load_element( $element, $parent_ref );
    
    # Recurse down breadth-first into the structure.
    foreach my $child_group ( $element->getChildrenByTagName('*') ) {

        # Camelcase to underscore-delim.
        my $relname = $element->nodeName();
        $relname =~ s/(?<=.)([A-Z])/_$1/g;

        # FIXME derive the PK field name by introspection.
        my $new_ref = { lc($relname) . '_id' => $obj->id() };

        $self->_load_group_element( $child_group, $new_ref );
    }

    return;
}

sub _load_related {

    my ( $self, $class, $value, $parent, $relationship ) = @_;

    my $rs = $self->database()->resultset($class)
        or die("Error: Unable to find a ResultSet for $class elements.");

    # Update or create the related object using the configured id column.
    my $rel_obj;
    if ( my $field = $self->external_id_map()->{ $class } ) {
        my %attr = ( $field => $value );

        # Load any extra default field values as specified in the class config.
        if ( my $class_extra = $self->external_value_map()->{$class} ) {
            foreach my $extra ( keys %{ $class_extra } ) {
                if ( my $val = $class_extra->{$extra}{$parent}{$relationship} ) {
                    $attr{$extra} = $val;
                }
                else {
                    croak("Unable to find default value for $class $extra"
                        . " linked from $parent via $relationship.\n");
                }
            }
        }
        $rel_obj = $self->load_object( \%attr, $rs );
    }
    else {
        croak("Unrecognised class $class in _load_related().");
    }

    return($rel_obj);
}

sub _find_reference {

    my ( $self, $class, $value ) = @_;

    my $rs = $self->database()->resultset($class)
        or die("Error: Unable to find a ResultSet for $class elements.");

    # FIXME it'd be nice to be able to take these external_id_map
    # values from the XML Schema doc, where they're defined. It's
    # related to the _load_related external_id_map config options
    # though (and which are not in the Schema), so merging with them
    # makes some sense (and then doesn't require a definition in the
    # XML schema, which might actually be a feature).

    # Attempt to retrieve the referenced object using the configured id column.
    my $rel_obj;
    if ( my $field = $self->external_id_map()->{$class} ) {
        my @rel_objs = $rs->search({ $field => $value });
        unless ( scalar @rel_objs ) {
            croak("Unable to find a $class with $field = $value.");
        }
        $rel_obj = $rel_objs[0];
    }
    else {
        croak("Unrecognised class $class in _find_reference().");
    }

    return($rel_obj);
}

sub load_object {

    # Method used to load all objects into the database. This is split
    # out like this so we can easily subclass and override the loading
    # behaviour, e.g. for ControlledVocab.
    my ( $self, $hashref, $rs ) = @_;

    if ( my $callback = $self->onload_callback() ) {
        $hashref = $callback->( $rs->result_class, $hashref );
    }
    
    my $obj;
    $self->database->txn_do(
        sub { $obj = $rs->update_or_create( $hashref ); }
    );

    return $obj;
}

1;

__END__

=head1 NAME

ClinStudy::XML::Import - Class for validating and loading XML into a
database

=head1 SYNOPSIS

 use ClinStudy::XML::Import;
 my $loader = ClinStudy::XML::Import->new(
     schema_file => 'my_schema.xsd',
     database    => $db_schema,
 );
 $loader->validate($doc) or die("Incorrect XML");
 $loader->load($doc);

=head1 DESCRIPTION

This class is a fairly generic validator/loader module for XML which
conforms to a given schema. The implementation of the class assumes
that the XML schema follows the target database schema very
closely. Mechanisms are provided to allow the automatic population of
database fields which are referenced, but incompletely specified, in
the XML schema.

The assumptions made about the concordance between XML and database
schemata are as follows:

1. Database table names are converted from underscore_delim to
CamelCase (this is the way DBIx::Class generally names its ResultSet
classes). Database tables are represented as elements, and column
values are represented as attributes of those elements. Attribute
names are generally the same as their respective column names, with a
couple of exceptions (see below).

2. XML fields can link to entire database rows in tables not covered
by the XML schema. This allows a local implementation to add
constraints which aren't deemed necessary as part of the XML
schema. For example, values in the XML document may reference terms in
a controlled value table in the database. In such cases, the database
column name is assumed to be in the form "target_id" and the XML field
would simply be "target". See the L<external_id_map> and
L<external_value_map> class attributes for information on how to
configure a subclass appropriately.

3. References within the XML document are supported; it is assumed
that the XML field will be of the form "target_ref" and the respective
database column will be "target_id". See L<external_id_map> for notes
on how to specify which database field identifies a given referent
row. Note that the load order may need to be specified to ensure that
the referent objects are available for retrieval. See the
L<load_order> attribute for a way to do this.

4. At the moment, the primary key fields are all assumed to be
"id". This will probably be fixed in a future version (FIXME).

=head2 ATTRIBUTES

See L<ClinStudy::XML::Schema> for attributes defined in this
superclass.

=over 2

=item database

A DBIx::Class::Schema object to be used for loading data into a
database. Not required for validation against the XML schema.

=item load_order

An optional array ref indicating the load order for top-level group
elements in the XML document. If this is used, then all elements to be
loaded must be included. This is not needed if there is only one
top-level group, or if object load order does not matter.

=item external_id_map

An optional hash ref indicating how fields in the XML document which
refer to whole database table rows should resolve those rows in an SQL
query. The hash keys are DBIx::Class::ResultSet names, and the values
are the (single) fields which confer identity on the rows in that
resultset. Defaults to an empty hash ref.

=item external_value_map

An optional hash ref providing extra values which may be required for
instantiation of database records external to the XML Schema. The
nested hash structure is illustrated below:

 ExternalResultSet => {
     external_column => {
         ParentResultSet => {
             relationship_column => 'desired value',
         }
     }
 }

For example:

 ControlledVocab => {
     category => {
         PriorTreatment => {
             type_id              => 'TreatmentType',
             nominal_timepoint_id => 'PriorTimepoint' ,
             duration_unit_id     => 'TimeUnit',
         }
     },
 },

The levels of this hash ref could of course be arranged in several
other ways; this order was chosen since it was the most succinct
arrangement for the original use case. Defaults to an empty hash
ref.

=item is_strict

Boolean flag indicating whether or not to validate the imported XML
document against the XML Schema (default=True).

=item onload_callback

(Experts only) An optional coderef which is called just prior to
loading the element into the database. The coderef is passed the class
name for the database object to be created, and a hashref of
attributes. This callback allows you to edit that hashref and return
it back to the import module just before the object is inserted into
the database.

=back

=head2 METHODS

See L<ClinStudy::XML::Schema> for methods defined in this
superclass.

=over 2

=item load

Load the supplied XML::LibXML::Document object into a ClinStudy::ORM
database instance. This process includes a validation step, so any
prior calls to C<validate> can be omitted.

=back

=head2 EXPORT

None by default.

=head1 SEE ALSO

ClinStudy::XML::Schema
ClinStudy::XML::Loader
XML::LibXML
XML::Schema

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

