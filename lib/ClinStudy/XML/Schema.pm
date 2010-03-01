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

package ClinStudy::XML::Schema;

use 5.008;

use strict; 
use warnings;

use Carp;

use Data::Dumper;

our $VERSION = '0.01';

use Moose;
use XML::LibXML;

has 'schema_file' => ( is  => 'ro',
                       isa => 'Str' );

has 'schema' => ( is      => 'rw',
                  isa     => 'XML::LibXML::Schema', );

sub BUILD {

    my ( $self, $params ) = @_;

    if ( my $f = $params->{schema_file} ) {
        my $sch = XML::LibXML::Schema->new(
            location => $f,
        );
        $self->schema( $sch );
    }

    unless ( $self->schema() ) {
        die("Must provide either schema or schema_file attribute.");
    }

    return;
}

sub validate {

    my ( $self, $doc ) = @_;

    UNIVERSAL::isa( $doc, 'XML::LibXML::Document' )
        or croak("Error: Incorrect XML document type passed to validate method.");

    # Simple eval wrapper method.
    my $rc;
    eval {
        $rc = $self->schema()->validate( $doc );
    };
    if ( $@ ) {
        warn $@;
        $rc = 1;
    }

    return ! $rc;
}

1;

__END__

=head1 NAME

ClinStudy::XML::Schema - Class for validating XML against a schema

=head1 SYNOPSIS

 use ClinStudy::XML::Schema;
 my $loader = ClinStudy::XML::Schema->new(
     schema_file => 'my_schema.xsd',
 );
 $loader->validate($doc) or die("Incorrect XML");

=head1 DESCRIPTION

This class is a generic validator module for XML which checks that it
conforms to a given schema.

=head2 ATTRIBUTES

=over 2

=item schema_file

The XML Schema file against which to check the XML instance
document. Either this, or the C<schema> attribute is required.

=item schema

An instance of the XML::LibXML::Schema class, pointing to the XML
Schema to use for validation. Either this, or the C<schema_file>
attribute is required.

=back

=head2 METHODS

=over 2

=item validate

Validate the supplied XML::LibXML::Document object against the stored
schema. Returns true on success, false otherwise.

=back

=head2 EXPORT

None by default.

=head1 SEE ALSO

ClinStudy::XML::Import
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

