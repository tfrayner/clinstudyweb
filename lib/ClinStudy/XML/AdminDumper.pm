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

package ClinStudy::XML::AdminDumper;

use 5.008;

use strict; 
use warnings;

use Moose;

extends 'ClinStudy::XML::Export';

use Carp;

our $VERSION = '0.01';

sub BUILD {

    my ( $self, $params ) = @_;

    $self->root_name('ClinStudyAdminML');
    $self->root_attrs({
        'xmlns:xsi'                     => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:noNamespaceSchemaLocation' => 'clindb_admin.xsd',
    });

    $self->classes([qw( ControlledVocab TermSource Test User )]);

    $self->external_id_map({
        'Role'            => 'rolename',
        'ControlledVocab' => 'value',
        'TermSource'      => 'name',
    });

    $self->boundaries({
        ControlledVocab => [ qw(AssayBatch AdverseEvent Channel ClinicalFeature Diagnosis
                                DiseaseEvent Drug EmergentGroup Patient PriorGroup PriorObservation
                                PriorTreatment RiskFactor Sample Study SystemInvolvement
                                TestPossibleValue TestResult Transplant Visit) ],
        TermSource => [ qw(ControlledVocab) ],
        Test => [ qw(TestResult) ],
    });

#    $self->irregular_plurals({
#    });

    return;
}

sub row_to_element {

    my ( $self, $row, $topclass, $parent_class, $parent_row ) = @_;

    # NOTE $parent_class and/or $parent_row may be undefined.
    
    my $source  = $row->result_source();
    my $class   = $source->source_name();

    if ( $class eq 'User' ) {
        warn(sprintf("Dumping data for user %s...\n", $row->username()));
    }

    my $element;
    if ( $class eq 'TestPossibleValue' && $parent_class eq 'Test' ) {
        $element = XML::LibXML::Element->new($class);
        $element->setAttribute('category', $row->possible_value_id->category());
        $element->setAttribute('value', $row->possible_value_id->value());
    }
    elsif ( $class eq 'RelatedVocab' ) {
        my $rel_acc = $row->relationship_id->accession();
        my $tar_acc = $row->target_id->accession();
        my $parent_acc = $parent_row ? $parent_row->accession() : undef;
        if ( $rel_acc ne $parent_acc && $tar_acc ne $parent_acc ) {
            $element = XML::LibXML::Element->new($class);
            $element->setAttribute('target_ref', $tar_acc);
            $element->setAttribute('relationship_ref', $rel_acc);
        }
    }
    else {

        # General case.
        $element = $self->next::method( $row, $topclass, $parent_class, $parent_row );
    }

    return $element;
}

sub rel_to_attr {

    # The generic superclass doesn't know about reference elements in
    # the XML (it would have to parse the schema doc to detect these,
    # and it's not smart enough yet to do that). We tell it which
    # relationships should be treated as references here.
    my ( $self, $row, $col, $element ) = @_;

    my $source  = $row->result_source();
    my $class   = $source->source_name();
    my $nextclass = $source->related_class( $col );
    $nextclass =~ s/^.*:://;

    # Only TermSource is used as a reference for now.
    if ( $nextclass eq 'TermSource' ) {

        # Generate the attribute as a reference within the XML doc.
        $self->next::method( $row, $col, $element, 1 );
    }
    else {

        # Regular attribute.
        $self->next::method( $row, $col, $element );
    }

    return;
}

1;
__END__

=head1 NAME

ClinStudy::XML::AdminDumper - Export of user/role data from ClinStudyDB databases.

=head1 SYNOPSIS

 use ClinStudy::XML::AdminDumper;
 my $dump = ClinStudy::XML::AdminDumper->new(
     database => $db_schema,
 );

 # Export all data.
 my $full = $dump->xml_all();

=head1 DESCRIPTION

This module provides the ability to export the user/role
administration metadata from a ClinStudyDB database. This
authentication data was deliberately omitted from the primary
ClinStudyML schema since it's a local concern, but we still need a way
to dump and restore such data.

=head1 ATTRIBUTES

See L<ClinStudy::XML::Export> for attributes defined in this superclass.

=head1 METHODS

=head2 row_to_element

Special-cased method handling TestPossibleValue and RelatedVocab
objects appropriately. See L<ClinStudy::XML::Export> for documentation
on the generic row_to_element method.

=head1 SEE ALSO

ClinStudy::XML::Export, ClinStudy::XML::Schema, ClinStudy::XML::Loader

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

