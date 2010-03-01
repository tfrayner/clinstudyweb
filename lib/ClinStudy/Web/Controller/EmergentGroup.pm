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

package ClinStudy::Web::Controller::EmergentGroup;

use strict;
use warnings;

use parent 'ClinStudy::Web::Controller::FormFuBase';

=head1 NAME

ClinStudy::Web::Controller::EmergentGroup - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub new {

    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->my_model_class( 'DB::EmergentGroup' );
    $self->my_container_namespace( undef );

    return $self;
}

=head2 add

=cut

sub add : Local { 
    my ($self, $c) = @_; 
    $c->stash->{template} = 'emergentgroup/edit.tt2'; 
    $c->forward('edit', [undef]); 
}

sub set_my_updated_message {

    my ( $self, $c, $object, $object_id ) = @_;

    $c->flash->{message}
        = ( $object_id ? 'Updated ' : 'Added ' )
            . sprintf("%s (%s, %s)",
                      $object->name,
                      $object->type_id->value,
                      $object->basis_id->value,);
}

sub set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    $c->flash->{message}
        = sprintf(qq{Deleted group %s (%s, %s)},
                  $object->name,
                  $object->type_id->value,
                  $object->basis_id->value, );
}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

1;
