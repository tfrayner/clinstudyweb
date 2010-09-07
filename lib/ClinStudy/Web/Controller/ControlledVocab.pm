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

package ClinStudy::Web::Controller::ControlledVocab;

use Moose;
use namespace::autoclean;

BEGIN {extends 'ClinStudy::Web::Controller::FormFuBase'; }

=head1 NAME

ClinStudy::Web::Controller::ControlledVocab - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->my_model_class( 'DB::ControlledVocab' );
    $self->my_sort_field( 'category' );

    return;
}

sub _set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    $c->flash->{message}
        = sprintf(qq{Deleted "%s" => "%s"},
                  $object->category,
                  $object->value, );
}

=head2 add

Add a new CV term in one of the pre-existing CV categories.

=cut

sub add : Local { 
    my ($self, $c) = @_; 
    $c->stash->{template} = 'controlledvocab/edit.tt2'; 
    $c->forward('common_edit', [undef]); 
}

=head2 add_category

Edit a given CV term, but also allow the user to edit the text of the
CV category, thereby permitting the addition of new CV
categories. This should be an admin-level operation.

=cut

sub add_category : Local { 

    my ($self, $c) = @_; 

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to add free-text categories.';
        $c->detach( '/access_denied' );
    }

    $c->stash->{template} = 'controlledvocab/edit.tt2'; 
    $c->forward('common_edit', [undef, 'edit_category']); 
}

=head2 edit

Edit a given CV term. This method prevents the user from adding new CV
categories, instead presenting a drop-down menu in the interface.

=cut

sub edit : Local { 

    my ($self, $c, $id) = @_; 

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit controlled vocab terms.';
        $c->detach( '/access_denied' );
    }

    $c->stash->{template} = 'controlledvocab/edit.tt2'; 
    $c->forward('common_edit', [$id]); 
}

=head2 common_edit

A private method which the edit, add and add_category methods all use
behind the scenes.

=cut

sub common_edit : Private {

    my ( $self, $c, $id, $template ) = @_;

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    my $cv;
    if ( $id ) {
        unless ( $cv = $c->model('DB::ControlledVocab')->find({ id => $id }) ) {
            $c->flash->{error} = 'No such controlled vocabulary term!';
            $c->res->redirect( $c->uri_for('list') );
            $c->detach();
        }
    }
    else {
        $cv = $c->model('DB::ControlledVocab')->new({});
    }

    $c->stash->{object} = $cv;

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    $template ||= 'edit';
    my $form = $self->load_form( $c, $cv, "controlledvocab/$template" );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $c->form_values_to_database( $cv, $form );

        # Set our message and pass back to list view.
        $c->flash->{message}
            = ( $id ? 'Updated ' : 'Added ' )
                . sprintf("%s => %s", $cv->category, $cv->value);
        $c->res->redirect( $c->uri_for('view', $cv->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        if ( ! $id ) {
            $c->stash->{message} = 'Adding a new controlled vocabulary term';
        }

        $form->model()->default_values( $cv );

        # Populate our allowed category values from the CV table. We
        # indulge in a little duck-typing to determine whether the
        # category field is free text or a select field.
        my $field = $form->get_field( 'category' );
        if ( UNIVERSAL::can( $field, 'options' ) ) {
            my %cvs = map { $_ => 1 } $c->model('DB::ControlledVocab')->get_column('category')->all();
            $field->options( [ map { [ $_, $_ ] } sort keys %cvs ] );
        }
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, $cv);    
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
