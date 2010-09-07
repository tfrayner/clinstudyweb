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

package ClinStudy::Web::Controller::FormFuBase;

use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

use Carp;

has 'my_model_class'         => ( is       => 'rw',
                                  isa      => 'Str',
                                  required => 0 );

has 'my_sort_field'          => ( is       => 'rw',
                                  isa      => 'Str',
                                  required => 0 );

has 'my_container_namespace' => ( is       => 'rw',
                                  isa      => 'Str',
                                  required => 0 );


=head1 NAME

ClinStudy::Web::Controller::FormFuBase - Catalyst Controller base class

=head1 DESCRIPTION

Catalyst Controller. This is a base class used in many of the
model-specific controller classes.

=head1 METHODS

=cut

##################
# PUBLIC METHODS #
##################

=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ClinStudy::Web::Controller::FormFuBase index.');

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c);    
}

=head2 list

=cut

sub list : Local {

    my ( $self, $c ) = @_;

    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);

    my $sort_field = $self->my_sort_field();
    my $attrs = $c->stash()->{'search_attrs'} || {};
    if ( $sort_field ) {
        $attrs->{ order_by } ||= $sort_field;
    }

    my $search  = $c->stash()->{'search_terms'};
    my @objects = $c->model($class)->search( $search, $attrs );

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c);
    
    $c->stash->{objects} = \@objects;
}

=head2 view

=cut

sub view : Local {

    my ( $self, $c, $object_id ) = @_;

    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);
    my $namespace = $self->action_namespace($c);
    my $error_redirect = $self->my_error_redirect($c)
        or confess("Error: CIMR error redirect not set in FormFuBase controller " . ref $self);

    my $object = $c->model($class)->find({ id => $object_id });
    $c->stash->{object}   = $object;

    if ( ! $object ) {
        $c->flash->{error} = "No such $namespace!";
        $c->res->redirect( $c->uri_for( $error_redirect ) );
        $c->detach();
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, $object);
}

=head2 search

=cut

sub search : Local {

    my ( $self, $c ) = @_;

    # Figure out who we are.
    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);
    my $namespace = $self->action_namespace($c);
    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();
    my $error_redirect = $self->my_error_redirect($c)
        or confess("Error: CIMR error redirect not set in FormFuBase controller " . ref $self);
    
    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        my ( $search, $attrs ) = $self->process_search_form($c, $form);
        $c->stash->{'search_terms'} = $search;
        $c->stash->{'search_attrs'} = $attrs;
        $c->stash->{template} = "$namespace/list.tt2";
        $c->detach('list');
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c);
}

=head2 edit

=cut

sub edit : Local {

    my ( $self, $c, $object_id, $container_id ) = @_;

    # Figure out who we are.
    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);
    my $namespace = $self->action_namespace($c);
    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();
    my $error_redirect = $self->my_error_redirect($c)
        or confess("Error: CIMR error redirect not set in FormFuBase controller " . ref $self);

    # Confirm we have privileges to be here.
    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to edit this record.';
        $c->detach('/access_denied');
    }

    my $object;
    if ( ! $object_id ) {

        # Not sure why we have to specify this, but hey ho.
        my %args = ( id => undef );

        if ( $container_id && $container_namespace ) {

            # Add a new object to $container. Check that the container exists:
            my $container = $c->model($container_class)->find({ id => $container_id });
            if ( ! $container ) {
                $c->flash->{error} = "No such $container!";
                $c->res->redirect( $c->uri_for( $error_redirect ) );
                $c->detach();
            }

            $args{ $container_field } = $container;
        }

        # Create the new object.
        $object = $c->model($class)->new( \%args );
    }
    else {

        # Edit a pre-existing object.
        $object = $c->model($class)->find({ id => $object_id });
        if ( ! $object ) {
            $c->flash->{error} = "No such $namespace!";
            $c->res->redirect( $c->uri_for( $error_redirect ) );
            $c->detach();
        }
    }

    # Load the form. We do this manually because we want our DBIC
    # object on the form's stash.
    my $form = $self->load_form( $c, $object, $c->namespace . '/edit' );

    if ( $form->submitted_and_valid() ) {

        # Form was submitted and it validated.
        $c->form_values_to_database( $object, $form );

        $self->_set_my_updated_message( $c, $object, $object_id );

        $c->res->redirect( $c->uri_for('view', $object->id) );
        $c->detach();
    }
    else {

        # First time through, or invalid form.
        $self->_set_my_updating_message( $c, $object, $object_id );

        $form->model->default_values( $object );

        # Optional callback to allow us to set custom defaults on an ad-hoc basis.
        $self->_set_custom_form_defaults( $c, $form );
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, $object);

    $c->stash->{object} = $object;
}

