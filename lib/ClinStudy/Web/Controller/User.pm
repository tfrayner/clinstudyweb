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

package ClinStudy::Web::Controller::User;

use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

use Digest;

=head1 NAME

ClinStudy::Web::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ClinStudy::Web::Controller::User in User.');
}

=head2 list

=cut

sub list : Local {

    my ( $self, $c ) = @_;

    my $users = $c->model('DB::User')->search(
        undef,
        { order_by => 'username' },
    );
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
    $c->stash->{users} = $users;
}

=head2 add

=cut

sub add : Local { 
    my ($self, $c) = @_;

    # Public method to allow new account creation.

    my $user = $c->model('DB::User')->new({});

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $user );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.

        # Hash and update the password.
        my $password = $self->reset_user_password( $user );

        # Set the creation date.
        my $date = $c->date_today();
        $user->set_column( date_created  => $date );
        $user->set_column( date_modified => $date );

        # Insert the user into the database.
        $c->form_values_to_database( $user, $form );

        # Log the user in. Don't try to log in if
        # we're already logged in, e.g. as admin.
        unless ( $c->user() ) {
            $c->authenticate({ username => $user->username,
                               password => $password });
        }

        # Set our message and pass back to list view.
        $c->flash->{message} = sprintf( "Added %s with password %s", $user->username, $password );
        if ( $c->check_any_user_role('admin') ) {
            $c->res->redirect( $c->uri_for('list') );
        }
        else {
            $c->res->redirect( $c->uri_for('/') );
        }
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $c->stash->{message} = 'Adding a new user';
        $form->model->default_values( $user );

        # Add in our reCAPTCHA configuration. Each site needs a new pair of keys.
        if ( my $field = $form->get_field({ type => 'reCAPTCHA' }) ) {
            $field->private_key( $c->config->{'reCAPTCHA'}{'private_key'} );
            $field->public_key(  $c->config->{'reCAPTCHA'}{'public_key'}  );
        };
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $user);
}

=head2 edit

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;

    # Admin-only method used to manage role-based privileges etc.
    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'You are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    my $user;
    if ( $id ) {
        unless ( $user = $c->model('DB::User')->find({ id => $id }) ) {
            $c->flash->{error} = 'No such user!';
            $c->res->redirect( $c->uri_for('list') );
            $c->detach();
        }
    }
    else {
        $user = $c->model('DB::User')->new({});
    }
    $c->stash->{user} = $user;

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $user );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated. Set the modification date.
        $user->set_column( date_modified => $c->date_today() );
        $c->form_values_to_database( $user, $form );

        # N.B. Password is never set in edit runmode so we don't rehash it.

        # Set our message and pass back to list view.
        $c->flash->{message} = 'Updated ' . $user->username;
        if ( $c->check_any_user_role('admin') ) {
            $c->res->redirect( $c->uri_for('list') );
        }
        else {
            $c->res->redirect( $c->uri_for('/') );
        }
        $c->detach();
    }
    else {
        $form->model->default_values( $user );
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c, $user);
}

=head2 edit

=cut

sub modify : Local {
    my ( $self, $c, $id ) = @_;

    # User-level method for resetting email, password etc.
    if ( $id != eval{ $c->user->id } ) {
        $c->stash->{error} = 'You are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    my $user;
    unless ( $user = $c->model('DB::User')->find({ id => $id }) ) {
        $c->flash->{error} = 'No such user!';
        $c->res->redirect( $c->uri_for('list') );
        $c->detach();
    }
    $c->stash->{user} = $user;

    # Template is basically the same, but the form differs.
    $c->stash->{template} = 'user/edit.tt2';

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $user );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.

        # Hash the submitted password *before* updating the database.
        my $ctx = Digest->new('SHA-1');
        $ctx->add( $form->param_value('password') );
        $form->add_valid( 'password', $ctx->hexdigest() );

        # Update the record. Set the modification date.
        $user->set_column( date_modified => $c->date_today() );
        $c->form_values_to_database( $user, $form );

        # Set our message and pass back to list view.
        $c->flash->{message} = 'Updated ' . $user->username;
        if ( $c->check_any_user_role('admin') ) {
            $c->res->redirect( $c->uri_for('list') );
        }
        else {
            $c->res->redirect( $c->uri_for('/') );
        }
        $c->detach();
    }
    else {
        $form->model->default_values( $user );
    }

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
}

