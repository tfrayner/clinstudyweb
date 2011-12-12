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

package ClinStudy::XML::Loader;

use 5.008;

use strict; 
use warnings;

use Carp;

use Moose;
extends 'ClinStudy::XML::Import';

use Storable qw(dclone);

has 'is_constrained'    => ( is       => 'rw',
                             isa      => 'Bool',
                             required => 1,
                             default  => 1 );

our $VERSION = '0.01';

my @load_order = qw(Patients AssayBatches);

my %external_id_map = (
    ControlledVocab => 'value',
    Test            => 'name',
    Sample          => 'name',
);

my %external_value_map = (
    ControlledVocab => {
        category => {
            AssayBatch => {
                platform_id          => 'PlatformType',
            },
            AdverseEvent => {
                severity_id          => 'AdverseSeverity',
                action_id            => 'AdverseAction',
                outcome_id           => 'AdverseOutcome',
                trial_related_id     => 'AdverseTrialRelated',
            },
            Channel => {
                label_id             => 'LabelCompound',
            },
            ClinicalFeature => {
                type_id              => 'ClinicalFeature',
            },
            Diagnosis => {
                condition_name_id    => 'DiagnosisCondition',
                confidence_id        => 'DiagnosisConfidence',
                previous_course_id   => 'PreviousDiseaseCourse',
                disease_staging_id   => 'DiseaseStaging',
                disease_extent_id    => 'DiseaseExtent',
            },
            DiseaseEvent => {
                type_id              => 'DiseaseEventType',
            },
            Drug => {
                name_id              => 'DrugName',
                locale_id            => 'DrugLocale',
                dose_unit_id         => 'DoseUnit',
                dose_freq_id         => 'DoseFrequency',
                duration_unit_id     => 'TimeUnit',
            },
            EmergentGroup => {
                type_id              => 'PatientGroup',
                basis_id             => 'PatientGroupBasis',
            },
            PriorGroup => {
                type_id              => 'PriorGroup',
            },
            Patient => {
                ethnicity_id         => 'Ethnicity',
                home_centre_id       => 'HomeCentre',
            },
            PhenotypeQuantity => {
                type_id              => 'PhenotypeQuantityType',
            },
            PriorObservation => {
                type_id              => 'ObservationType',
            },
            PriorTreatment => {
                type_id              => 'TreatmentType',
                nominal_timepoint_id => 'PriorTimepoint' ,
                duration_unit_id     => 'TimeUnit',
            },
            RiskFactor => {
                type_id              => 'RiskFactor',
            },
            Sample => {
                cell_type_id         => 'CellType',
                material_type_id     => 'MaterialType',
                quality_score_id     => 'QualityScore',
            },
            SampleDataFile => {
                type_id              => 'SampleDataType',
            },
            SystemInvolvement => {
                type_id              => 'SystemInvolvement',
            },
            Study => {
                type_id              => 'StudyType',
            },
            TestPossibleValues => {
                possible_value_id    => 'TestResult',
            },
            TestResult => {
                controlled_value_id  => 'TestResult',
            },
            Transplant => {
                sensitisation_status_id => 'SensitisationStatus',
                organ_type_id           => 'OrganType',
                reperfusion_quality_id  => 'ReperfusionQuality',
                donor_type_id           => 'DonorType',
            },
            Visit => {
                disease_activity_id  => 'DiseaseActivity',
                nominal_timepoint_id => 'NominalTimepoint',
            },
            VisitDataFile => {
                type_id              => 'VisitDataType',
            },
        },
    },
);

sub BUILD {

    my ( $self, $params ) = @_;

    # Set up our subclass config here.
    $self->load_order( \@load_order );

    $self->external_id_map( \%external_id_map );

    $self->external_value_map( \%external_value_map );

    return;
}

sub _update_testresult_attrs {

    # This method modifies $row_ref in-place to convert value to
    # controlled_value in appropriate cases.
    my ( $self, $element, $row_ref ) = @_;

    # Fairly standard attr extraction.
    foreach my $attr ( $element->attributes() ) {
        next unless $attr->isa('XML::LibXML::Attr');
        $self->process_attr( $attr, $row_ref );
    }

    # Remap value to controlled_value as appropriate.
    my $test = $self->database()->resultset('Test')->find($row_ref->{'test_id'});

    # Rewrite $row_ref to repoint controlled_values to the correct
    # ControlledVocab row.
    if ( defined $row_ref->{'value'} ) {
        my @possible = $test->possible_values();
        if ( scalar @possible ) {

            # This can really only return one result.
            my @res = $test->search_related('test_possible_values')
                           ->search_related('possible_value_id',
                                            { value => $row_ref->{'value'} });
            if ( scalar @res ) {
                $row_ref->{'controlled_value_id'} = $res[0]->id();
                delete $row_ref->{'value'};
            }
            elsif ( $self->is_constrained() ) {
                croak(sprintf(qq{Error: Attempting to load a TestResult for test "%s"}
                            . qq{ with an incorrect controlled_value "%s".\n},
                              $test->name(), $row_ref->{'value'} ));
            }
        }
    }

    return;
}