=head2 delete

=cut

sub delete : Local {

    my ( $self, $c, $object_id ) = @_;

    if ( ! $c->check_any_user_role('editor') ) {
        $c->stash->{error} = 'Sorry, you are not authorised to delete this record.';
        $c->detach('/access_denied');
    }

    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);
    my $error_redirect = $self->my_error_redirect($c)
        or confess("Error: CIMR error redirect not set in FormFuBase controller " . ref $self);
    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();
    my $namespace  = $self->action_namespace($c);

    my $object = $c->model($class)->find({ id => $object_id });

    if ( $object ) {

        if ( my $message = $c->check_model_relationships( $object ) ) {
            $c->flash->{error}
                = sprintf("Unable to delete $namespace; it is linked to %s", $message);

            if ( $container_namespace ) {
                $c->res->redirect( $c->uri_for("/$container_namespace/view",
                                               $object->$container_field->id) );
            }
            else {
                $c->res->redirect( $c->uri_for("/$namespace/list") );
            }
            $c->detach();
        }

        $self->_set_my_deleted_message( $c, $object );

        $c->delete_database_object( $object );

        if ( $container_namespace ) {
            $c->res->redirect( $c->uri_for("/$container_namespace/view",
                                           $object->$container_field->id) );
        }
        else {
            $c->res->redirect( $c->uri_for("/$namespace/list") );
        }
        $c->detach();
    }
    else {
        $c->flash->{error} = "No such $namespace";
        $c->res->redirect( $c->uri_for( $error_redirect ) );
        $c->detach();
    }
}

# Container-based methods; these are only used by subclasses
# representing objects which are aggregated into containers (e.g.,
# diagnoses into Patient).

=head2 list_by_container

=cut

sub list_by_container {

    my ( $self, $c, $container_id ) = @_;

    my $class = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);
    my $sort_field = $self->my_sort_field()
        or warn("Warning: CIMR data sort field not set in FormFuBase controller " . ref $self . "\n");
    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();

    my @objects;
    if ( $container_id ) {
        my $container = $c->model($container_class)->find({id => $container_id});
        if ( ! $container ) {
            $c->flash->{error} = "No such $container_namespace!";
            $c->res->redirect( $c->uri_for("/$container_namespace/list") );
            $c->detach();
        }
        my %opts;
        if ( defined $sort_field ) {
            $opts{ 'order_by' } = $sort_field;
        }
        @objects = $c->model($class)->search(
            { $container_field => $container_id, },
            \%opts,
        );
        $c->stash->{container} = $container;
    }
    else {
        @objects = $c->model($class);
    }

    $c->stash->{breadcrumbs} = $self->_set_my_breadcrumbs($c, undef, $container_id);

    $c->stash->{objects} = \@objects;
}

=head2 add_to_container

=cut

sub add_to_container {

    my ( $self, $c, $container_id ) = @_;

    my $namespace = $self->action_namespace($c);
    $c->stash->{template} = "$namespace/edit.tt2";
    $c->forward('edit', [undef, $container_id]);
}

###################
# PRIVATE METHODS #
###################

# We use this in preference to the FormConfig attributes to insert our
# DBIC object onto each form's stash.
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

sub camel_case {

    my ( $term ) = @_;

    # Taken from DBIx::Class::Schema::Loader::Base for (hopefully) a
    # measure of consistency.
    my $camel = join '', map { ucfirst $_ } split /[\W_]+/, lc $term;

    return $camel;
}

