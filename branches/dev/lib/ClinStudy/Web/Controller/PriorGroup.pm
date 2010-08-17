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

package ClinStudy::Web::Controller::PriorGroup;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::PriorGroup - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::PriorGroup' );

    return;
}

=head2 add

=cut

sub add : Local { 
    my ($self, $c) = @_; 
    $c->stash->{template} = 'priorgroup/edit.tt2'; 
    $c->forward('edit', [undef]); 
}

sub set_my_updated_message {

    my ( $self, $c, $object, $object_id ) = @_;

    $c->flash->{message}
        = ( $object_id ? 'Updated ' : 'Added ' )
            . sprintf("%s (%s)",
                      $object->name,
                      $object->type_id->value,);
}

sub set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    $c->flash->{message}
        = sprintf(qq{Deleted group %s (%s)},
                  $object->name,
                  $object->type_id->value, );
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
