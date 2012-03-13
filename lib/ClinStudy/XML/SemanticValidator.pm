# Copyright 2012 Tim Rayner, University of Cambridge
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

package ClinStudy::XML::DummyObject;

use Class::Struct;

struct( id => '$' );

package ClinStudy::XML::SemanticValidator;

use 5.008;

use strict; 
use warnings;

use Carp;

use List::Util qw( first );
use Data::Dumper;

our $VERSION = '0.01';

# Preloaded methods go here.
use Moose;

extends 'ClinStudy::XML::Loader';

has 'warning_flag' => ( is       => 'rw',
                        isa      => 'Bool',
                        required => 1,
                        default  => 0, );

has 'failure_flag' => ( is       => 'rw',
                        isa      => 'Bool',
                        required => 1,
                        default  => 0, );

has 'report'       => ( is       => 'rw',
                        isa      => 'Str',
                        required => 1,
                        default  => q{} );

{
    
my %BAD_CV;

sub check_semantics {

    my ( $self, $doc ) = @_;

    $self->load($doc);

    if ( scalar grep { defined $_ } values %BAD_CV ) {
        $self->_append_report("\nInvalid ControlledVocab terms found:\n\n");
        foreach my $category (sort keys %BAD_CV) {
            $self->_append_report("  $category:\n");
            foreach my $value ( @{$BAD_CV{$category}} ) {
                $self->_append_report("    $value\n");
            }
        }
    }
    else {
        $self->_append_report("\nNo invalid ControlledVocab terms found.\n");
    }

    return ! $self->failure_flag;
}

sub load_object {

    my ( $self, $hashref, $rs ) = @_;

    my $class = $rs->result_source()->source_name();

    my $obj = $rs->find( $hashref );

    # These are never elements in their own right, so must be checked here.
    if ( $class eq 'ControlledVocab' ) {
        unless ( $obj ) {
            push @{ $BAD_CV{$hashref->{'category'}} }, $hashref->{'value'};
            $self->failure_flag(1);
        }
    }

    return ClinStudy::XML::DummyObject->new( id => $obj ? $obj->id() : undef );
}

} # End of BAD_CV scope.

sub load_element {

    my ( $self, $element, $parent_ref ) = @_;

    my $class = $element->nodeName();

    my $obj = $self->next::method( $element, $parent_ref );
    
    if ( $class eq 'Visit' ) {
        $self->_apply_visit_checks( $element, $parent_ref, $obj );
    }
    elsif ( $class eq 'Sample' ) {
        $self->_apply_sample_checks( $element, $parent_ref, $obj );
    }

    return $obj;
}

sub load_element_message {

    my ( $self, $element ) = @_;

    my $class = $element->nodeName();

    if ( $class eq 'Patient' ) {
        warn("Checking data for patient " . $element->getAttribute('trial_id') . "...\n");
    }
    elsif ( $class eq 'AssayBatch' ) {
        warn("Checking data for assay batch " . $element->getAttribute('name') . "...\n");
    }
    
    return;
}

sub find_reference {

    my ( $self, $class, $value ) = @_;

    my $rs = $self->database()->resultset($class)
        or die("Error: Unable to find a ResultSet for $class elements.");

    # Attempt to retrieve the referenced object using the configured
    # id column. If the referenced object is not in the database,
    # return a dummy object. This 
    my $rel_obj;
    if ( my $field = $self->external_id_map()->{$class} ) {
        my @rel_objs = $rs->search({ $field => $value });
        unless ( scalar @rel_objs ) {
            croak("Unable to find a $class with $field = $value.");
        }
        $rel_obj = $rel_objs[0];
    }
    else {
        croak("Unrecognised class $class in find_reference().");
    }

    return($rel_obj);
}

# Missing referent objects will throw an error unless we silently
# ignore them. In order for the XML to be syntactically valid the
# referents must be present, it's just they're not in the database
# yet. Note that if we ever make referent objects part of a given
# object's "identifier" set of attributes (which is unlikely) then
# this is probably going to cause problems.
sub handle_missing_referent {

    my ( $self, $class, $field, $value ) = @_;

    return ClinStudy::XML::DummyObject->new( id => undef );
}