# Don't override unless you know what you're doing.
sub _my_container_class {
    
    my ( $self ) = @_;

    my $namespace = $self->my_container_namespace();

    # Allow non-contained subclasses to generate an empty list here.
    return unless $namespace;

    # We rely on a couple of conventions here.
    my $dbclass   = 'DB::' . camel_case( $namespace );
    my $dbfield   = $namespace . '_id';
    
    return ( $dbclass, $dbfield, $namespace );
}

# A convenient generic method.
sub my_error_redirect {

    my ( $self, $c ) = @_;

    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();
    if ( $container_namespace ) {
        return "/$container_namespace/list";
    }
    else {
        my $namespace = $self->action_namespace($c);
        return "/$namespace/list";
    }
}

# These are just some sensible generic defaults which will often be
# overridden in the subclasses.
sub _set_my_editing_message {

    my ( $self, $c, $object, $action, $flash ) = @_;

    my $name = $self->my_model_class()
        or confess("Error: CIMR database class not set in FormFuBase controller " . ref $self);
    $name =~ s/\A DB:://xms;
    $name =~ s/([a-z])([A-Z])/$1 $2/g;
    $name = lc( $name );

    my $sort_field = $self->my_sort_field();
    $flash ||= 'flash';

    if ( $sort_field && $object->$sort_field ) {
        $c->$flash->{message}
            = sprintf("%s %s %s",
                      $action,
                      $name,
                      $object->$sort_field,);
    }
    else {
        $c->$flash->{message}
            = sprintf("%s %s",
                      $action,
                      $name,);
    }
}    

sub _set_my_updated_message {

    my ( $self, $c, $object, $object_id ) = @_;

    my $action = ( ( defined $object_id && $object_id > 0 ) ? 'Updated' : 'Added new');
    $self->_set_my_editing_message( $c, $object, $action );
}

sub _set_my_updating_message {

    my ( $self, $c, $object, $object_id ) = @_;

    my $action = ( ( defined $object_id && $object_id > 0 ) ? 'Updating' : 'Adding new');
    $self->_set_my_editing_message( $c, $object, $action, 'stash' );
}

sub _set_my_deleted_message {

    my ( $self, $c, $object ) = @_;

    my $namespace  = $self->action_namespace($c);
    my $sort_field = $self->my_sort_field();

    if ( defined $sort_field && UNIVERSAL::can( $object, $sort_field ) ) {
        $c->flash->{message}
            = sprintf(qq{Deleted %s %s},
                      $object->$sort_field,
                      $namespace, );
    }
    else {
        $c->flash->{message}
            = sprintf(qq{Deleted %s},
                      $namespace, );
    }
}

sub _set_my_breadcrumbs {

    my ( $self, $c, $object, $container_id ) = @_;

    # Link to the starting page from every other page.
    my @breadcrumbs = ({ path  => '/',
                         label => 'Start page' });

    my ( $container_class, $container_field, $container_namespace ) = $self->_my_container_class();
    my $namespace = $self->action_namespace($c);

    # This is a sticking plaster on a wider problem - deriving labels
    # from namespaces FIXME. E.g. we'd quite like to have CamelCase as
    # input and space-delim as output.
    my %irregular = ( assaybatch => 'assaybatches' );

    # If this object should have a container, put elements in
    # describing it.
    if ( $container_namespace ) {
        if ( $container_namespace eq 'patient' ) {
            push @breadcrumbs, {
                path  => "/$container_namespace",
                label => "List of ${container_namespace}s",
            };
        }
        else {
            my $label = $irregular{ $container_namespace } || $container_namespace;
            push @breadcrumbs, {
                path  => "/$container_namespace/list",
                label => "List of ${label}s",
            };
        }
        if ( $container_field ) {
            if ( $object && $object->$container_field ) {
                push @breadcrumbs, {
                    path  => "/$container_namespace/view/" . $object->$container_field->id(),
                    label => "This $container_namespace",
                };
            }
            elsif ( defined $container_id ) {
                push @breadcrumbs, {
                    path  => "/$container_namespace/view/$container_id",
                    label => "This $container_namespace",
                };
            }
        }
    }
    else {
        if ( $namespace eq 'patient' ) {
            push @breadcrumbs, {
                path  => "/$namespace",
                label => "List of ${namespace}s",
            };
        }
        else {
            my $label = $irregular{ $namespace } || "${namespace}s";
            push @breadcrumbs, {
                path  => "/$namespace/list",
                label => "List of ${label}",
            }
        }
    }

    # If $object has no ID, don't worry because the last element in
    # the breadcrumb chain is left without a link anyway.
    if ( $object ) {
        push @breadcrumbs, {
            path  => "/$namespace/view/" . ($object->id() || q{}),
            label => "This $namespace",
        };
    }

    return \@breadcrumbs;
}