sub load_element {

    my  ( $self, $element, $parent_ref ) = @_;

    my $class = $element->nodeName();

    if ( $class eq 'Patient' ) {
        warn("Importing data for patient " . $element->getAttribute('trial_id') . "...\n");
    }
    elsif ( $class eq 'AssayBatch' ) {
        warn("Importing data for assay batch " . $element->getAttribute('name') . "...\n");
    }

    my $rs = $self->database()->resultset($class)
        or die("Error: Unable to find a ResultSet for $class elements.");

    my $obj;
    if ( $class eq 'TestResult' ) {

        if ( exists( $parent_ref->{'test_result_id'} ) ) {

            # We handle nested ChildTestResults here as a special
            # case. The alternative would have been another many-to-many
            # relationship in the XML Schema, which would have been rather
            # more complicated to use than I'd have liked.
            my $parent_id = $parent_ref->{'test_result_id'};
            $parent_ref = {};  # Throws away any other incoming information; beware.

            # Copy element attrs to our hashref.
            $self->_update_testresult_attrs( $element, $parent_ref );

            # Retrieve the parent TestResult.
            my $parent = $rs->find( $parent_id )
                or croak("Error: Unable to find parent TestResult ($parent_id).");

            # Link the child to the same container as the parents.
            foreach my $col ( qw(visit_id hospitalisation_id) ) {
                $parent_ref->{$col} = $parent->$col;
            }

            # Create the child TestResult.
            my $obj = $self->load_object($parent_ref, $rs);

            # Link it to its parent.
            my $sub_rs = $self->database()->resultset('TestAggregation');
            $self->load_object({
                aggregate_result_id => $parent->id(),
                test_result_id      => $obj->id(),
            }, $sub_rs);
        }
        else {

            # Regular TestResult; we have to check for
            # controlled_value constraints though.

            # Clone the parent_ref, otherwise we get carry-over of attributes
            # between elements.
            my $row_ref = dclone( $parent_ref );
            $self->_update_testresult_attrs( $element, $row_ref );
            $obj = $self->load_object($row_ref, $rs);
        }
    }
    elsif ( $class eq 'EmergentGroup' ) {
        my $parent_id = $parent_ref->{'visit_id'};
        $parent_ref = {};  # Throws away any other incoming information; beware.

        foreach my $attr ( $element->attributes() ) {
            next unless $attr->isa('XML::LibXML::Attr');
            $self->process_attr( $attr, $parent_ref );
        }
        
        my $visit = $self->database()->resultset('Visit')->find($parent_id)
            or croak("Error: Unable to find parent Visit ($parent_id).");

        my $obj = $self->load_object( $parent_ref, $rs );

        my $sub_rs = $self->database()->resultset('VisitEmergentGroup');
        $self->load_object({
            visit_id          => $visit->id(),
            emergent_group_id => $obj->id(),
        }, $sub_rs);
    }
    elsif ( $class eq 'PriorGroup' ) {
        my $parent_id = $parent_ref->{'patient_id'};
        $parent_ref = {};  # Throws away any other incoming information; beware.

        foreach my $attr ( $element->attributes() ) {
            next unless $attr->isa('XML::LibXML::Attr');
            $self->process_attr( $attr, $parent_ref );
        }
        
        my $patient = $self->database()->resultset('Patient')->find($parent_id)
            or croak("Error: Unable to find parent Patient ($parent_id).");

        my $obj = $self->load_object( $parent_ref, $rs );

        my $sub_rs = $self->database()->resultset('PatientPriorGroup');
        $self->load_object({
            patient_id     => $patient->id(),
            prior_group_id => $obj->id(),
        }, $sub_rs);
    }
    else {
        $obj = $self->next::method( $element, $parent_ref );
    }

    return $obj;
}

sub load_object {

    # We override the core superclass loading method to check for
    # attempts to load invalid CVs. Note that it would be nice if we
    # could prevalidate XML against the database to avoid such
    # attempts.
    my ( $self, $hashref, $rs ) = @_;

    my $class = $rs->result_source()->source_name();

    my $obj;
    if ( $class eq 'ControlledVocab' && $self->is_constrained() ) {
        $obj = $rs->find( $hashref );
        unless ( $obj ) {
            my $mess =
                sprintf("Error: Attempting to load an invalid ControlledVocab term (%s => %s). Allowed values:\n",
                        $hashref->{'category'},
                        $hashref->{'value'} );
            $mess .= join("\n", map { $_->value() } $rs->search({ category => $hashref->{'category'} }) );
            die("$mess\n");
        }
    }
    else {
        $obj = $self->next::method( $hashref, $rs );
    }

    return $obj;
}

1;

__END__

=head1 NAME

ClinStudy::XML::Loader - Perl extension for handling ClinStudy XML

=head1 SYNOPSIS

 use ClinStudy::XML::Loader;
 my $loader = ClinStudy::XML::Loader->new(
     schema_file => 'my_schema.xsd',
     database    => $db_schema,
 );
 $loader->validate($doc) or die("Incorrect XML");
 $loader->load($doc);

=head1 DESCRIPTION

A module designed to handle validation of XML according to the
ClinStudy schema, and loading of such XML into a database. This is a
database-specific subclass of the ClinStudy::XML::Import class.

=head1 ATTRIBUTES

=head2 is_constrained

Simple boolean flag indicating whether to raise an exception if the
semantic framework previously loaded into the database is violated by
the loaded document (default=True). Typically this is only set to
False in certain specialised operations, for example merging
ClinStudyML documents using a temporary SQLite database.

=head1 METHODS

=head2 load_element

Special handling for TestResult, EmergentGroup and PriorGroup
(i.e. many-to-many relationships). See L<ClinStudy::XML::Import> for
more information.

=head2 load_object

Special-cased method which, if C<$self->is_constrained>, refuses to
load new ControlledVocab terms into the database. Otherwise hands off
to the superclass method documented in L<ClinStudy::XML::Import>.

=head1 SEE ALSO

L<ClinStudy::XML::Import>,
L<ClinStudy::XML::Schema>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

