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
    if ( defined $vid && defined $ct_cv ) {

        # This should never fail; $vid has only just been
        # retrieved from the database by load_object().
        my $visit = $self->database()->resultset('Visit')->find($vid)
            or confess("Unable to retrieve visit with ID $vid");

        my @sample_ids = map { $_->id() }
            $visit->search_related('samples',
                                   { 'cell_type_id.value' => $ct_cv },
                                   { join => 'cell_type_id' });
            
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
 blah blah blah

=head1 DESCRIPTION

Stub documentation for ClinStudy::XML::SemanticValidator, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

=head2 EXPORT

None by default.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=head1 BUGS

Probably.

=cut