sub _apply_visit_checks {

    my ( $self, $element, $parent_ref, $obj ) = @_;

    # Check for pre-existing visits for this nominal timepoint, warn if present.
    my $pid   = $parent_ref->{patient_id};
    my $nt_cv = $element->getAttribute('nominal_timepoint');
    if ( defined $pid && defined $nt_cv ) {

        # This should never fail; $pid has only just been
        # retrieved from the database by load_object().
        my $patient = $self->database()->resultset('Patient')->find($pid)
            or confess("Unable to retrieve patient with ID $pid");

        my @visit_ids = map { $_->id() }
            $patient->search_related('visits',
                                     { 'nominal_timepoint_id.value' => $nt_cv },
                                     { join => 'nominal_timepoint_id' });
            
        if ( scalar @visit_ids
                 && ! ( defined $obj->id()
                            && first { $_ == $obj->id() } @visit_ids ) ) {
            $self->_append_report("Warning: New visit for patient $pid duplicates"
                                      . " pre-existing nominal timepoint.\n");
            $self->warning_flag(1);
        }
    }

    return;
}

sub _apply_sample_checks {

    my ( $self, $element, $parent_ref, $obj ) = @_;

    # Check for pre-existing samples for this cell type, warn if present.
    my $vid   = $parent_ref->{visit_id};
    my $ct_cv = $element->getAttribute('cell_type');
    my $mt_cv = $element->getAttribute('material_type');
    if ( defined $vid && defined $ct_cv && defined $mt_cv ) {

        # This should never fail; $vid has only just been
        # retrieved from the database by load_object().
        my $visit = $self->database()->resultset('Visit')->find($vid)
            or confess("Unable to retrieve visit with ID $vid");

        my @sample_ids = map { $_->id() }
            $visit->search_related('samples',
                                   { 'cell_type_id.value'     => $ct_cv,
                                     'material_type_id.value' => $mt_cv },
                                   { join => [ 'cell_type_id', 'material_type_id' ] });
            
        if ( scalar @sample_ids
                 && ! ( defined $obj->id()
                            && first { $_ == $obj->id() } @sample_ids ) ) {
            $self->_append_report("Warning: New sample for visit $vid duplicates"
                                      . " pre-existing cell type.\n");
            $self->warning_flag(1);
        }
    }

    return;
}

sub _append_report {

    my ( $self, $str ) = @_;

    $self->report( $self->report() . $str );

    return;
}

1;
__END__

=head1 NAME

ClinStudy::XML::SemanticValidator - Report on potential problems with a ClinStudyML document.

=head1 SYNOPSIS

 use ClinStudy::XML::SemanticValidator;
 my $validator = ClinStudy::XML::SemanticValidator->new(
     database    => $schema,
     schema_file => $xsd,
 );
 $validator->check_semantics( $xml );
 
 if ( $validator->failure_flag() ) {
     die("Semantic validation failed: \n\n" . $validator->report());
 }

=head1 DESCRIPTION

This is a lightweight ClinStudyML validation module which checks the
content of a document against a ClinStudyWeb database instance,
reporting on any irregularities it finds.

=head1 ATTRIBUTES

=head2 failure_flag

Boolean flag indicating whether validation failed (TRUE=failure). If
this is set then typically an subsequent database loading will
fail. Given that failed loads should automatically roll back this is
little more than a time-saver.

=head2 warning_flag

Boolean flag indicating whether validation generated any warnings
(TRUE=warnings were generated). If this is set then subsequent loading
may alter the database in ways you didn't want. This flag is therefore
far more important than the failure_flag.

=head2 report

A string holding the validation report; this should give reasons for
the above flags being set, so that the document can be inspected and
modified if necessary.

=head1 METHODS

=head2 check_semantics

The core method used to check the document contents. Takes as its
argument the same XML::LibXML::Document object as is required by the
Loader->load method.

=head2 load_object

Overridden loader method used to prevent any update or insert into the database.

=head2 load_element

Overridden loader method which contains much of the validation code.

=head2 load_element_message

Overridden loader method generating a user-friendly message.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