=head2 reset

=cut

sub reset : Local {

    my ( $self, $c, $id ) = @_;

    # General user- and admin- level method to automatically reset the
    # password to something moderately hard to crack.
    if ( $id != eval{ $c->user->id }
        && ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'You are not authorised to edit this record.';
        $c->detach( '/access_denied' );
    }

    my $user = $c->model('DB::User')->find({ id => $id });

    # Change the password in memory; we need to call $user->update
    # after this call.
    my $password = $self->reset_user_password( $user );

    # Set the modification date.
    $c->update_database_object( $user, { date_modified => $c->date_today() } );

    $c->flash->{message}
        = sprintf("Reset password for %s to %s.", $user->username, $password);
    if ( $c->check_any_user_role('admin') ) {
        $c->res->redirect( $c->uri_for('list') );
    }
    else {
        $c->res->redirect( $c->uri_for('/') );
    }
    $c->detach();    
}

=head2 delete

=cut

sub delete : Local {

    my ( $self, $c, $id ) = @_;

    # Admin-level method for deleting unwanted users.

    if ( ! $c->check_any_user_role('admin') ) {
        $c->stash->{error} = 'You are not authorised to delete this record.';
        $c->detach('/access_denied');
    }

    my $user = $c->model('DB::User')->find({ id => $id });

    if ( $user ) {

        # Prevent accidental deletion of admin users here.
        if ( scalar grep { $_->rolename() eq 'admin' } $user->roles() ) {
            $c->stash->{error} = 'Users with an admin role cannot be deleted.'
                               . ' Please remove the admin role and retry.';
            $c->detach('/access_denied');
        }

        $c->flash->{message}
            = sprintf("Deleted user %s", $user->username);

        # Actually delete the user.
        $c->delete_database_object( $user );

        $c->res->redirect( $c->uri_for('/user/list/') );
        $c->detach();
    }
    else {
        $c->flash->{error} = 'No such user';
        $c->res->redirect( $c->uri_for('/user/list') );
        $c->detach();
    }
}

=head2 create_password

=cut

{   # Create a closure over this array.
    my @pass_chars = ( 'A'..'Z', 'a'..'z', 0..9 );

    sub create_password {

	my $self = shift;

	# Simply returns a random string suitable for use as a
	# password. Can pass an optional length argument, otherwise
	# defaults to eight chars.

	my $length = shift || 8;

	my $password = q{};
	for ( 1..$length ) {
	    $password .= $pass_chars[int rand(scalar @pass_chars)];
	}
	return $password;
    }
}

=head2 reset_user_password

=cut

sub reset_user_password {

    my ( $self, $user, $password ) = @_;

    $password ||= $self->create_password();
    
    my $ctx = Digest->new('SHA-1');
    $ctx->add( $password );

    $user->set_column( password => $ctx->hexdigest() );

    return $password;
}

###########
# PRIVATE #
###########

# We use this in preference to the FormConfig attributes to insert our
# DBIC object onto each form's stash. This is copied from FormFuBase
# rather than subclassing, which might have undesirable security
# implications.
sub load_form {

    my ( $self, $c, $object, $action ) = @_;

    $action ||= $c->action;
    my $form = $self->form();
    $form->load_config_filestem($action);
    $form->stash->{object} = $object if defined $object;
    $form->process();
    $c->stash->{form} = $form;

    return $form;
}

sub set_my_breadcrumbs : Private {

    my ( $self, $c, $user ) = @_;

    my @crumbs = (
        {
            path  => '/',
            label => 'Start page',
        },
        {
            path  => '/user/list',
            label => 'User admin',
        },
    );

    if ( $user && $user->id() ) {
        push @crumbs, {
            path  => '/user/edit/' . $user->id(),
            label => 'This user',
        };
    }

    return \@crumbs;
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
