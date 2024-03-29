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

package ClinStudy::XML::Dumper;

use 5.008;

use strict; 
use warnings;

use Moose;

extends 'ClinStudy::XML::Export';

use Carp;
use List::Util qw(first);
use Data::Dumper;

our $VERSION = '0.01';

sub BUILD {

    my ( $self, $params ) = @_;

    $self->root_name('ClinStudyML');
    $self->root_attrs({
        'xmlns:xsi'                     => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:noNamespaceSchemaLocation' => 'clindb.xsd',
    });

    $self->classes([ qw( AssayBatch Patient ) ]);

    $self->boundaries({
        Patient    => [ qw(Channel) ],
        AssayBatch => [ qw(Sample) ],
    });

    # Note that this is identical to that in the Loader class. Shared config?
    $self->external_id_map({
        ControlledVocab => 'value',
        Test            => 'name',
        Sample          => 'name',
    });

    # When updating, also fix the version in ClinStudy::XML::Builder.
    $self->irregular_plurals({
        AssayBatch        => 'AssayBatches',
        Comorbidity       => 'Comorbidities',
        Diagnosis         => 'Diagnoses',
        PhenotypeQuantity => 'PhenotypeQuantities',
        Study             => 'Studies',
    });

    return;
}

sub xml {

    my ( $self, $objects ) = @_;

    # Check that the objects are of a supported class.
    foreach my $row ( @$objects ) {
        my $topclass = $row->result_source()->source_name();
        unless ( first { $topclass eq $_ } qw(AssayBatch Patient) ) {
            croak(qq{Error: Export of $topclass objects is not supported.\n});
        }
    }

    my @elements;
    foreach my $row ( @$objects ) {
        my $topclass = $row->result_source()->source_name();
 
        # Follow links from Patient to AssayBatch and vice versa. We
        # need to retrieve AssayBatch before Patient in each case
        # because otherwise Channel gets clobbered by the Export
        # tracker hash.
        if ( $topclass eq 'Patient' ) {
            foreach my $batch ( $row->search_related('visits')
                                    ->search_related('samples')
                                    ->search_related('channels')
                                    ->search_related('assay_id')
                                    ->search_related('assay_batch_id') ) {
                my $elem = $self->row_to_element( $batch, 'AssayBatch' );
                push( @elements, $elem ) if defined $elem;
            }
            my $elem = $self->row_to_element( $row, $topclass );
            push( @elements, $elem ) if defined $elem;
        }
        elsif ( $topclass eq 'AssayBatch' ) {
            my $elem = $self->row_to_element( $row, $topclass );
            push( @elements, $elem ) if defined $elem;
            foreach my $patient ( $row->search_related('assays')
                                      ->search_related('channels')
                                      ->search_related('sample_id')
                                      ->search_related('visit_id')
                                      ->search_related('patient_id') ) {
                my $elem = $self->row_to_element( $patient, 'Patient' );
                push( @elements, $elem ) if defined $elem;                
            }
        }
    }

    my $doc = $self->_elements_to_doc( \@elements );

    # Fix up document to remove assays referencing samples which have
    # not been exported.
    foreach my $assay ( $doc->findnodes('.//Assay') ) {
        foreach my $channel ( $assay->findnodes('./Channels/Channel') ) {
            my $sample_name = $channel->getAttribute('sample_ref');
            my @samples = $doc->findnodes(qq{.//Sample[\@name="$sample_name"]});
            unless ( scalar @samples ) {
                $assay->unbindNode();
            }
        }
    }

    if ( ! $self->validate($doc) && $self->is_strict() ) {
        croak("Error: Generated XML document does not conform to schema.\n");
    }

    return( $doc );
}

{
    # State variable used to track how many levels of TestResults
    # we've seen, and throw an error if we go too deep.
    my $LEVEL_COUNT = 0;
    my %VEG_TRACKER;
    my %PPG_TRACKER;

sub row_to_element {

    my ( $self, $row, $topclass, $parent_class, $parent_row ) = @_;

    # NOTE $parent_class and/or $parent_row may be undefined.
    
    my $source  = $row->result_source();
    my $class   = $source->source_name();

    if ( $class eq 'Patient' ) {
        warn(sprintf("Dumping data for patient %s...\n", $row->trial_id()));
    }
    elsif ( $class eq 'AssayBatch' ) {
        warn(sprintf("Dumping data for assay batch %s...\n", $row->name()));
    }

    my $element;
    if ( $class eq 'TestResult' ) {

        # Special case.

        # Check that we're not trying to attach a test aggregation
        # child, to its ultimate container class
        # (visit).
        my @parents = $row->parent_test_results();
        return if ( scalar @parents
                        && $parent_class ne 'TestResult' );

        # Note that we're not including these in the Export tracker
        # mechanism, so we need to check for infinite loops. Decrement
        # before exiting from this "if" clause.
        if ( $LEVEL_COUNT++ > 100 ) {
            croak("Error: Excessive recursion for TestResult"
                      . " heirarchy (are there really 100 levels?)");
        }

        # Create the new element.
        $element = XML::LibXML::Element->new($class);
        $self->cols_to_attrs( $row, $element, ['needs_reparenting'] );

        # test_id is a required column.
        $element->setAttribute('test', $row->test_id()->name());

        # The controlled_value column will always end up in the value
        # attr.
        my $cval = $row->controlled_value_id();
        if ( defined $cval && $cval ne q{} ) {
            $element->setAttribute('value', $cval->value());
        }

        # Recurse down into ChildTestResults.
        my @children;
        foreach my $child ( $row->child_test_results() ) {
            my $nextelem = $self->row_to_element( $child, $topclass, $class );
            push(@children, $nextelem) if defined $nextelem;
        }
        if ( scalar @children ) {
            my $group = XML::LibXML::Element->new( 'ChildTestResults' );
            $element->addChild($group);
            foreach my $child ( @children ) {
                $group->addChild($child);
            }
        }

        # Decrement because we're effectively going up a level.
        $LEVEL_COUNT--;
    }
    elsif ( $class eq 'VisitEmergentGroup' ) {

        # Special case - the generic export code needs a little help
        # getting over this many-to-many relationship.

        # We need to keep track of those VisitEmergentGroups
        # combinations we've already exported here, because Export
        # won't do it for us.
        my @pkeys   = $source->primary_columns();
        my $tkey = join('|', map { $row->get_column($_) } @pkeys);
        return if $VEG_TRACKER{$class}{$tkey}++;

        my $emergent        = $row->emergent_group_id();
        my $emergent_source = $emergent->result_source();

        $element = XML::LibXML::Element->new('EmergentGroup');

        # Simple attributes
        $self->cols_to_attrs( $emergent, $element );

        # We're only interested in the has_one relationships.
        foreach my $col ( $emergent_source->relationships() ) {
            my $reltype = $emergent_source->relationship_info($col)->{attrs}{accessor}
                or croak("Error: Unable to retrieve relationship info for $class column $col.");
            unless ( $reltype eq 'multi' ) {
                $self->rel_to_attr($emergent, $col, $element);
            }
        }
    }
    elsif ( $class eq 'PatientPriorGroup' ) {

        # Special case - the generic export code needs a little help
        # getting over this many-to-many relationship.

        # We need to keep track of those PatientPriorGroups
        # combinations we've already exported here, because Export
        # won't do it for us.
        my @pkeys   = $source->primary_columns();
        my $tkey = join('|', map { $row->get_column($_) } @pkeys);
        return if $PPG_TRACKER{$class}{$tkey}++;

        my $prior        = $row->prior_group_id();
        my $prior_source = $prior->result_source();

        $element = XML::LibXML::Element->new('PriorGroup');

        # Simple attributes
        $self->cols_to_attrs( $prior, $element );

        # We're only interested in the has_one relationships.
        foreach my $col ( $prior_source->relationships() ) {
            my $reltype = $prior_source->relationship_info($col)->{attrs}{accessor}
                or croak("Error: Unable to retrieve relationship info for $class column $col.");
            unless ( $reltype eq 'multi' ) {
                $self->rel_to_attr($prior, $col, $element);
            }
        }
    }
    else {

        # General case.
        $element = $self->next::method( $row, $topclass, $parent_class );
    }

    return $element;
}

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

    # Only Sample is used as a reference for now.
    if ( $nextclass eq 'Sample' ) {

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

ClinStudy::XML::Dumper - XML export from ClinStudyDB databases.

=head1 SYNOPSIS

 use ClinStudy::XML::Dumper;
 my $dump = ClinStudy::XML::Dumper->new(
     database => $db_schema,
 );

 # Export a list of DBIx::Class::Row objects.
 my $doc  = $dump->xml(\@patients);
 
 # Export all data.
 my $full = $dump->xml_all();

=head1 DESCRIPTION

Module handling the generation of XML from a ClinStudyDB database.

=head1 ATTRIBUTES

See L<ClinStudy::XML::Export> for attributes defined in this superclass.

=head1 METHODS

=head2 xml

Method which, when passed a list of either Patient or AssayBatch
database objects, will generate the appropriate in-memory XML::LibXML
tree structure appropriate for output with C<toString()>.

=head2 row_to_element

Special-cased method which handles TestResult, VisitEmergentGroup and
PatientPriorGroup appropriately. See L<ClinStudy::XML::Export> for
documentation on the superclass method.

=head2 rel_to_attr

Overridden method from the ClinStudy::XML::Export superclass which
knows which class attributes reference other classes.

=head1 SEE ALSO

ClinStudy::XML::Export, ClinStudy::XML::Schema, ClinStudy::XML::Loader

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

