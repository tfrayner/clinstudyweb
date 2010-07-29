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

package ClinStudy::XML::AdminLoader;

use 5.008;

use strict; 
use warnings;

use Carp;
use Storable qw(dclone);
use Moose;
extends 'ClinStudy::XML::Import';

our $VERSION = '0.01';

sub BUILD {

    my ( $self, $params ) = @_;

    # Set up our subclass config here.
    $self->load_order( [ qw( ControlledVocabs Tests Users ) ] );

    $self->external_id_map( { Role            => 'rolename',
                              ControlledVocab => 'accession' } );

    return;
}

sub load_element {

    my ( $self, $element, $parent_ref ) = @_;

    my $obj;
    if ( $element->nodeName eq 'TestPossibleValue' ) {
        my $row_ref = dclone($parent_ref);
        my $cv = $self->database->resultset('ControlledVocab')->find({
            category => $element->getAttribute('category'),
            value    => $element->getAttribute('value'),
        }) or die("Error: TestPossibleValue attempting to load its own CVs - naughty!");
        $row_ref->{possible_value_id} = $cv->id;
        $obj = $self->database->resultset('TestPossibleValue')->find_or_create($row_ref);
    }
    else {
        $obj = $self->SUPER::load_element( $element, $parent_ref );
    }

    return $obj;
}

1;

__END__

=head1 NAME

ClinStudy::XML::AdminLoader - Import user metadata into a ClinStudy database.

=head1 SYNOPSIS

 use ClinStudy::XML::AdminLoader;
 my $loader = ClinStudy::XML::AdminLoader->new(
     schema_file => 'my_schema.xsd',
     database    => $db_schema,
 );
 $loader->validate($doc) or die("Incorrect XML");
 $loader->load($doc);

=head1 DESCRIPTION

A module designed to handle validation of XML according to the
ClinStudyAdmin schema, and loading of such XML into a database. This is a
database-specific subclass of the ClinStudy::XML::Import class.

=head1 SEE ALSO

ClinStudy::XML::Import
ClinStudy::XML::Schema
ClinStudy::XML::Infopath

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut
