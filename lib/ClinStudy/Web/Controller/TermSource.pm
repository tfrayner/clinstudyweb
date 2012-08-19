
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

package ClinStudy::Web::Controller::TermSource;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::TermSource - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::TermSource' );
    $self->my_sort_field( 'name' );

    return;
}

=head2 add

Add a new term source.

=cut

sub add : Local { 
    my ($self, $c) = @_; 
    $c->stash->{template} = 'termsource/edit.tt2'; 
    $c->forward('edit', [undef]); 
}

=head2 edit

Edit a given term source. This is restricted to admin-level users.

=cut

sub edit : Local { 

    my ($self, $c, @args) = @_; 

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit term sources.';
        $c->detach( '/access_denied' );
    }

    $self->next::method( $c, @args )
}

=head2 delete

Delete a given term source. This is restricted to admin-level users.

=cut

sub delete : Local { 

    my ($self, $c, @args) = @_; 

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to delete term sources.';
        $c->detach( '/access_denied' );
    }

    $self->next::method( $c, @args )
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
