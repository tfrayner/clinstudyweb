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

package ClinStudy::Web::Controller::RelatedVocab;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::RelatedVocab - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::RelatedVocab' );
    $self->my_sort_field( 'relationship_id' );
    $self->my_container_namespace( 'controlledvocab' );

    return;
}

# FIXME ideally this would be deleted in favour of a more sane
# approach to container_namespace allowing for underscores in the
# designated containers.
sub my_container_class {

    my ( $self ) = @_;

    return('DB::ControlledVocab', 'controlled_vocab_id', 'controlledvocab');

}

sub _set_my_editing_message {

    my ( $self, $c, $object, $action, $flash ) = @_;

    $flash ||= 'flash';
    $c->$flash->{message}
        = sprintf("%s %s %s",
                  $action,
                  ( $object->relationship_id ? $object->relationship_id->value : q{} ),
                  'relationship',);
}

sub set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    my $namespace  = $self->action_namespace($c);
    my $sort_field = $self->my_sort_field();

    $c->flash->{message}
        = sprintf(qq{Deleted %s relationship},
                  $object->relationship_id->value );
}

=head2 add_to_controlled_vocab

=cut

sub add_to_controlled_vocab : Local {
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
