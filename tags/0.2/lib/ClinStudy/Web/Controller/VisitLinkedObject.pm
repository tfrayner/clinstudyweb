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

package ClinStudy::Web::Controller::VisitLinkedObject;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

use Carp;

=head1 NAME

ClinStudy::Web::Controller::VisitLinkedObject - Catalyst Controller abstract class

=head1 DESCRIPTION

Catalyst Controller. This is an abstract class used in many of the
model-specific controller classes.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_container_namespace( 'visit' );

    return;
}

##################
# PUBLIC METHODS #
##################

=head2 list_by_visit 

=cut

sub list_by_visit : Local {
    my $self = shift;
    $self->SUPER::list_by_container( @_ );
}

=head2 add_to_visit

=cut

sub add_to_visit : Local {
    my $self = shift;
    $self->SUPER::add_to_container( @_ );
}

###################
# PRIVATE METHODS #
###################

sub _set_my_breadcrumbs {

    # Since Visit is itself a PatientLinkedObject we now have more
    # levels of navigation to take care of.
    my ( $self, $c, $object, $container_id ) = @_;

    my $breadcrumbs = $self->SUPER::_set_my_breadcrumbs( $c, $object, $container_id );

    my @fixed = grep { $_->{path} !~ '/visit/list' } @$breadcrumbs;

    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();

    if ( $container_field && $object ) {
        my $visit = $object->$container_field;
        my $patient = $visit->patient_id();

        # Rewrite our superclass breadcrumbs to add in some new levels.
        my @extra = ( $fixed[0],
                      {
                          path  => '/patient',
                          label => 'List of patients',
                      },
                      {
                          path  => '/patient/view/' . $patient->id(),
                          label => 'This patient',
                      },
                      @fixed[1..$#fixed] );
        @fixed = @extra;
    }

    return \@fixed;
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable();

1;