sub process_search_form {

    # Method which takes a completed FormFu form and extracts a pair
    # of hashrefs suitable for passing to
    # DBIx::Class::ResultSet->search. This method is designed to be
    # subclassed for table-specific behaviour.
    my ( $self, $c, $form ) = @_;

    # Remove empty fields and the unnecessary 'submit' field.
    my ( %search, %attrs );
    my $params = $form->params();
    my $batchq = $params->{'batch'};
    if ( grep { length $_ } values %$batchq ) {

        # Batch query takes precedence.
        while ( my ( $attr, $text ) = each %$batchq ) {

            # Split lines, strip whitespace and remove blank lines.
            my @vals = grep { $_ =~ /\S/ }
                       map { my ($x) = ( $_ =~ m/^\s*(.*?)\s*$/ ) }
                       split /\n/, $text;
            $search{ $attr } = { 'in' => \@vals };
        }
    }
    elsif ( my $simpleq = $params->{'simple'} ) {

        # Simple(!) query.
        TERM:
        while ( my ( $key, $value ) = each %$simpleq ) {
            next TERM if ( $key eq 'submit' || ! defined $value );
            if ( ref($value) eq 'HASH' ) {

                # Nested query joining across multiple tables.
                my ( $subsearch, $subattrs ) = $self->_process_nested_query($key, $value);

                # Merge %search with %$subsearch, and %attrs with
                # %$subattrs. Note that key collisions are unlikely
                # but possible; example would be simultaneous search for
                # drugs.name_id from both Visit and Hospitalisation.
                @{$attrs{join}}{ keys %$subattrs } = values %$subattrs;
                @search{ keys %$subsearch }        = values %$subsearch;
            }
            elsif ( length($value) ) {
                $value =~ tr/*?/%_/;
                $search{$key} = { like => $value };
            }
        }
    }
    else {

        # This indicates a problem in the search form definition.
        $c->flash->{error} = "Internal error: search form contains neither simple nor batch query.";
        $c->res->redirect( $c->uri_for( '/error' ) );
        $c->detach();
    }

    return ( \%search, \%attrs )
}

sub _process_nested_query {

    # Recursive method used to extract an appropriate query structure
    # from FormFu search forms.

    #  input:  key => { nextkey => nextvalue }

    #  output attrs:  key => nextkey
    #  output search: key.nextkey = nextvalue
    my ( $self, $key, $value ) = @_;

    my ( %search, %attrs );

    TERM:
    while ( my ( $nextkey, $nextvalue ) = each %$value ) {

        next TERM if ( $key eq 'submit' || ! defined $nextvalue );
        if ( ref($nextvalue) eq 'HASH' ) {

            # Recurse here.
            my ( $nextsearch, $nextattrs )
                = $self->_process_nested_query( $nextkey, $nextvalue );

            # Merge %search with %$nextsearch, build up the %attr hash
            @search{ keys %$nextsearch } = values %$nextsearch;
            $attrs{ $key } = $nextattrs
                if ( scalar grep { defined $_ } values %$nextattrs ); 
        }
        elsif ( length($nextvalue) ) {
            $attrs{$key} = $nextkey;
            $nextvalue =~ tr/*?/%_/;
            $search{"$key.$nextkey"} = { 'like' => $nextvalue };
        }
    }

    return ( \%search, \%attrs );
}

sub _set_custom_form_defaults {}

=head1 AUTHOR

Tim F. Rayner <tfrayner@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner, University of Cambridge

This library is released under version 2 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable();

1;
