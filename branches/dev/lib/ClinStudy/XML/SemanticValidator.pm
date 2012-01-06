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

my %BAD_CV;

sub check_semantics {

    my ( $self, $doc ) = @_;

    $self->load($doc);

    return ! scalar grep { defined $_ } values %BAD_CV;
}

sub load_object {

    my ( $self, $hashref, $rs ) = @_;

    my $class = $rs->result_source()->source_name();

    my $obj = $rs->find( $hashref );

    if ( $class eq 'ControlledVocab' ) {
        unless ( $obj ) {
            push @{ $BAD_CV{$hashref->{'category'}} }, $hashref->{'value'};
        }
    }

    return ClinStudy::XML::DummyObject->new( id => $obj ? $obj->id() : undef );
}

sub load_element {

    my ( $self, $element, $parent_ref ) = @_;

    my $class = $element->nodeName();

    my $obj = $self->next::method( $element, $parent_ref );
    
    if ( $class eq 'Visit' ) {

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
                warn("Warning: New visit for patient $pid duplicates"
                         . " pre-existing nominal timepoint.\n")
            }
        }
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

sub report {

    my ( $self ) = @_;

    my $report = q{};
    if ( scalar grep { defined $_ } values %BAD_CV ) {
        $report .= "Invalid ControlledVocab terms found:\n\n";
        foreach my $category (sort keys %BAD_CV) {
            $report .= "  $category:\n";
            foreach my $value ( @{$BAD_CV{$category}} ) {
                $report .= "    $value\n";
            }
        }
    }
    else {
        $report .= "No invalid ControlledVocab terms found.\n";
    }

    return $report;
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
