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

package ClinStudy::Web::Controller::PatientLinkedObject;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

use Carp;

=head1 NAME

ClinStudy::Web::Controller::PatientLinkedObject - Catalyst Controller abstract class

=head1 DESCRIPTION

Catalyst Controller. This is an abstract class used in many of the
model-specific controller classes.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_container_namespace( 'patient' );

    return;
}

###################
# PRIVATE METHODS #
###################

sub _derive_nametag {

    my ( $self ) = @_;

    my $name = $self->my_model_class()
        or confess("Error: CIMR database class not set in PatientLinkedObject controller " . ref $self);
    $name =~ s/\A DB:://xms;
    $name =~ s/([a-z])([A-Z])/$1 $2/g;
    $name = lc( $name );

    return $name;
}

sub set_my_updated_message {

    my ( $self, $c, $object, $object_id ) = @_;

    my $name = $self->_derive_nametag();

    $c->flash->{message}
        = sprintf("%s %s for %s",
                  ( $object_id && $object_id > 0 ? 'Updated ' : 'Added new '),
                  $name,
                  $object->patient_id->trial_id,);
}

sub set_my_updating_message {

    my ( $self, $c, $object, $object_id ) = @_;

    my $name = $self->_derive_nametag();

    $c->stash->{message}    # I think we do mean to use the stash here, rather than flash.
        = sprintf("%s %s for %s",
                  ( $object_id && $object_id > 0 ? 'Updating a ' : 'Adding a new '),
                  $name,
                  $object->patient_id->trial_id,);
}

sub set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    my $name = $self->_derive_nametag();
    my $sort_field = $self->my_sort_field();

    if ( defined $sort_field ) {
        $c->flash->{message}
            = sprintf("Deleted %s %s for %s",
                      $object->$sort_field,
                      $name,
                      $object->patient_id->trial_id, );
    }
    else {
        $c->flash->{message}
            = sprintf("Deleted %s for %s",
                      $name,
                      $object->patient_id->trial_id, );
    }
}

##################
# PUBLIC METHODS #
##################

=head2 list_by_patient 

=cut

sub list_by_patient : Local {
    my $self = shift;
    $self->SUPER::list_by_container( @_ );
}

=head2 add_to_patient

=cut

sub add_to_patient : Local {
    my $self = shift;
    $self->SUPER::add_to_container( @_ );
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
