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

package ClinStudy::Web::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

use Carp;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

ClinStudy::Web::Controller::Root - Root Controller for ClinStudy::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index : Private {

    my ( $self, $c ) = @_;
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
}

=head2 default

Then, in answer to my query,
Through the net I loved so dearly,
Came its answer, dark and dreary:
Quoth the server, "404".

=cut

sub default : Private {

    my ( $self, $c ) = @_;
    $c->response->status('404');
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
    push @{ $c->stash->{breadcrumbs} }, {
        path  => '/',
        label => 'Not found',
    };
    $c->stash->{template} = 'not_found.tt2';
}

=head2 access_denied

Where the dispossessed and disenfranchised ultimately end up.

=cut

sub access_denied : Private {

    my ( $self, $c, $action ) = @_;
    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
    push @{ $c->stash->{breadcrumbs} }, {
        path  => '/',
        label => 'Access denied',
    };
    $c->stash->{template} = 'denied.tt2';
}

=head2 login

The primary login action, tied into the users/roles table system in
the underlying ClinStudy database.

=cut

sub login : Global FormConfig {

    my ( $self, $c ) = @_;

    $c->stash->{breadcrumbs} = $self->set_my_breadcrumbs($c);
    push @{ $c->stash->{breadcrumbs} }, {
        path  => '/login',
        label => 'Login',
    };

    my $form = $c->stash->{form};

    return unless $form->submitted_and_valid();

    if ( $c->authenticate({ username => $form->param_value('username'),
                            password => $form->param_value('password'), }) ) {

        # Set the access date.
        $self->update_database_timestamp( $c );

        $c->flash->{message} = 'Logged in successfully.';
        $c->res->redirect($c->uri_for('/'));
        $c->detach();
    }
    else {
        $c->stash->{error} = 'Login failed.';
    }
}

=head2 raven_login

A completely separate login action that (in theory) uses the
University of Cambridge Raven authentication system. Note that roles
are still managed locally by the underlying ClinStudy instance, so a user
logging in using Raven still needs an account in ClinStudy.

=cut

sub raven_login : Global FormConfig('login.yml') {

    my ( $self, $c ) = @_;

    $c->stash->{template} = 'login.tt2';

    if ( $c->user ) {
        $c->flash->{error} = 'Already logged in as another user.';
        $c->res->redirect($c->uri_for('/'));
        $c->detach();
    }
        
    my $result = $c->authenticate( {}, 'raven' );

    if ( $c->user ) {

        # Track the fact that this is a Raven login for later logout purposes. 
        $c->session->{'is_raven'} = 1;
        if ( $c->user->in_storage ) {

            # User is in our local database.

            # Set the access date.
            $self->update_database_timestamp( $c );

            $c->flash->{message} = 'Successfully logged in via Raven.';
            $c->res->redirect($c->uri_for('/'));
            $c->detach();
        }
        else {

            # Raven user is fine, but not entered in our local DB.
            $c->logout;
            $c->flash->{error} = 'Local access has not been granted for this Raven user.';
            $c->res->redirect($c->uri_for('/'));
            $c->detach();
        }
    }

    return;
}

=head2 logout

Standard logout action.

=cut

sub logout : Global {

    my ( $self, $c ) = @_;

    my $is_raven = $c->session->{'is_raven'};

    # Whatever happens we want to log out.
    $c->logout;

    # If the user logged in via Raven, log them out the same way.
    if ( $is_raven ) {

        # The session persists, but this is no longer Raven-based.
        $c->session->{'is_raven'} = 0;
        $c->res->redirect('https://raven.cam.ac.uk/auth/logout.html');
        $c->detach();
    }
    
    $c->flash->{message} = 'Logged out.';
    $c->res->redirect( $c->uri_for('/') );
}

sub set_my_breadcrumbs : Private {

    my ( $self, $c ) = @_;

    my @crumbs = (
        {
            path  => '/',
            label => 'Start page',
        },
    );

    return \@crumbs;
}

sub update_database_timestamp {

    my ( $self, $c ) = @_;

    my $schema = $c->model('DB::User')->result_source->schema();

    if ( my $user = $c->user() ) {
        $schema->changeset_user( $user->id() );
        if ( my $session_id = $c->sessionid() ) {
            $schema->changeset_session( $session_id );
        }
        $schema->txn_do(
            sub { $user->set_column( date_accessed => $c->date_today() );
                  $user->update(); }
        );        
    }
    else {
        confess("There's no point trying to update the database if the user failed to log in.");
    }

    return;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable();

1;
